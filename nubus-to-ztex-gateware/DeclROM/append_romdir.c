// 00 00 10 0a 00 00 00 00 01 01 5a 93 2b c7 00 0f



#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <errno.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

struct dir {
	uint32_t oslt;
	uint32_t length;
	uint32_t crc;
	uint8_t one;
	uint8_t appleformat;
	uint8_t tp0;
	uint8_t tp1;
	uint8_t tp2;
	uint8_t tp3;
	uint8_t zero;
	uint8_t bytelane;
};

int main(int argc, char **argv) {
	struct dir data;
	struct stat buf;
	int fd;

	if (argc < 2) {
		fprintf(stderr, "no I/O file\n");
		exit(-1);
	}


	data.oslt = 0;
	data.length = 0;
	data.crc = 0;
	data.one = 1;
	data.appleformat = 1;
	data.tp0 = 0x5a;
	data.tp1 = 0x93;
	data.tp2 = 0x2b;
	data.tp3 = 0xc7;
	data.zero = 0;
	data.bytelane = 0x0F;

	if (stat(argv[1], &buf)) {
		fprintf(stderr, "stat: %d -> %s\n", errno, strerror(errno));
		exit(-2);
	}

	data.length = sizeof(data) + buf.st_size;

	printf("size is %u\n", data.length);

	//.long (\entry_type<<24) + ((\label-.) & 0xffffff)
	data.oslt = 0x00 << 24 | (-buf.st_size) & 0xFFFFFF;
	
	printf("entry is 0x%08x\n", data.oslt);
	
	data.length = __builtin_bswap32(data.length);
	data.oslt = __builtin_bswap32(data.oslt);

	if ((fd = open(argv[1], O_WRONLY | O_APPEND)) == -1) {
		fprintf(stderr, "open: %d -> %s\n", errno, strerror(errno));
		exit(-3);
	}

	write(fd, &data, sizeof(data));
	
	close(fd);

	return 0;
}
