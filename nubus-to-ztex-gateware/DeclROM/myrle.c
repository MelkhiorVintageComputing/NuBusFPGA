#include <stdint.h>

//#include <stdio.h>

#ifndef SKIP_MAIN
uint32_t rleenc(uint32_t* out, const uint32_t* in, const uint32_t len) {
	uint32_t i = 0, j = 0, p = 0, ib, k;
	int32_t c = 0;

	p = in[0];

	for (i = 1 ; i < len ; i++) {
		if (c == 0) { // just started
			if (in[i] == p) { // repeat
				c++;
			} else { // non-repeat
				p = in[i];
				c--;
				ib = i - 1;
			}
		} else if (c > 0) { // in-repeat
			if (in[i] == p) { // keep repeating
				c++;
			} else { // exit repeat
				out[j++] = __builtin_bswap32(c); // write result
				out[j++] = p;
				p = in[i]; // restart
				c = 0;
			}
		} else { // c < 0
			if (in[i] == p) { // exit non-repeat
				out[j++] = __builtin_bswap32(c+1); // write result, removing previous
				for (k = 0 ; k < (-c) ; k++)
					out[j++] = in[ib+k];
				p = in[i]; // restart
				c = 1; // this and previous
			} else { // non-repeat
				p = in[i];
				c--;
			}
		}

	}
	out[j++] = __builtin_bswap32(c);
	out[j++] = p;

	return j;
}
#endif


uint32_t rledec(uint32_t* out, const uint32_t* in, const uint32_t len) {
	uint32_t i = 0, j = 0, k = 0, chk = 0, ib;

	for (i = 0 ; i < len ; ) {
#ifndef __m68k__
		int32_t c = (int32_t)__builtin_bswap32(in[i]);
#else
		int32_t c = (int32_t)(in[i]);
#endif
		if (c >= 0) {
			chk += (1 + c);
			if (c < 300000) { // !!!!!!!!!!!!!!!!!!!!!!!!!!
				for (k = 0 ; k < (c + 1) ; k++)
					out[j++] = in[i+1];
			} else { // do a small subset at the beginning and end instead of the full range and assume this is padding otherwise
				for (k = 0 ; k < 4 ; k++)
					out[j+k] = in[i+1];
				for (k = c-3 ; k < (c + 1) ; k++)
					out[j+k] = in[i+1];
				j += c+1;
			}
			i += 2;
		} else {
			chk += (1 + -c);
			for (k = 0 ; k < (1 + -c) ; k++)
				out[j++] = in[i+1+k];
			i += 2 + -c;
		}
		//fprintf(stderr, "%u: %u <> %u (%d, 0x%08x)\n", i, j, chk, c, in[i+1]);
	}
	return j;
}

#ifndef SKIP_MAIN
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/uio.h>
#include <unistd.h>

int main(int argc, char** argv) {
	int fd;
	uint32_t len, k;
	uint32_t *bufa, *bufb;
	FILE* f;

	bufa = calloc(sizeof(uint32_t), 256*1024*1024/sizeof(uint32_t));
	bufb = calloc(sizeof(uint32_t), 256*1024*1024/sizeof(uint32_t));

	fd = open("dump.raw", O_RDONLY);
	len = read(fd, bufa, 248*1024*1024ull) / 4;
	close(fd);

	printf("File : %d bytes\n", len*4);

	len = rleenc(bufb, bufa, len);
  
	printf("Compressed : %d bytes\n", len*4);

	/* for (k = 0 ; k < len ; k++) */
	/*   bufb[k] = __builtin_bswap32(bufb[k]); */

	fd = open("dump.cpr", O_WRONLY | O_CREAT, S_IRWXU);
	/* len =  */write (fd, bufb, len*4);
	close(fd);

	/* for (k = 0 ; k < len ; k++) */
	/*   bufb[k] = __builtin_bswap32(bufb[k]); */

	f = fopen("dump_cpr.c", "w");
	/* fprintf(f, "unsigned char* compressed[%d] = {\n", len*4); */
	/* for (k = 0 ; k < len*4 ; k++) { */
	/*   fprintf(f, "0x%02x%s", ((unsigned char*)bufb)[k], */
	/* 	    k == (len*4-1) ? "};" : (k%16 == 15 ? ",\n" : ",") */
	/* 	    ); */
	/* } */
	fprintf(f, "unsigned long* compressed[%d] = {\n", len);
	for (k = 0 ; k < len ; k++) {
		fprintf(f, "0x%08x%s", bufb[k],
				k == (len-1) ? "};" : (k%8 == 7 ? ",\n" : ",")
				);
	}
	fclose(f);

	len = rledec(bufa, bufb, len);
  
	printf("Uncompressed : %d bytes\n", len*4);

	fd = open("dump.ucp", O_WRONLY | O_CREAT, S_IRWXU);
	len = write (fd, bufa, len*4);
	close(fd);
  
	return 0;
}

#endif
