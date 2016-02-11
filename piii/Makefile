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

SRCFILES=modinv1002.asm gcd32.c ri-aux.asm psp.c montgomery_mul.[ch] \
	basemath.c mpqs_eval.asm mpqs_td.asm mpqs_sieve.asm asm_arith64.asm \
	asm_arith96.asm asm_arith128.asm asm_arith160.asm asm_arith192.asm\
	sieve-from-sched.asm lasched.w medsched.w \
	64bit.h modmul64.c \
	ls-defs.asm lasched0.asm lasched1.asm lasched2.asm lasched3.asm \
	medsched0.asm Makefile siever-config.w 32bit.h search0.asm \
	mpz-trialdiv.w mpz-td.asm MMX-TD.c MMX-TD1.asm slinieG.asm \
	slinie3.asm slinie3A.asm slinie2.asm slinie2A.asm slinie1.asm \
	slinie1A.asm tdsieve-from-sched.asm tdslinie.asm tdslinie1.asm \
	tdslinie2.asm tdslinie3.asm \
	mpqs3_nextpol.asm mpqs3_sieve.asm mpqs3_td.asm mpqs3arith.c \
	mpqs_sieveinit.asm mpqs_gauss.asm mpqs_nextpol.asm mpqs-config.h \
	zeit.c lasieve-asmprepn.asm mpqs3_gauss.asm

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
	m4 -Dn_i_bits=0 ls-defs.asm $^ > $@

%.o: %.s
	cc -c $^

.SECONDARY:  *.s

.PHONY:	bup

montgomery_mul.o mpqs.o: siever-config.h ../if.h

liblasieve.a: modinv1002.o gcd32.o ri-aux.o psp.o montgomery_mul.o \
	basemath.o sieve-from-sched.o mpqs_eval.o mpqs_td.o mpqs_sieve.o \
	asm_arith64.o asm_arith96.o asm_arith128.o asm_arith160.o \
	asm_arith192.o MMX-TD.o MMX-TD1.o modmul64.o \
	tdsieve-from-sched.o mpz-trialdiv.o mpz-td.o zeit.o \
	mpqs_sieveinit.o mpqs_gauss.o lasieve-asmprepn.o mpqs_nextpol.o \
	mpqs3_nextpol.o mpqs3_td.o mpqs3_sieve.o mpqs3_gauss.o
	ar rcs $@ $^

laschedI%.o: lasched.c lasched.h siever-config.h ../if.h
	$(CC) $(CFLAGS) -DI_bits=$* -g -c -o $@ $<

lasched0I%.s: ls-defs.asm lasched0.asm
	m4 -Dn_i_bits=`expr $* - 1` $^ > $@

lasched1I%.s: ls-defs.asm lasched1.asm
	m4 -Dn_i_bits=`expr $* - 1` $^ > $@

lasched2I%.s: ls-defs.asm lasched2.asm
	m4 -Dn_i_bits=`expr $* - 1` $^ > $@

lasched3I%.s: ls-defs.asm lasched3.asm
	m4 -Dn_i_bits=`expr $* - 1` $^ > $@

medschedI%.o: medsched.c medsched.h siever-config.h ../if.h
	$(CC) $(CFLAGS) -DI_bits=$* -g -c -o $@ $<

medsched0I%.s: ls-defs.asm medsched0.asm
	m4 -Dn_i_bits=`expr $* - 1` $^ > $@

search0I%.s: ls-defs.asm search0.asm
	m4 -Dn_i_bits=`expr $* - 1` $^ > $@

slinieI%.s: ls-defs.asm slinieG.asm
	m4 -Dn_i_bits=`expr $* - 1` $^ > $@

slinie3I%.s: ls-defs.asm slinie3A.asm
	m4 -Dn_i_bits=`expr $* - 1` $^ > $@

slinie2I%.s: ls-defs.asm slinie2A.asm
	m4 -Dn_i_bits=`expr $* - 1` $^ > $@

slinie1I%.s: ls-defs.asm slinie1A.asm
	m4 -Dn_i_bits=`expr $* - 1` $^ > $@

tdslinie1I%.s: ls-defs.asm tdslinie1.asm
	m4 -Dn_i_bits=`expr $* - 1` $^ > $@

tdslinie2I%.s: ls-defs.asm tdslinie2.asm
	m4 -Dn_i_bits=`expr $* - 1` $^ > $@

tdslinie3I%.s: ls-defs.asm tdslinie3.asm
	m4 -Dn_i_bits=`expr $* - 1` $^ > $@

tdslinieI%.s: ls-defs.asm tdslinie.asm
	m4 -Dn_i_bits=`expr $* - 1` $^ > $@

liblasieveI%.a:	laschedI%.o lasched0I%.o lasched1I%.o lasched2I%.o \
	lasched3I%.o medschedI%.o medsched0I%.o slinieI%.o search0I%.o \
	slinie3I%.o slinie2I%.o slinie1I%.o tdslinie1I%.o tdslinie2I%.o \
	tdslinie3I%.o tdslinieI%.o
	ar rcs $@ $^

bup:
	echo $(SRCFILES)
