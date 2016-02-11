# Copyright (C) 2002 Jens Franke, T.Kleinjung
# This file is part of gnfs4linux, distributed under the terms of the
# GNU General Public Licence and WITHOUT ANY WARRANTY.

# You should have received a copy of the GNU General Public License along
# with this program; see the file COPYING.  If not, write to the Free
# Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
# 02111-1307, USA.


.comm mpqs_FB_start,4
.comm mpqs_FB_disp,4
.comm mpqs_FB_np_p,4
.comm mpqs_FB_mm_inv,4


# for (i=0; i<mpqs_nFB; i++) {
#   p=fb[2*i];
#   mmi=mpqs_FB_mm_inv[i];
#   pi=fbs[2*i]; bbb=fbs[2*i+1];
#   cc=bbb;
#   if (cc&1) cc+=p; cc>>=1;
#   cc=mpqs_FB_disp[i]+(p-cc); if (cc>=p) cc-=p;
#   cc1=fb[2*i+1];
#   h32=cc1*pi;
#   MMREDUCE; cc1=h32;
#   if (cc1>=p) cc1-=p;
#   cc2=p-cc1;
#   cc1+=cc; if (cc1>=p) cc1-=p;
#   cc2+=cc; if (cc2>=p) cc2-=p;
#   fbs[2*i]=(ushort)cc1; fbs[2*i+1]=(ushort)cc2;
# }

# asm_next_pol11(len)
function_head(asm_next_pol11)
	pushl %ebx
	pushl %esi
	pushl %edi
	pushl %ebp
	movl 20(%esp),%ecx    # len
	movl $mpqs_FB_disp,%edi
	movl $mpqs_FB_np_p,%ebp
	movl $mpqs_FB_mm_inv,%ebx
	movl $mpqs_FB_start,%esi
	movl $0x00010001,%eax
	movd %eax,%mm7
	psllq $32,%mm7
	movd %eax,%mm6
	paddw %mm6,%mm7    # 0x0001000100010001
np11_mainloop:
	movq (%ebp),%mm0     # p
	movq 8(%ebp),%mm1    # sqrt
	movq (%ebx),%mm2     # mm_inv
	movq (%esi),%mm3     # pi
	movq 8(%esi),%mm4    # cc

	movq %mm3,%mm6
	pmullw %mm1,%mm6     # low sqrt*cc1
	pmulhuw %mm1,%mm3    # high sqrt*cc1
	pmullw %mm2,%mm6     # h=low(sqrt*cc1)*mm_inv
	pxor %mm5,%mm5
	pcmpeqw %mm6,%mm5    # 0xffff iff h=0
	pand %mm7,%mm5       # 0x0001 iff h=0
	pmulhuw %mm0,%mm6    # high h*p
	paddw %mm7,%mm3
	psubw %mm5,%mm3      # carry
	paddw %mm6,%mm3      # res
	movq %mm3,%mm6       # if >=p subtract p
	paddw %mm7,%mm6      # res+1
	pcmpgtw %mm0,%mm6    # 0xffff iff res>=p
	pand %mm0,%mm6       # p iff res>=p
	psubw %mm6,%mm3      # res mod p = cc1

	movq %mm4,%mm5
	pand %mm7,%mm5       # 0x0001 iff cc odd
	pcmpeqw %mm7,%mm5    # 0xffff iff cc odd
	pand %mm0,%mm5       # p iff cc odd
	paddw %mm4,%mm5
	psrlw $1,%mm5        # cc/2 mod p = cc

	movq (%edi),%mm1     # disp
	movq %mm0,%mm4
	psubw %mm5,%mm4      # p-cc
	paddw %mm1,%mm4
	movq %mm4,%mm6       # if >=p subtract p
	paddw %mm7,%mm6      # res+1
	pcmpgtw %mm0,%mm6    # 0xffff iff res>=p
	pand %mm0,%mm6       # p iff res>=p
	psubw %mm6,%mm4      # res mod p = cc

	movq %mm0,%mm2
	psubw %mm3,%mm2      # p-cc1 = cc2

	paddw %mm4,%mm3
	movq %mm3,%mm6       # if >=p subtract p
	paddw %mm7,%mm6      # res+1
	pcmpgtw %mm0,%mm6    # 0xffff iff res>=p
	pand %mm0,%mm6       # p iff res>=p
	psubw %mm6,%mm3      # res mod p = cc1

	paddw %mm4,%mm2
	movq %mm2,%mm5       # if >=p subtract p
	paddw %mm7,%mm5      # res+1
	pcmpgtw %mm0,%mm5    # 0xffff iff res>=p
	pand %mm0,%mm5       # p iff res>=p
	psubw %mm5,%mm2      # res mod p = cc2

	movq %mm3,%mm4
	punpcklwd %mm2,%mm3
	punpckhwd %mm2,%mm4
	movq %mm3,(%esi)
	movq %mm4,8(%esi)

	decl %ecx
	leal 16(%esi),%esi
	leal 8(%edi),%edi
	leal 16(%ebp),%ebp
	leal 8(%ebx),%ebx
	jnz np11_mainloop

	emms
	popl %ebp
	popl %edi
	popl %esi
	popl %ebx
	ret

# for (i=1; i<mpqs_nFB; i++) {
#   p=fb[2*i];
#   mmi=mpqs_FB_mm_inv[i];
#   cc=invptr[i];
#   cc*=bimul; h32=cc;
#   MMREDUCE; cc=h32; if (cc>=p) cc-=p;
#   ropptr[i]=(ushort)cc;
#   pi=fbs[2*i];
#   pi*=invptr[i]; h32=pi;
#   MMREDUCE; fbs[2*i]=(ushort)h32;
#   bbb=fbs[2*i+1]+cc; if (bbb>=p) bbb-=p; fbs[2*i+1]=bbb;
# }

# asm_next_pol10(len,*invptr,*ropptr,bimul)
function_head(asm_next_pol10)
	pushl %ebx
	pushl %esi
	pushl %edi
	pushl %ebp
	movl 20(%esp),%ecx    # len
	movl 28(%esp),%edi    # ropptr
	movl $mpqs_FB_np_p,%ebp
	movl $mpqs_FB_mm_inv,%ebx
	movl $mpqs_FB_start,%esi
	movl $0x00010001,%eax
	movd %eax,%mm7
	psllq $32,%mm7
	movd %eax,%mm6
	xorl %edx,%edx
	mull 32(%esp)
	paddw %mm6,%mm7    # 0x0001000100010001
	movd %eax,%mm1
	psllq $32,%mm1
	movd %eax,%mm5
	paddw %mm5,%mm1    # bimul
	movl 24(%esp),%edx    # invptr
	xorl %eax,%eax
np10_mainloop:
	movq (%ebp),%mm0     # p
	movq (%ebx),%mm2     # mm_inv
	movq (%esi),%mm3     # pi
	movq (%edx),%mm4     # cc=invptr[i]

	movq %mm3,%mm6
	pmullw %mm4,%mm6     # low pi*cc
	pmulhuw %mm4,%mm3    # high pi*cc
	pmullw %mm2,%mm6     # h=low(pi*cc)*mm_inv
	pxor %mm5,%mm5
	pcmpeqw %mm6,%mm5    # 0xffff iff h=0
	pand %mm7,%mm5       # 0x0001 iff h=0
	pmulhuw %mm0,%mm6    # high h*p
	paddw %mm7,%mm3
	psubw %mm5,%mm3      # carry
	paddw %mm6,%mm3      # res
	movq %mm3,(%esi)

	movq %mm4,%mm6
	pmullw %mm1,%mm6     # low pi*cc
	pmulhuw %mm1,%mm4    # high pi*cc
	pmullw %mm2,%mm6     # h=low(pi*cc)*mm_inv
	pxor %mm5,%mm5
	pcmpeqw %mm6,%mm5    # 0xffff iff h=0
	pand %mm7,%mm5       # 0x0001 iff h=0
	pmulhuw %mm0,%mm6    # high h*p
	paddw %mm7,%mm4
	psubw %mm5,%mm4      # carry
	paddw %mm6,%mm4      # res
	movq %mm4,%mm6       # if >=p subtract p
	paddw %mm7,%mm6      # res+1
	pcmpgtw %mm0,%mm6    # 0xffff iff res>=p
	pand %mm0,%mm6       # p iff res>=p
	psubw %mm6,%mm4      # res mod p
	movq %mm4,(%edi)

	movq 8(%esi),%mm3    # fbs[2*i+1]
	paddw %mm4,%mm3      # fbs[2*i+1]+cc
	movq %mm3,%mm6       # if >=p subtract p
	paddw %mm7,%mm6      # res+1
	pcmpgtw %mm0,%mm6    # 0xffff iff res>=p
	pand %mm0,%mm6       # p iff res>=p
	psubw %mm6,%mm3      # res mod p
	movq %mm3,8(%esi)

	decl %ecx
	leal 16(%esi),%esi
	leal 8(%edi),%edi
	leal 8(%edx),%edx
	leal 16(%ebp),%ebp
	leal 8(%ebx),%ebx
	jnz np10_mainloop

	emms
	popl %ebp
	popl %edi
	popl %esi
	popl %ebx
	ret


# asm_next_pol3plus(len,*SI_add)
function_head(asm_next_pol3plus)
	pushl %ebx
	pushl %esi
	pushl %edi
	pushl %ebp
	movl 20(%esp),%ecx    # len
	movl 24(%esp),%esi    # SI_add
	movl $mpqs_FB_start,%edi
	movl $mpqs_FB_np_p,%ebp
	movl $0x00010001,%eax
	movd %eax,%mm7
	psllq $32,%mm7
	movd %eax,%mm6
	paddw %mm6,%mm7    # 0x0001000100010001

np3plus_mainloop:
	movq (%ebp),%mm2
	movq (%esi),%mm4
	movq %mm2,%mm0
	movq %mm2,%mm1
	punpcklwd %mm2,%mm0   # p0,p0,p1,p1
	punpckhwd %mm2,%mm1   # p2,p2,p3,p3
	movq %mm4,%mm2
	punpcklwd %mm4,%mm2   # a0,a0,a1,a1
	movq %mm4,%mm3
	punpckhwd %mm4,%mm3   # a2,a2,a3,a3

	movq (%edi),%mm4
	paddw %mm2,%mm4
	movq %mm7,%mm2
	paddw %mm4,%mm2
	pcmpgtw %mm0,%mm2
	pand %mm0,%mm2
	psubw %mm2,%mm4
	movq %mm4,(%edi)

	movq 8(%edi),%mm5
	paddw %mm3,%mm5
	movq %mm7,%mm3
	paddw %mm5,%mm3
	pcmpgtw %mm1,%mm3
	pand %mm1,%mm3
	psubw %mm3,%mm5
	movq %mm5,8(%edi)

	leal 16(%ebp),%ebp
	decl %ecx
	leal 8(%esi),%esi
	leal 16(%edi),%edi
	jnz np3plus_mainloop

	emms
	popl %ebp
	popl %edi
	popl %esi
	popl %ebx
	ret

# asm_next_pol3minus(len,*SI_add)
function_head(asm_next_pol3minus)
	pushl %ebx
	pushl %esi
	pushl %edi
	pushl %ebp
	movl 20(%esp),%ecx    # len
	movl 24(%esp),%esi    # SI_add
	movl $mpqs_FB_start,%edi
	movl $mpqs_FB_np_p,%ebp
	movl $0x00010001,%eax
	movd %eax,%mm7
	psllq $32,%mm7
	movd %eax,%mm6
	paddw %mm6,%mm7    # 0x0001000100010001

np3minus_mainloop:
	movq (%ebp),%mm2
	movq (%esi),%mm4
	movq %mm2,%mm0
	movq %mm2,%mm1
	punpcklwd %mm2,%mm0   # p0,p0,p1,p1
	punpckhwd %mm2,%mm1   # p2,p2,p3,p3
	movq %mm4,%mm2
	punpcklwd %mm4,%mm2   # a0,a0,a1,a1
	movq %mm4,%mm3
	punpckhwd %mm4,%mm3   # a2,a2,a3,a3

	movq (%edi),%mm4
	psubw %mm0,%mm2
	psubw %mm2,%mm4
	movq %mm7,%mm2
	paddw %mm4,%mm2
	pcmpgtw %mm0,%mm2
	pand %mm0,%mm2
	psubw %mm2,%mm4
	movq %mm4,(%edi)

	movq 8(%edi),%mm5
	psubw %mm1,%mm3
	psubw %mm3,%mm5
	movq %mm7,%mm3
	paddw %mm5,%mm3
	pcmpgtw %mm1,%mm3
	pand %mm1,%mm3
	psubw %mm3,%mm5
	movq %mm5,8(%edi)

	leal 16(%ebp),%ebp
	decl %ecx
	leal 8(%esi),%esi
	leal 16(%edi),%edi
	jnz np3minus_mainloop

	emms
	popl %ebp
	popl %edi
	popl %esi
	popl %ebx
	ret

