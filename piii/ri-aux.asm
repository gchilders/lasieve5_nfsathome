# Copyright (C) 2002,2004 Jens Franke, T.Kleinjung
# This file is part of gnfs4linux, distributed under the terms of the
# GNU General Public Licence and WITHOUT ANY WARRANTY.

# You should have received a copy of the GNU General Public License along
# with this program; see the file COPYING.  If not, write to the Free
# Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
# 02111-1307, USA.

# The function we want to write.
# ulong asm_getbc(x)
# Modular inverse of x modulo modulo32
# and y satisfies 0<y<x.

define(x,%edi)
define(y,%esi)
define(xc,%ecx)
define(yc,%ebx)
define(A,%ebp)
# Number of trial subtractions before doing a division
define(nts,26)

# %eax and %edx are used in the division.

define(s1,`
	subl $1,$3
	addl $2,$4')dnl

dnl Folgendes Makro wird nicht gebraucht:
define(ts1,`
	cmpl $1,$3
	setbe %al
	decl %eax
	movl %eax,%edx
	andl $1,%edx
	subl %edx,$3
	andl $2,%eax
	addl %eax,$4')dnl

function_head(asm_getbc)
	pushl %ebx
	pushl %esi
	pushl %edi
	pushl %ebp
# Get args from stack. Test their sanity.
# Set xc and yc to their initial values.
	movl 20(%esp),x
	xorl xc,xc
	movl 28(%esp),A
	xorl yc,yc
	movl 24(%esp),y
	incl xc
	cmpl x,A
	ja   have_bs
divide:

forloop(i,0,nts,`
	s1(x,xc,y,yc)
	cmpl x,y
	jb test_y')

	movl y,%eax
	xorl %edx,%edx
	divl x
	movl %edx,y
	mull xc
	addl %eax,yc
test_y:
	cmpl y,A
	ja have_ct

forloop(i,0,nts,`
	s1(y,yc,x,xc)
	cmpl y,x
	jb test_x')dnl

        movl x,%eax
	xorl %edx,%edx
	divl y
	movl %edx,x
	mull yc
	addl %eax,xc
test_x:
	cmpl x,A
	jbe divide

have_bs:
forloop(i,0,nts,`
	s1(x,xc,y,yc)
	cmpl y,A
	ja have_bsct')dnl

	movl y,%eax
	xorl %edx,%edx
	subl A,%eax
	divl x
	incl %eax
	movl %eax,A
	mull x
	subl %eax,y
	movl A,%eax
	mull xc
	addl %eax,yc
	jmp have_bsct
have_ct:
forloop(i,0,nts,`
	s1(y,yc,x,xc)
	cmpl x,A
	ja have_bsct')dnl

	movl x,%eax
	xorl %edx,%edx
	subl A,%eax
	divl y
	incl %eax
	movl %eax,A
	mull y
	subl %eax,x
	movl A,%eax
	mull yc
	addl %eax,xc
have_bsct:
	movl 32(%esp),%eax
	movl 36(%esp),%edx
	movl 40(%esp),%ebp
	movl x,(%eax)
	movl 44(%esp),%eax
	movl xc,(%edx)
	movl y,(%ebp)
	movl yc,(%eax)
	popl %ebp
	popl %edi
	popl %esi
	popl %ebx
	ret
