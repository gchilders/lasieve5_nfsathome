# Copyright (C) 2001,2002 Jens Franke
# This file is part of gnfs4linux, distributed under the terms of the 
# GNU General Public Licence and WITHOUT ANY WARRANTY.

# You should have received a copy of the GNU General Public License along
# with this program; see the file COPYING.  If not, write to the Free
# Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
# 02111-1307, USA.

CFLAGS= -O3
include ../paths

CC=gcc
CTANGLE=ctangle

SRCFILES=modinv32.c gcd32.c psp.c montgomery_mul.[ch] \
	basemath.c arith_noasm.c lasched.w medsched.w \
	Makefile siever-config32.w siever-config64.w 32bit.h \
	mpqs3arith.c mpqs-config.h zeit.c

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
	m4 -g -Dn_i_bits=0 ls-defs.asm $^ > $@

%.o: %.s
	cc -c $^

.SECONDARY:  *.s

.PHONY:	bup

montgomery_mul.o mpqs.o: siever-config.h ../if.h

liblasieve.a: modinv32.o gcd32.o psp.o montgomery_mul.o \
	basemath.o arith_noasm.o zeit.o
	ar rcs $@ $^

laschedI%.o: lasched.c lasched.h siever-config.h ../if.h
	$(CC) $(CFLAGS) -DI_bits=$* -c -o $@ $<

medschedI%.o: medsched.c medsched.h siever-config.h ../if.h
	$(CC) $(CFLAGS) -DI_bits=$* -c -o $@ $<

liblasieveI%.a:	laschedI%.o medschedI%.o
	ar rcs $@ $^

bup:
	echo $(SRCFILES)
