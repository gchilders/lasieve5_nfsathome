/* for mpqs <=96 Bit */

#define TINY

/*
#define ASM_MPQS_SIEVE_INIT
#define ASM_MPQS_SIEVE
#define ASM_MPQS_SIEVE0
#define ASM_MPQS_EVAL
#define ASM_MPQS_TD
#define ASM_MPQS_GAUSS
#define ASM_MPQS_NEXT_POL
*/


#ifdef TINY
static ushort mpqs_param[14][7]={
 { 30, 3, 2, 5, 7, 30, 768},      /* 44 */
 { 30, 3, 3, 5, 9, 30, 1024},     /* 48 */
 { 35, 3, 3, 5, 10, 40, 1280},    /* 52 */
 { 40, 3, 3, 6, 10, 50, 1536},    /* 56 */
 { 50, 3, 3, 6, 10, 50, 1536},    /* 60 */
 { 60, 3, 3, 6, 11, 60, 1536},    /* 64 */
 { 60, 3, 3, 7, 11, 60, 1792},    /* 68 */
 { 80, 3, 3, 7, 12, 50, 2048},    /* 72 */
 { 90, 3, 3, 7, 13, 50, 2048},    /* 76 */
 { 110, 3, 3, 7, 14, 60, 2560},   /* 80 */
 { 120, 3, 4, 7, 14, 60, 2560},   /* 84 */
 { 140, 3, 4, 7, 15, 80, 3072},   /* 88 */
 { 150, 3, 4, 7, 16, 80, 3072},   /* 92 */
 { 160, 4, 4, 8, 17, 80, 3072}    /* 96 */
};
/* second parameter useless in TINY-variant */
#else
static ushort mpqs_param[14][7]={
 { 40, 3, 2, 4, 11, 16, 16384},
 { 40, 3, 2, 4, 11, 16, 16384},
 { 40, 3, 2, 4, 11, 16, 16384},
 { 50, 3, 2, 4, 12, 16, 16384},
 { 60, 3, 3, 4, 15, 16, 16384},
 { 70, 3, 3, 5, 14, 16, 16384},
 { 80, 3, 3, 5, 14, 16, 16384},
 { 90, 3, 3, 5, 15, 20, 16384},
 { 110, 3, 3, 5, 17, 20, 16384},
 { 120, 3, 3, 5, 19, 20, 16384},
 { 140, 3, 4, 6, 18, 30, 16384},
 { 140, 3, 4, 6, 20, 40, 16384},
 { 160, 3, 4, 6, 21, 50, 16384},
 { 180, 4, 4, 6, 23, 70, 16384}
};
#endif


/* for mpqs >=96 Bit */

#define TINY3

/*
 #define ASM_MPQS3_NEXT_POL
 #define ASM_MPQS3_SIEVE_INIT
 #define ASM_MPQS3_SIEVE
 #define ASM_MPQS3_SIEVE0
 #define ASM_MPQS3_EVAL
 #define ASM_MPQS3_TD
 #define ASM_MPQS3_TDSIEVE
*/

#ifdef TINY3
static ushort mpqs3_param[15][7]={
 { 160, 0, 4, 7, 17, 70, 4096},    /* 92 */
 { 170, 0, 4, 8, 17, 80, 4096},    /* 96 */
 { 200, 0, 4, 8, 17, 100, 5120},   /* 100 */
 { 220, 0, 4, 8, 19, 120, 5120},   /* 104 */
 { 240, 0, 4, 8, 19, 130, 6144},   /* 108 */
 { 270, 0, 5, 8, 21, 130, 7168},   /* 112 */
 { 310, 0, 5, 9, 21, 130, 8192},   /* 116 */
 { 350, 0, 5, 9, 21, 130, 10240},  /* 120 */
 { 380, 0, 5, 9, 22, 130, 11264},  /* 124 */
 { 410, 0, 5, 9, 22, 130, 12800},  /* 128 bit */

 { 440, 0, 5, 9, 22, 440, 16384},   /* experimental */
 { 540, 0, 6, 10, 22, 540, 16384},
 { 600, 0, 6, 10, 22, 600, 16384},
 { 660, 0, 6, 11, 22, 660, 16384},
 { 720, 0, 6, 11, 22, 720, 16384}

};
/* second parameter useless in TINY3-variant */
#else
static ushort mpqs3_param[15][7]={
 { 160, 4, 4, 6, 21, 50, 16384},
 { 180, 4, 4, 7, 22, 70, 16384},
 { 200, 4, 4, 7, 23, 70, 16384},
 { 220, 4, 5, 7, 23, 70, 16384},
 { 250, 4, 5, 8, 24, 70, 16384},
 { 290, 4, 5, 8, 25, 70, 16384},
 { 330, 5, 5, 9, 25, 70, 16384},
 { 370, 5, 5, 9, 25, 80, 16384},
 { 410, 4, 5, 9, 25, 80, 16384},
 { 440, 4, 5, 9, 25, 90, 16384},   /* 128 bit */

 { 480, 4, 5, 9, 25, 90, 16384},   /* experimental */
 { 540, 4, 6, 11, 25, 90, 16384},
 { 600, 4, 7, 11, 25, 90, 16384},
 { 660, 4, 7, 12, 25, 90, 16384},
 { 720, 4, 7, 12, 25, 90, 16384}

};
#endif

