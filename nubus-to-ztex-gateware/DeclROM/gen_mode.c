#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#if 0
	ALIGN 2
_HiRes8Modes:	
             OSLstEntry    mVidParams,_HRV8Parms         /*  offset to vid parameters */
             DatLstEntry   mPageCnt,Pages8s             /*  number of video pages */
             DatLstEntry   mDevType,clutType         /*  device type */
             .long   EndOfList                  /*  end of list */
_HRV8Parms:	
             .long          _EndHRV8Parms-_HRV8Parms      /*  physical block size  */
             .long          defmBaseOffset              /*  QuickDraw base offset ; vpBaseOffset */
             .word          RB8s                        /*  physRowBytes ; vpRowBytes */
             .word          defmBounds_Ts,defmBounds_Ls,defmBounds_Bs,defmBounds_Rs /*  vpBounds */
             .word          defVersion                  /*  bmVersion ; vpVersion */
             .word	   0				/*  packType not used ; vpPackType */
             .long	   0 				/*  packSize not used ; vpPackSize */
             .long          defmHRes                    /*  bmHRes  */
             .long          defmVRes                    /*  bmVRes */
             .word          ChunkyIndexed               /*  bmPixelType */
             .word          8                           /*  bmPixelSize */
             .word          1                           /*  bmCmpCount */
             .word          8                           /*  bmCmpSize */
             .long          defmPlaneBytes              /*  bmPlaneBytes */
_EndHRV8Parms:


		

	ALIGN 2
_sRsrc_GoboFB:	
	OSLstEntry  sRsrcType,_GoboFBType      /*  video type descriptor */
    OSLstEntry  sRsrcName,_GoboFBName      /*  offset to driver name string */
    OSLstEntry  sRsrcDrvrDir,_GoboFBDrvrDir /* offset to driver directory */
	DatLstEntry  sRsrcFlags,6    /* force 32 bits mode & open */
    DatLstEntry sRsrcHWDevId,1           /*  hardware device ID */
    OSLstEntry  MinorBaseOS,_MinorBase    /*  offset to frame buffer array */
    OSLstEntry  MinorLength,_MinorLength  /*  offset to frame buffer length */
    /* OSLstEntry  sGammaDir,_GammaDirS      /*  directory for 640x480 monitor */
/*  Parameters */
    OSLstEntry  firstVidMode,_HiRes8Modes        /*  offset to 8 Bit Mode parms */
    OSLstEntry  secondVidMode,_HiRes4Modes        /*  offset to 4 Bit Mode parms */
    OSLstEntry  thirdVidMode,_HiRes2Modes        /*  offset to 2 Bit Mode parms */
    OSLstEntry  fourthVidMode,_HiRes1Modes        /*  offset to 1 Bit Mode parms */
    OSLstEntry  fifthVidMode,_HiRes24Modes        /*  offset to 24/32 Bit Mode parms */
    OSLstEntry  sixthVidMode,_HiRes15Modes        /*  offset to 15/16 Bit Mode parms */
    .long EndOfList               /*  end of list */

		
	ALIGN 2
_VModeName:	
	OSLstEntry	sRsrc_GoboFB, _ScreenNameGoboFBHiRes
	OSLstEntry	sRsrc_GoboFB_13, _ScreenNameGoboFB13
	DatLstEntry	endOfList,	0

	ALIGN 2
_ScreenNameGoboFBHiRes:	
	.long		_ScreenNameGoboFBHiResEnd - _ScreenNameGoboFBHiRes
	.word		0
	.string		"GoblinFB Native\0"
_ScreenNameGoboFBHiResEnd:
#endif

struct one_res {
				  const unsigned short hres;
				  const unsigned short vres;
};

#define NUM_RES 16
#if 0
static struct one_res res_db[NUM_RES] = {
							 { 1920, 1080 },
							 { 1680, 1050 }, // should be unsuitable
							 { 1600,  900 },
							 { 1440,  900 },
							 
							 { 1280, 1024 },
							 { 1280,  960 },
							 { 1280,  800 },
							 { 1152,  870 },
							 
							 { 1152,  864 },
							 { 1024,  768 },
							 {  832,  624 },
							 {  800,  600 },
							 
							 {  768,  576 },
							 {  640,  480 },
							 {  512,  384 },
							 {    0,    0 }			 
};
#else
static struct one_res res_db[NUM_RES] = {
							 { 1920, 1080 },
							 { 1600,  900 },
							 {  640,  480 },
							 {    0,    0}
};
#endif

int main(int argc, char **argv) {
	unsigned short maxhres = 1920, maxvres = 1080;
	const int depthdb[6] = { 8, 4, 2, 1, 32, 16 };
	int enabled[NUM_RES];
	int i, j;
	unsigned char id;

	for (i = 0 ; i < NUM_RES ; i++) {
		enabled[i] = 0;
	}

	if (argc == 3) {
		maxhres = atoi(argv[1]);
		maxvres = atoi(argv[2]);
	}
	fprintf(stderr, "Resolution: %hu x %hu\n", maxhres, maxvres);

	id = 0x80;
	for (i = 0 ; (res_db[i].hres != 0) && (res_db[i].vres != 0) && (id < 0x90); i++) { // 0x90 is the ram disk
		char filename[512];
		const unsigned short hres = res_db[i].hres;
		const unsigned short vres = res_db[i].vres;
		FILE *fd;

		if ((hres * vres) % 128) // unsuitable
			continue;
		
		snprintf(filename, 512, "VidRomRes_%hux%hu.s", hres, vres);	
		fd = fopen(filename, "w");
		if (fd == NULL) {
			fprintf(stderr, "Generating '%s' failed.\n", filename);
			return -1;
		}
		if ((hres <= maxhres) && (vres <= maxvres)) {
			enabled[i] = 1;
			id ++;
		
			for (j = 0 ; j < 6 ; j++) {
				char modename[128];
				const unsigned short depth = depthdb[j];
				const unsigned short rowBytes = (hres * depth) / 8;
				snprintf(modename, 128, "R%hux%huD%d", hres, vres, depth);
			
				fprintf(fd, "\tALIGN 2\n");
				fprintf(fd, "_%sModes: /* id 0x%02x */\n", modename, id-1);
				fprintf(fd, "\tOSLstEntry\tmVidParams,_%sParms\t/* offset to vid parameters */\n", modename);
				fprintf(fd, "\tDatLstEntry\tmPageCnt,1\t/* number of video pages */\n");
				fprintf(fd, "\tDatLstEntry\tmDevType,clutType\t/* device type */\n");
				fprintf(fd, "\t.long\tEndOfList\t/* end of list */\n");
				fprintf(fd, "_%sParms:\n", modename);
				fprintf(fd, "\t.long\t_End%sParms-_%sParms\t/* physical block size */\n", modename, modename);
				fprintf(fd, "\t.long\t0\t/* QuickDraw base offset ; vpBaseOffset */\n"); // defmBaseOffset
				fprintf(fd, "\t.word\t%hu\t/* physRowBytes ; vpRowBytes */\n", rowBytes);
				fprintf(fd, "\t.word\t0,0,%hu,%hu\t/* vpBounds */\n", vres, hres);
				fprintf(fd, "\t.word\tdefVersion\t/* bmVersion ; vpVersion */\n");
				fprintf(fd, "\t.word\t0\t/* packType not used ; vpPackType */\n");
				fprintf(fd, "\t.long\t0\t/* packSize not used ; vpPackSize */\n");
				fprintf(fd, "\t.long\tdefmHRes\t/* bmHRes */\n");
				fprintf(fd, "\t.long\tdefmVRes\t/* bmVRes */\n");
				fprintf(fd, "\t.word\tChunkyIndexed\t/* bmPixelType */\n");
				fprintf(fd, "\t.word\t%d\t/* bmPixelSize */\n", depth);
				fprintf(fd, "\t.word\t%d\t/* bmCmpCount */\n", depth <= 8 ? 1 : 3);
				fprintf(fd, "\t.word\t%d\t/* bmCmpSize */\n", depth <= 8 ? depth : (depth == 32 ? 8 : 5));
				fprintf(fd, "\t.long\t0\t/* bmPlaneBytes */\n"); // defmPlaneBytes
				fprintf(fd, "_End%sParms:\n\n",modename);
			}
		}
		fclose(fd);
	}
	
	{
		char filename[512];
		FILE *fd;
		id = 0x80;
		snprintf(filename, 512, "VidRomRes.s");
		fd = fopen(filename, "w");
		if (fd == NULL) {
			fprintf(stderr, "Generating '%s' failed.\n", filename);
			return -1;
		}
		
		for (i = 0 ; (res_db[i].hres != 0) && (res_db[i].vres != 0) ; i++) {
			const unsigned short hres = res_db[i].hres;
			const unsigned short vres = res_db[i].vres;
			if (enabled[i]) {
				fprintf(fd, ".include \"VidRomRes_%hux%hu.s\"\n", hres, vres);
			}
		}
		
		fclose(fd);
	}

	{
		char filename[512];
		FILE *fd;
		snprintf(filename, 512, "VidRomName.s");
		fd = fopen(filename, "w");
		if (fd == NULL) {
			fprintf(stderr, "Generating '%s' failed.\n", filename);
			return -1;
		}
		fprintf(fd, "\tALIGN 2\n");
		fprintf(fd, "_VModeName:\n");
		
		for (i = 0 ; (res_db[i].hres != 0) && (res_db[i].vres != 0) ; i++) {
			const unsigned short hres = res_db[i].hres;
			const unsigned short vres = res_db[i].vres;
			if (enabled[i]) {
				fprintf(fd, "\tOSLstEntry\tsRsrc_GoboFB_R%hux%hu,_ScreenNameGoboFB_R%hux%hu\n", hres, vres, hres, vres);
			}
		}
		fprintf(fd, "\tDatLstEntry	endOfList,	0\n");

		for (i = 0 ; (res_db[i].hres != 0) && (res_db[i].vres != 0) ; i++) {
			const unsigned short hres = res_db[i].hres;
			const unsigned short vres = res_db[i].vres;
			if (enabled[i]) {
				int native = (hres == maxhres) && (vres == maxvres);
				fprintf(fd, "\tALIGN 2\n");
				fprintf(fd, "_ScreenNameGoboFB_R%hux%hu:\n", hres, vres);
				fprintf(fd, "\t.long\t_ScreenNameGoboFB_R%hux%huEnd - _ScreenNameGoboFB_R%hux%hu\n", hres, vres, hres, vres);
				fprintf(fd, "\t.word\t0\n");
				fprintf(fd, "\t.string\t\"GoblinFB %hux%hu%s\\0\"\n", hres, vres, native ? " (N)": "");
				fprintf(fd, "_ScreenNameGoboFB_R%hux%huEnd:\n", hres, vres);
			}
		}
		
		fclose(fd);
	}

	{
		char filename[512];
		FILE *fd;
		snprintf(filename, 512, "VidRomDir_%hux%hu.s", maxhres, maxvres);
		fd = fopen(filename, "w");
		if (fd == NULL) {
			fprintf(stderr, "Generating '%s' failed.\n", filename);
			return -1;
		}
		for (i = 0 ; (res_db[i].hres != 0) && (res_db[i].vres != 0) ; i++) {
			const unsigned short hres = res_db[i].hres;
			const unsigned short vres = res_db[i].vres;
			if (enabled[i]) {
				int native = (hres == maxhres) && (vres == maxvres);
				fprintf(fd, "\tALIGN 2\n");
				fprintf(fd, "_sRsrc_GoboFB_R%hux%hu:\n", hres, vres);
				fprintf(fd, "\tOSLstEntry\tsRsrcType,_GoboFBType\t/* video type descriptor */\n");
				fprintf(fd, "\tOSLstEntry\tsRsrcName,_GoboFBName\t/* offset to driver name string */\n");
				fprintf(fd, "\tOSLstEntry\tsRsrcDrvrDir,_GoboFBDrvrDir /* offset to driver directory */\n");
				fprintf(fd, "\tDatLstEntry\tsRsrcFlags,%d\t/* force 32 bits mode & open (native) - or not (others)*/\n", native ? 6 : 0);
				fprintf(fd, "\tDatLstEntry\tsRsrcHWDevId,1\t/* hardware device ID */\n");
				fprintf(fd, "\tOSLstEntry\tMinorBaseOS,_MinorBase\t/* offset to frame buffer array */\n");
				fprintf(fd, "\tOSLstEntry\tMinorLength,_MinorLength\t/* offset to frame buffer length */\n");
				fprintf(fd, "\t/* OSLstEntry\tsGammaDir,_GammaDirS\t/* directory for 640x480 monitor */\n");
				fprintf(fd, "/* Parameters */\n");
				fprintf(fd, "\tOSLstEntry\tfirstVidMode,_R%hux%huD8Modes\t/* offset to 8 Bit Mode parms */\n", hres, vres);
				fprintf(fd, "\tOSLstEntry\tsecondVidMode,_R%hux%huD4Modes\t/* offset to 4 Bit Mode parms */\n", hres, vres);
				fprintf(fd, "\tOSLstEntry\tthirdVidMode,_R%hux%huD2Modes\t/* offset to 2 Bit Mode parms */\n", hres, vres);
				fprintf(fd, "\tOSLstEntry\tfourthVidMode,_R%hux%huD1Modes\t/* offset to 1 Bit Mode parms */\n", hres, vres);
				fprintf(fd, "\tOSLstEntry\tfifthVidMode,_R%hux%huD32Modes\t/* offset to 24/32 Bit Mode parms */\n", hres, vres);
				fprintf(fd, "\tOSLstEntry\tsixthVidMode,_R%hux%huD16Modes\t/* offset to 15/16 Bit Mode parms */\n", hres, vres);
				fprintf(fd, "\t.long EndOfList\t/* end of list */\n\n");
			}
		}
		fclose(fd);
	}
	
	{
		char filename[512];
		FILE *fd;
		unsigned char id = 0x80;
		snprintf(filename, 512, "VidRomDir.s");
		fd = fopen(filename, "w");
		if (fd == NULL) {
			fprintf(stderr, "Generating '%s' failed.\n", filename);
			return -1;
		}
		
		fprintf(fd, "\t.include \"VidRomDir_%hux%hu.s\"\n", maxhres, maxvres);
		
		fclose(fd);
	}

	
	{
		char filename[512];
		FILE *fd;
		unsigned char id = 0x80;
		snprintf(filename, 512, "VidRomDef.s");
		fd = fopen(filename, "w");
		if (fd == NULL) {
			fprintf(stderr, "Generating '%s' failed.\n", filename);
			return -1;
		}
		
		for (i = 0 ; (res_db[i].hres != 0) && (res_db[i].vres != 0) ; i++) {
			const unsigned short hres = res_db[i].hres;
			const unsigned short vres = res_db[i].vres;
			if (enabled[i]) {
				fprintf(fd, "sRsrc_GoboFB_R%hux%hu = 0x%02hhx\n", hres, vres, id++);
			}
		}
		
		fclose(fd);
	}
	
	{
		char filename[512];
		FILE *fd;
		snprintf(filename, 512, "VidRomRsrcDir.s");
		fd = fopen(filename, "w");
		if (fd == NULL) {
			fprintf(stderr, "Generating '%s' failed.\n", filename);
			return -1;
		}
		fprintf(fd, "_sRsrcDir:\n");
		fprintf(fd, "\tOSLstEntry\tsRsrc_Board,_sRsrc_Board\t/*  board sRsrc List */\n");
		for (i = 0 ; (res_db[i].hres != 0) && (res_db[i].vres != 0) ; i++) {
			const unsigned short hres = res_db[i].hres;
			const unsigned short vres = res_db[i].vres;
			if (enabled[i]) {
				fprintf(fd, "\tOSLstEntry\tsRsrc_GoboFB_R%hux%hu,_sRsrc_GoboFB_R%hux%hu/* video sRsrc List */\n", hres, vres, hres, vres);
			}
		}
		fprintf(fd, "\tDatLstEntry	endOfList,	0\n");
		
		fclose(fd);
	}
	
			
	return 0;
}
