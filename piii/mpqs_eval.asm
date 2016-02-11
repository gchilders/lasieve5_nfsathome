# Copyright (C) 2002 Jens Franke, T.Kleinjung
# This file is part of gnfs4linux, distributed under the terms of the
# GNU General Public Licence and WITHOUT ANY WARRANTY.

# You should have received a copy of the GNU General Public License along
# with this program; see the file COPYING.  If not, write to the Free
# Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
# 02111-1307, USA.

# Written by T. Kleinjung

define(sv,16(%esp))dnl
define(svend,20(%esp))dnl
define(buffer,24(%esp))dnl
define(nmax,28(%esp))dnl

# asm_evaluate(sievebegin,sieveend,buffer,nmax):
# scans sievearray between sievebegin and sieveend for entries
# >127 and stores them in buffer (2 Bytes), stores at most nmax
# entries, returns number of stored entries

# edx: counts entries found so far
# esi: points to location of array we are investigating
# edi: points at end of array (=sieveend)
# mm7: 0
# mm0-3:
# ebx, ecx:

# Modified by J. Franke

function_head(asm_evaluate0)
	pushl %edi
	pushl %esi
	pushl %ebx


	movl sv,%esi
	movl svend,%edi
	movl buffer,%edx
	movl nmax,%ecx
	pxor %mm7,%mm7
	leal (%edx,%ecx,2),%ecx
	movl %ecx,nmax	
	jmp entry320

loop320:
	leal 32(%esi),%esi
	movq %mm7,-32(%esi)
	movq %mm7,-24(%esi)
	movq %mm7,-16(%esi)
	movq %mm7,-8(%esi)

entry320:
	cmpl %edi,%esi
	jz end0

	movq (%esi),%mm0
	movq 8(%esi),%mm1
	movq 16(%esi),%mm2
	movq 24(%esi),%mm3

	por %mm0,%mm1
	por %mm2,%mm3
	por %mm1,%mm3
	pmovmskb %mm3,%ecx
	testl %ecx,%ecx
	jz loop320

	movq 8(%esi),%mm1
	movq 24(%esi),%mm3
	pmovmskb %mm0,%eax
	pmovmskb %mm2,%ecx
	sall $16,%ecx
	pmovmskb %mm1,%ebx
	orl %ecx,%eax
	pmovmskb %mm3,%ecx
	sall $8,%ebx
	sall $24,%ecx
	orl %ebx,%eax
	subl sv,%esi
	orl %ecx,%eax
	xorl %ebx,%ebx
loop10:	
	bsfl %eax,%ecx
	addl %ecx,%ebx
	addl %ebx,%esi
	shrl %cl,%eax
	movw %si,(%edx)
	leal 2(%edx),%edx 
	subl %ebx,%esi
	incl %ebx
	shrl $1,%eax
	cmpl %edx,nmax
	jbe buffer_full0
	testl %eax,%eax
	jnz loop10
	addl sv,%esi
	jmp loop320

buffer_full0:
	addl sv,%esi
loop0320:
	cmpl %edi,%esi
	jz end0

	leal 32(%esi),%esi
	movq %mm7,-32(%esi)
	movq %mm7,-24(%esi)
	movq %mm7,-16(%esi)
	movq %mm7,-8(%esi)
	jmp loop0320

end0:
	movl %edx,%eax
	emms
	subl buffer,%eax
	popl %ebx
	popl %esi
	popl %edi
	shrl $1,%eax
	ret



function_head(asm_evaluate)
	pushl %edi
	pushl %esi
	pushl %ebx


	movl sv,%esi
	movl svend,%edi
	movl buffer,%edx
	movl nmax,%ecx
	pxor %mm7,%mm7
	leal (%edx,%ecx,2),%ecx
	movl %ecx,nmax	
	jmp entry32

loop32:
	leal 32(%esi),%esi

entry32:
	cmpl %edi,%esi
	jz end

	movq (%esi),%mm0
	movq 8(%esi),%mm1
	movq 16(%esi),%mm2
	movq 24(%esi),%mm3

	por %mm0,%mm1
	por %mm2,%mm3
	por %mm1,%mm3
	pmovmskb %mm3,%ecx
	testl %ecx,%ecx
	jz loop32

	movq 8(%esi),%mm1
	movq 24(%esi),%mm3
	pmovmskb %mm0,%eax
	pmovmskb %mm2,%ecx
	sall $16,%ecx
	pmovmskb %mm1,%ebx
	orl %ecx,%eax
	pmovmskb %mm3,%ecx
	sall $8,%ebx
	sall $24,%ecx
	orl %ebx,%eax
	subl sv,%esi
	orl %ecx,%eax
	xorl %ebx,%ebx
loop1:	
	bsfl %eax,%ecx
	addl %ecx,%ebx
	addl %ebx,%esi
	shrl %cl,%eax
	movw %si,(%edx)
	leal 2(%edx),%edx 
	subl %ebx,%esi
	incl %ebx
	shrl $1,%eax
	cmpl %edx,nmax
	jbe buffer_full
	testl %eax,%eax
	jnz loop1
	addl sv,%esi
	jmp loop32

buffer_full:
	addl sv,%esi
loop032:
	cmpl %edi,%esi
	jz end

	leal 32(%esi),%esi
	jmp loop032

end:
	movl %edx,%eax
	emms
	subl buffer,%eax
	popl %ebx
	popl %esi
	popl %edi
	shrl $1,%eax
	ret




