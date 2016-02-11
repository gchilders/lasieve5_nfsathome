
# Copyright (C) 2002 Jens Franke, T.Kleinjung
# This file is part of gnfs4linux, distributed under the terms of the
# GNU General Public Licence and WITHOUT ANY WARRANTY.

# You should have received a copy of the GNU General Public License along
# with this program; see the file COPYING.  If not, write to the Free
# Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
# 02111-1307, USA.


#  asm_re_strip(rowptr,m,dptr,ucmptr):
#
#  tab[0]=0ULL;
#  for (j=0,zz=1; j<4; j++,zz+=zz) {
#    if (dptr[j]==-1) tab[zz]=0ULL;
#    else tab[zz]=rowptr[dptr[j]];
#    for (k=1; k<zz; k++) tab[zz+k]=tab[k]^tab[zz];
#  }
#  for (t=0; t<m; t++)
#    rowptr[t]^=tab[ucmptr[t]];

define(`tab',%esi)dnl
define(`rowptr',160(%esp))dnl
define(`m',164(%esp))dnl
define(`dptr',168(%esp))dnl
define(`ucmptr',172(%esp))dnl
define(`d',%edx)dnl
define(`h',%ebx)dnl
define(`h0',%ecx)dnl
define(`row',%edi)dnl
define(`cnt',%ecx)dnl
define(`ucm',%eax)dnl
function_head(asm_re_strip)
	pushl %edi
	pushl %esi
	pushl %ebx
	pushl %ebp
	subl $140,%esp

	leal 4(%esp),tab
	movl tab,%eax
	andl $4,%eax
	addl %eax,tab   # 8 | tab
	pxor %mm0,%mm0
# fill tab:
	movq %mm0,(tab)

	movl dptr,h0
	movswl (h0),d
	movl rowptr,row
	leal (row,d,8),h
	addl $1,d
	cmovcl tab,h
	movq (h),%mm1   # row64[d[c0]+m*l] or 0
	movq %mm1,8(tab)

	movswl 2(h0),d
	leal (row,d,8),h
	addl $1,d
	cmovcl tab,h
	movq (h),%mm2   # row64[d[c0+1]+m*l] or 0
	movq %mm2,16(tab)
	movq %mm2,%mm3
	pxor %mm1,%mm3
	movq %mm3,24(tab)

	movswl 4(h0),d
	leal (row,d,8),h
	addl $1,d
	cmovcl tab,h
	movq (h),%mm4   # row64[d[c0+2]+m*l] or 0
	movq %mm4,32(tab)
	movq %mm4,%mm5
	movq %mm4,%mm6
	movq %mm4,%mm7
	pxor %mm1,%mm5
	pxor %mm2,%mm6
	pxor %mm3,%mm7
	movq %mm5,40(tab)
	movq %mm6,48(tab)
	movq %mm7,56(tab)

	movswl 6(h0),d
	leal (row,d,8),h
	addl $1,d
	cmovcl tab,h
	movq (h),%mm0   # row64[d[c0+3]+m*l] or 0
	pxor %mm0,%mm1
	movq %mm0,64(tab)
	movq %mm1,72(tab)
	pxor %mm0,%mm2
	pxor %mm0,%mm3
	movq %mm2,80(tab)
	movq %mm3,88(tab)
	pxor %mm0,%mm4
	pxor %mm0,%mm5
	movq %mm4,96(tab)
	movq %mm5,104(tab)
	pxor %mm0,%mm6
	pxor %mm0,%mm7
	movq %mm6,112(tab)
	movq %mm7,120(tab)
# apply to strip
	movl m,cnt
	movl ucmptr,ucm

re_loop:
	decl cnt
	movzbl (ucm),h
	movq (tab,h,8),%mm7
	leal 1(ucm),ucm
	pxor (row),%mm7
	movq %mm7,(row)
	leal 8(row),row
	jnz re_loop

	emms
	addl $140,%esp
	popl %ebp
	popl %ebx
	popl %esi
	popl %edi
	ret

