# Copyright (C) 2002,2004 Jens Franke, T.Kleinjung
# This file is part of gnfs4linux, distributed under the terms of the
# GNU General Public Licence and WITHOUT ANY WARRANTY.

# You should have received a copy of the GNU General Public License along
# with this program; see the file COPYING.  If not, write to the Free
# Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
# 02111-1307, USA.

# The function we want to write.
# ulong asm_modinv32(x)
# Modular inverse of x modulo modulo32
# and y satisfies 0<y<x.

define(x,%edi)
define(y,%esi)
define(xc,%ecx)
define(yc,%ebx)
# Number of trial subtractions before doing a division
define(nts,26)

# %eax and %edx are used in the division.

dnl	.MACRO s1 k kc l lc
dnl	subl \k,\l
dnl	addl \kc,\lc
dnl	.ENDM

define(s1,`
	subl $1,$3
	addl $2,$4')dnl

dnl	.MACRO ts1 k kc l lc
dnl	cmpl \k,\l
dnl	setbe %al
dnl	decl %eax
dnl	movl %eax,%edx
dnl	andl \k,%edx
dnl	subl %edx,\l
dnl	andl \kc,%eax
dnl	addl %eax,\lc
dnl	.ENDM
define(ts1,`
	cmpl $1,$3
	setbe %al
	decl %eax
	movl %eax,%edx
	andl $1,%edx
	subl %edx,$3
	andl $2,%eax
	addl %eax,$4')dnl

.section	.rodata
.error_string:
	.string "Bad args to asm_modinv32\n"
.section	.data

function_head(asm_modinv32)
	pushl %ebx
	pushl %esi
	pushl %edi
# Get args from stack. Test their sanity.
	movl 16(%esp),x
	movl modulo32,y
	testl x,x
	jz badargs
	cmpl x,y
	jbe badargs
# Set xc and yc to their initial values.
	xorl yc,yc
	xorl xc,xc
	incl xc
	cmpl $1,x
	jbe have_inverse2
divide:

forloop(i,0,nts,`
	s1(x,xc,y,yc)
	cmpl x,y
	jb xlarger')dnl

	movl y,%eax
	xorl %edx,%edx
	divl x
	movl %edx,y
	mull xc
	addl %eax,yc

xlarger:
	cmpl $1,y
	jbe have_inverse1

forloop(i,0,nts,`
	s1(y,yc,x,xc)
	cmpl y,x
	jb ylarger')dnl

        movl x,%eax
	xorl %edx,%edx
	divl y
	movl %edx,x
	mull yc
	addl %eax,xc
ylarger:
	cmpl $1,x
	ja divide
have_inverse2:
	jne badargs
	movl xc,%eax
	popl %edi
	popl %esi
	popl %ebx
	ret
have_inverse1:
	jne badargs
	movl modulo32,%eax
	subl yc,%eax
	popl %edi
	popl %esi
	popl %ebx
	ret
badargs:
	pushl $.error_string
	call Schlendrian

