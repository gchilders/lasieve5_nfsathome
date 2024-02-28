# Copyright (C) 2001,2002 Jens Franke
# This file is part of gnfs4linux, distributed under the terms of the 
# GNU General Public Licence and WITHOUT ANY WARRANTY.

# You should have received a copy of the GNU General Public License along
# with this program; see the file COPYING.  If not, write to the Free
# Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
# 02111-1307, USA.

#ifdef DEBUG
#CFLAGS= -DGATHER_STAT -DDEBUG -g
#else

# SMJS various ones I've used

# For gcc installed using brew on osx 10.9 (note -Wa,-q which specifies using clang as rather than system one)
# CFLAGS= -m64 -Ofast -march=native -fomit-frame-pointer -funroll-loops -I/Users/searle/progs/ensc-dependencies/include -Wa,-q
#CFLAGS= -m64 -Ofast -march=corei7 -mtune=corei7 -I/Users/searle/progs/ensc-dependencies/include -Wa,-q

# windows one
#CFLAGS=-Wall -Wno-unused-variable -Wno-unused-function -Wno-unused-but-set-variable -Ofast -fomit-frame-pointer -march=corei7 -mtune=corei7 -funroll-loops -Ic:/users/steve/progs/local/include 

# linux
CFLAGS=-Wall -Wno-unused-variable -Wno-unused-function -O2 -fomit-frame-pointer -march=native -funroll-loops -fcommon

#clang
#CFLAGS= -Wall -Wno-unused-variable -Wno-unused-function -Ofast -march=native -I/Users/searle/progs/ensc-dependencies/include
#clang for profiling
#CFLAGS= -O1 -g -march=native -I/Users/searle/progs/ensc-dependencies/include

#endif

GMP_LIB=-lgmp
#For windows
#GMP_LIB=-Lc:/Users/steve/progs/local/lib -lgmp -lws2_32
#Using brew installed gmp
#GMP_LIB=-L/usr/local/Cellar/gmp4/4.3.2/lib -lgmp
#orig
#GMP_LIB=/home/franke/itanium-bin/libgmp.a

include paths

CC=gcc  $(CFLAGS)
#CC=gcc-4.9  $(CFLAGS)
#CC=clang  $(CFLAGS)
#CC=x86_64-w64-mingw32-gcc-10-posix $(CFLAGS)

CTANGLE=ctangle
#CTANGLE='c:/progra~2/cweb/bin/ctangle.exe'

.SUFFIXES:

.SECONDARY: *.c *.o *.a

SRCFILES=fbgen.c fbgen.h lasieve-prepn.w la-cs.w if.w gmp-aux.w mpz-ull.w \
	fbgen64.c fbgen64.h \
	real-poly-aux.c real-poly-aux.h recurrence6.w redu2.w input-poly.w \
	input-poly-orig.w \
	primgen32.w primgen64.w gnfs-lasieve4e.w gnfs-lasieve4g.w \
	td.[ch] \
	ecm.[ch] strategy.w ecmtest.c \
	ecmstat.c mpqsstat.c mpqstest.c mpqs3test.c mpqs.c mpqs3.c \
	pprime_p.c pm1.[ch] pm1test.c pm1stat.c gnfs-lasieve4f.w


ASMDIRS=athlon athlon64 piii generic xeon64

list_asm_files = \
	$(foreach file, $(shell $(MAKE) -s -C $(asm_dir) bup),$(asm_dir)/$(file))

ASMFILES=$(foreach asm_dir,$(ASMDIRS),$(list_asm_files))

asm/%:	force
	$(MAKE) -C asm $*

%.c: %.w %.ch
	$(CTANGLE) $*.w $*.ch

%.c: %.w
	$(CTANGLE) $*.w

%.h: %.w %.ch
	$(CTANGLE) $*.w $*.ch

%.h: %.w
	$(CTANGLE) $*.w

%.tex: %.w %.ch
	cweave $*.w $*.ch

%.tex: %.w
	cweave $*.w

%.dvi: %.tex
	tex $<

%.s: %.asm
	gasp -c '#' -o $@ $^

%.o: %.c if.h asm/siever-config.h
	$(CC) -c -o $@ $<

%.o: %.s
	$(CC) -c $^

.PHONY:	force

alle: gnfs-lasieve4I11e  gnfs-lasieve4I12e  gnfs-lasieve4I13e  gnfs-lasieve4I14e   gnfs-lasieve4I15e  gnfs-lasieve4I16e

allf: gnfs-lasieve4I11f  gnfs-lasieve4I12f  gnfs-lasieve4I13f  gnfs-lasieve4I14f   gnfs-lasieve4I15f  gnfs-lasieve4I16f

allg: gnfs-lasieve4I11g  gnfs-lasieve4I12g  gnfs-lasieve4I13g  gnfs-lasieve4I14g   gnfs-lasieve4I15g  gnfs-lasieve4I16g

input-poly.o: input-poly.h

input-poly-orig.o: input-poly-orig.h

fbgen.o: gmp-aux.h

fbgen.o lasieve-prepn.o: asm/32bit.h

recurrence6.o: recurrence6.c recurrence6.h if.h asm/siever-config.h
	$(CC) -c -o $@ $<

redu2.o: redu2.h

primgen32.o fbgen.o: primgen32.h

gnfs-lasieve4e.c: la-cs.w

gnfs-lasieve4eI%.o: gnfs-lasieve4e.c if.h primgen32.h asm/32bit.h redu2.h \
	recurrence6.h fbgen.h real-poly-aux.h gmp-aux.h asm/medsched.h \
	asm/siever-config.h lasieve-prepn.h input-poly.h asm/lasched.h \
	strategy.h
	$(CC) -c -DI_bits=$* -o $@ $<

gnfs-lasieve4fI%.o: gnfs-lasieve4f.c if.h primgen32.h asm/32bit.h redu2.h \
	recurrence6.h fbgen.h real-poly-aux.h gmp-aux.h asm/medsched.h \
	asm/siever-config.h lasieve-prepn.h input-poly.h asm/lasched.h \
	strategy.h
	$(CC) -c -DI_bits=$* -o $@ $<

gnfs-lasieve4gI%.o: gnfs-lasieve4g.c if.h primgen32.h asm/32bit.h redu2.h \
	recurrence6.h fbgen.h real-poly-aux.h gmp-aux.h asm/medsched.h \
	asm/siever-config.h lasieve-prepn.h input-poly.h asm/lasched.h \
	strategy.h
	$(CC) -c -DI_bits=$* -o $@ $<

libgmp-aux.a: gmp-aux.o mpz-ull.o
	$(AR) rcs $@ $^

lasieve-prepn.o: lasieve-prepn.h recurrence6.h

mpqs3.o: asm/mpqs-config.h

mpqs.o: mpqs.c asm/mpqs-config.h asm/siever-config.h
#	gcc -c -O2 -o $@ $<
	$(CC) -c -o $@ $<

mpqs3.o: mpqs3.c asm/mpqs-config.h asm/siever-config.h
#	gcc -c -O2 -o $@ $<
	$(CC) -c -o $@ $<

gnfs-lasieve4I%e: gnfs-lasieve4eI%.o if.o input-poly.o libgmp-aux.a redu2.o \
	recurrence6.o fbgen.o fbgen64.o real-poly-aux.o mpqs.o \
	primgen32.o lasieve-prepn.o pprime_p.o \
	strategy.o ecm.o mpqs3.o pm1.o \
	asm/liblasieve.a asm/liblasieveI%.a
	$(CC) -o $@ $^ $(GMP_LIB) -lm

gnfs-lasieve4I%f: gnfs-lasieve4fI%.o if.o input-poly-orig.o libgmp-aux.a redu2.o \
	recurrence6.o fbgen.o fbgen64.o real-poly-aux.o mpqs.o \
	primgen32.o lasieve-prepn.o pprime_p.o \
	strategy.o ecm.o mpqs3.o pm1.o \
	asm/liblasieve.a asm/liblasieveI%.a
	$(CC) -o $@ $^ $(GMP_LIB) -lm

gnfs-lasieve4I%g: gnfs-lasieve4gI%.o if.o input-poly-orig.o libgmp-aux.a redu2.o \
	recurrence6.o fbgen.o fbgen64.o real-poly-aux.o mpqs.o \
	primgen32.o primgen64.o lasieve-prepn.o pprime_p.o \
	strategy.o ecm.o mpqs3.o pm1.o td.o \
	asm/liblasieve.a asm/liblasieveI%.a
	$(CC) -o $@ $^ $(GMP_LIB) -lm

mpqsz.o: mpqs.c asm/mpqs-config.h
	$(CC) -O2 -DMPQS_STAT -DMPQS_ZEIT -c -o $@ $<
#	gcc -g -DMPQS_STAT -DMPQS_ZEIT -c -o $@ $<

mpqstest: mpqstest.o mpqsz.o if.o mpz-ull.o asm/liblasieve.a
	$(CC) -o $@ $^ $(GMP_LIB) -lm

mpqst: mpqst.o mpqsz.o if.o asm/liblasieve.a
	$(CC) -o $@ $^ $(GMP_LIB) -lm

mpqszt.o: mpqs.c  asm/mpqs-config.h
	$(CC) -O2 -DTOTAL_STAT -DMPQS_ZEIT -c -o $@ $<

tmpqs: mpqst.o mpqszt.o if.o asm/liblasieve.a
	$(CC) -o $@ $^ $(GMP_LIB) -lm

mpqs3z.o: mpqs3.c asm/mpqs-config.h
	$(CC) -O2 -DMPQS3_STAT -DMPQS3_ZEIT -c -o $@ $<
#	gcc -g -DMPQS3_STAT -DMPQS3_ZEIT -c -o $@ $<

mpqs3test: mpqs3test.o mpqs3z.o if.o libgmp-aux.a asm/liblasieve.a
	$(CC) -o $@ $^ $(GMP_LIB) -lm

mpqs3z2.o: mpqs3.c asm/mpqs-config2.h
	$(CC) -O2 -DMPQS3_STAT -DMPQS3_ZEIT -DVARIANT2 -c -o $@ $<
#	gcc -g -DMPQS3_STAT -DMPQS3_ZEIT -c -o $@ $<

mpqs3test2: mpqs3test.o mpqs3z2.o if.o libgmp-aux.a asm/liblasieve.a
	$(CC) -o $@ $^ $(GMP_LIB) -lm

mpqsstat: mpqsstat.o mpqs.o mpqs3.o if.o mpz-ull.o libgmp-aux.a \
	asm/liblasieve.a
	$(CC) -o $@ $^ $(GMP_LIB) -lm

ecmz.o: ecm.c asm/siever-config.h
	$(CC) -DECM_STAT -DECM_ZEIT -c -o $@ $<

ecmtest: ecmtest.o ecmz.o if.o asm/liblasieve.a
	$(CC) -o $@ $^ $(GMP_LIB) -lm

ecmstat: ecmstat.o ecmz.o if.o asm/liblasieve.a
	$(CC) -o $@ $^ $(GMP_LIB) -lm

pm1z.o: pm1.c asm/siever-config.h
	$(CC) -DPM1_STAT -DPM1_ZEIT -c -o $@ $<

pm1test: pm1test.o pm1z.o if.o asm/liblasieve.a
	$(CC) -o $@ $^ $(GMP_LIB) -lm

pm1stat: pm1stat.o pm1z.o if.o asm/liblasieve.a
	$(CC) -o $@ $^ $(GMP_LIB) -lm

lasieve5.tgz: Makefile paths INSTALL.and.USE COPYING $(SRCFILES) $(ASMFILES)
	tar cvO $^ | gzip --best --stdout > $@

clean:
	rm -f *.o *.a asm/*.o asm/*.a asm/*.s asm/*.S

realclean: clean
	rm -f gmp-aux.c gnfs-lasieve4e.c gnfs-lasieve4f.c gnfs-lasieve4g.c if.c input-poly.c la-cs.c lasieve-prepn.c mpz-ull.c primgen32.c primgen64.c recurrence6.c redu2.c strategy.c
	rm -f gmp-aux.h gnfs-lasieve4e.h gnfs-lasieve4f.h gnfs-lasieve4g.h if.h input-poly.h la-cs.h lasieve-prepn.h mpz-ull.h primgen32.h primgen64.h recurrence6.h redu2.h strategy.h
	rm -f asm/lasched.c asm/medsched.c asm/mpz-trialdiv.c asm/siever-config.c
	rm -f asm/lasched.h asm/medsched.h asm/mpz-trialdiv.h asm/siever-config.h

binclean: realclean
	rm -f gnfs-lasieve4I1* forumexs/*.out readmeex/*.gz
