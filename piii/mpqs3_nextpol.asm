# Copyright (C) 2002 Jens Franke, T.Kleinjung
# This file is part of gnfs4linux, distributed under the terms of the
# GNU General Public Licence and WITHOUT ANY WARRANTY.

# You should have received a copy of the GNU General Public License along
# with this program; see the file COPYING.  If not, write to the Free
# Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
# 02111-1307, USA.


.comm mpqs3_FB,4
.comm mpqs3_FB_start,4
.comm mpqs3_FB_disp,4
.comm mpqs3_2A_all_inv,4
.comm mpqs3_FB_np_p,4
.comm mpqs3_FB_np_b,4
.comm mpqs3_FB_np_sum,4
.comm mpqs3_FB_mm_inv,4
.comm mpqs3_FB_mm_16,4
.comm mpqs3_FB_mm_32,4
.comm mpqs3_FB_mm_48,4
.comm mpqs3_FB_mm_64,4
.comm mpqs3_FB_mm_80,4
.comm mpqs3_FB_mm_96,4
.comm mpqs3_FB_mm_112,4

# for (i=0; i<mpqs3_nFB; i++) {
#   p=fb[2*i];
#   mmi=mpqs3_FB_mm_inv[i];
#   pi=fbs[2*i]; bbb=fbs[2*i+1];
#   cc=bbb;
#   if (cc&1) cc+=p; cc>>=1;
#   cc=mpqs3_FB_disp[i]+(p-cc); if (cc>=p) cc-=p;
#   cc1=fb[2*i+1];
#   h32=cc1*pi;
#   MMREDUCE; cc1=h32;
#   if (cc1>=p) cc1-=p;
#   cc2=p-cc1;
#   cc1+=cc; if (cc1>=p) cc1-=p;
#   cc2+=cc; if (cc2>=p) cc2-=p;
#   fbs[2*i]=(ushort)cc1; fbs[2*i+1]=(ushort)cc2;
# }

# asm3_next_pol11(len)
function_head(asm3_next_pol11)
	pushl %ebx
	pushl %esi
	pushl %edi
	pushl %ebp
	movl 20(%esp),%ecx    # len
	movl $mpqs3_FB_disp,%edi
	movl $mpqs3_FB_np_p,%ebp
	movl $mpqs3_FB_mm_inv,%ebx
	movl $mpqs3_FB_start,%esi
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

# for (i=1; i<mpqs3_nFB; i++) {
#   p=fb[2*i];
#   mmi=mpqs3_FB_mm_inv[i];
#   cc=invptr[i];
#   cc*=bimul; h32=cc;
#   MMREDUCE; cc=h32; if (cc>=p) cc-=p;
#   ropptr[i]=(ushort)cc;
#   pi=fbs[2*i];
#   pi*=invptr[i]; h32=pi;
#   MMREDUCE; fbs[2*i]=(ushort)h32;
#   bbb=fbs[2*i+1]+cc; if (bbb>=p) bbb-=p; fbs[2*i+1]=bbb;
# }

# asm3_next_pol10(len,*invptr,*ropptr,bimul)
function_head(asm3_next_pol10)
	pushl %ebx
	pushl %esi
	pushl %edi
	pushl %ebp
	movl 20(%esp),%ecx    # len
	movl 28(%esp),%edi    # ropptr
	movl $mpqs3_FB_np_p,%ebp
	movl $mpqs3_FB_mm_inv,%ebx
	movl $mpqs3_FB_start,%esi
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


# for (i=0; i<mpqs3_nFB; i++) {
#   p=fb[2*i];
#   mpqs3_FB_np_sum[i]=0;
#   mmi=mpqs3_FB_mm_inv[i];
#   ptr16=(ushort *)(&prod_other);
#   bbb=0;
#   h32=(u32_t)(ptr16[0]); h32*=mpqs3_FB_mm_32[i];
#   MMREDUCE; bbb+=h32;
#   h32=(u32_t)(ptr16[1]); h32*=mpqs3_FB_mm_48[i];
#   MMREDUCE; bbb+=h32;
#   h32=(u32_t)(ptr16[2]); h32*=mpqs3_FB_mm_64[i];
#   MMREDUCE; bbb+=h32;
#   h32=(u32_t)(ptr16[3]); h32*=mpqs3_FB_mm_80[i];
#   MMREDUCE; bbb+=h32;
#   h32=(u32_t)(ptr24[4]); h32*=mpqs3_FB_mm_96[i];
#   MMREDUCE; bbb+=h32;
#   h32=(u32_t)(ptr24[5]); h32*=mpqs3_FB_mm_112[i];
#   MMREDUCE; bbb+=h32;
#   h32=bbb*(u32_t)(mpqs3_2A_all_inv[i]);
#   MMREDUCE; bbb=h32; if (bbb>=p) bbb-=p;
#   mpqs3_FB_np_b[i]=bbb;
# }

# asm3_next_pol0(len,*poptr)
function_head(asm3_next_pol0)
	pushl %ebx
	pushl %esi
	pushl %edi
	pushl %ebp
	movl 20(%esp),%ecx    # len
	movl $mpqs3_FB_np_b,%edi
	movl $mpqs3_FB_np_p,%ebp
	movl $mpqs3_FB_mm_inv,%ebx
	movl 24(%esp),%edx    # poptr
	movl $mpqs3_2A_all_inv,%esi
	movl $0x00010001,%eax
	movd %eax,%mm7
	psllq $32,%mm7
	movd %eax,%mm6
	paddw %mm6,%mm7    # 0x0001000100010001
	xorl %eax,%eax
np0_mainloop:
	movq (%ebp),%mm0     # p
	movq (%ebx),%mm2     # mm_inv

	movq (%edx),%mm3     # pr=poptr[0]
	movq mpqs3_FB_mm_32(%eax),%mm4  # m32
	movq %mm3,%mm6
	pmullw %mm4,%mm6     # low pr*m32
	pmulhuw %mm3,%mm4    # high pr*m32
	pmullw %mm2,%mm6     # h=low(pr*m32)*mm_inv
	pxor %mm5,%mm5
	pcmpeqw %mm6,%mm5    # 0xffff iff h=0
	pand %mm7,%mm5       # 0x0001 iff h=0
	pmulhuw %mm0,%mm6    # high h*p
	paddw %mm7,%mm4
	psubw %mm5,%mm4      # carry
	paddw %mm6,%mm4      # res
	movq %mm4,%mm1

	movq 8(%edx),%mm3     # pr=poptr[1]
	movq mpqs3_FB_mm_48(%eax),%mm4  # m48
	movq %mm3,%mm6
	pmullw %mm4,%mm6     # low pr*m48
	pmulhuw %mm3,%mm4    # high pr*m48
	pmullw %mm2,%mm6     # h=low(pr*m48)*mm_inv
	pxor %mm5,%mm5
	pcmpeqw %mm6,%mm5    # 0xffff iff h=0
	pand %mm7,%mm5       # 0x0001 iff h=0
	pmulhuw %mm0,%mm6    # high h*p
	paddw %mm7,%mm4
	psubw %mm5,%mm4      # carry
	paddw %mm6,%mm4      # res
	paddw %mm4,%mm1

	movq 16(%edx),%mm3     # pr=poptr[2]
	movq mpqs3_FB_mm_64(%eax),%mm4  # m64
	movq %mm3,%mm6
	pmullw %mm4,%mm6     # low pr*m64
	pmulhuw %mm3,%mm4    # high pr*m64
	pmullw %mm2,%mm6     # h=low(pr*m64)*mm_inv
	pxor %mm5,%mm5
	pcmpeqw %mm6,%mm5    # 0xffff iff h=0
	pand %mm7,%mm5       # 0x0001 iff h=0
	pmulhuw %mm0,%mm6    # high h*p
	paddw %mm7,%mm4
	psubw %mm5,%mm4      # carry
	paddw %mm6,%mm4      # res
	paddw %mm4,%mm1

	movq 24(%edx),%mm3     # pr=poptr[3]
	movq mpqs3_FB_mm_80(%eax),%mm4  # m80
	movq %mm3,%mm6
	pmullw %mm4,%mm6     # low pr*m80
	pmulhuw %mm3,%mm4    # high pr*m80
	pmullw %mm2,%mm6     # h=low(pr*m80)*mm_inv
	pxor %mm5,%mm5
	pcmpeqw %mm6,%mm5    # 0xffff iff h=0
	pand %mm7,%mm5       # 0x0001 iff h=0
	pmulhuw %mm0,%mm6    # high h*p
	paddw %mm7,%mm4
	psubw %mm5,%mm4      # carry
	paddw %mm6,%mm4      # res
	paddw %mm4,%mm1      # mm1 is at most 8p<2^16

# reduction if res>4p
	movq %mm0,%mm5
	movq %mm1,%mm4       # if res>4p subtract 4p:
	psllw $2,%mm5        # 4p
	pcmpgtw %mm5,%mm4    # 0xffff iff res>4p
	pand %mm5,%mm4       # 4p iff res>4p
	psubw %mm4,%mm1

	movq 32(%edx),%mm3     # pr=poptr[4]
	movq mpqs3_FB_mm_96(%eax),%mm4  # m96
	movq %mm3,%mm6
	pmullw %mm4,%mm6     # low pr*m96
	pmulhuw %mm3,%mm4    # high pr*m96
	pmullw %mm2,%mm6     # h=low(pr*m96)*mm_inv
	pxor %mm5,%mm5
	pcmpeqw %mm6,%mm5    # 0xffff iff h=0
	pand %mm7,%mm5       # 0x0001 iff h=0
	pmulhuw %mm0,%mm6    # high h*p
	paddw %mm7,%mm4
	psubw %mm5,%mm4      # carry
	paddw %mm6,%mm4      # res
	paddw %mm4,%mm1

	movq 40(%edx),%mm3     # pr=poptr[5]
	movq mpqs3_FB_mm_112(%eax),%mm4  # m112
	movq %mm3,%mm6
	pmullw %mm4,%mm6     # low pr*m112
	pmulhuw %mm3,%mm4    # high pr*m112
	pmullw %mm2,%mm6     # h=low(pr*m112)*mm_inv
	pxor %mm5,%mm5
	pcmpeqw %mm6,%mm5    # 0xffff iff h=0
	pand %mm7,%mm5       # 0x0001 iff h=0
	pmulhuw %mm0,%mm6    # high h*p
	paddw %mm7,%mm4
	psubw %mm5,%mm4      # carry
	paddw %mm6,%mm4      # res
	paddw %mm4,%mm1      # mm1 is at most 8p<2^16
# now: p in mm0, 2^32*prod_other mod p in mm1, mm_inv in mm2, 1 in mm7 

	movq (%esi),%mm3     # ai=2A_all_inv[i]
	movq %mm3,%mm6
	pmullw %mm1,%mm6     # low ai*res
	pmulhuw %mm3,%mm1    # high ai*res
	pmullw %mm2,%mm6     # h=low(ai*res)*mm_inv
	pxor %mm5,%mm5
	pcmpeqw %mm6,%mm5    # 0xffff iff h=0
	pand %mm7,%mm5       # 0x0001 iff h=0
	pmulhuw %mm0,%mm6    # high h*p
	paddw %mm7,%mm1
	psubw %mm5,%mm1      # carry
	paddw %mm6,%mm1      # res=2^16*prod_other*2A_all_inv[i] mod p

	movq %mm1,%mm4       # if >=p subtract p
	paddw %mm7,%mm4      # res+1
	pcmpgtw %mm0,%mm4    # 0xffff iff res>=p
	pand %mm0,%mm4       # p iff res>=p
	psubw %mm4,%mm1      # res mod p

	movq %mm1,(%edi)

	addl $8,%eax
	decl %ecx
	leal 8(%esi),%esi
	leal 8(%edi),%edi
	leal 16(%ebp),%ebp
	leal 8(%ebx),%ebx
	jnz np0_mainloop

	emms
	popl %ebp
	popl %edi
	popl %esi
	popl %ebx
	ret

# for (i=0; i<mpqs3_nFB; i++) {
#   p=fb[2*i]; mmi=mpqs3_FB_mm_inv[i];
#   cc=0;
#   h32=(u32_t)(ptr16[0]); h32*=mpqs3_FB_mm_16[i];
#   MMREDUCE; cc+=h32;
#   h32=(u32_t)(ptr16[1]); h32*=mpqs3_FB_mm_32[i];
#   MMREDUCE; cc+=h32;
#   h32=(u32_t)(ptr16[2]); h32*=mpqs3_FB_mm_48[i];
#   MMREDUCE; cc+=h32;
#   h32=(u32_t)(ptr16[3]); h32*=mpqs3_FB_mm_64[i];
#   MMREDUCE; cc+=h32;
#   h32=(u32_t)(ptr24[4]); h32*=mpqs3_FB_mm_80[i];
#   MMREDUCE; cc+=h32;
#   h32=(u32_t)(ptr24[5]); h32*=mpqs3_FB_mm_96[i];
#   MMREDUCE; cc+=h32;
#   h32=cc;
#   MMREDUCE;
#   mpqs3_FB_np_sum[i]+=(2*p-h32);
#   h32*=mpqs3_FB_np_b[i];
#   MMREDUCE; if (h32>=p) h32-=p;
#   cc=h32;
#   mpqs3_SI_add[j][i]=(ushort)cc;
# }


# asm3_next_pol1(len,*rop,B_i-ptr)
function_head(asm3_next_pol1)
	pushl %ebx
	pushl %esi
	pushl %edi
	pushl %ebp
	movl 20(%esp),%ecx    # len
	movl 24(%esp),%edi    # rop
	movl 28(%esp),%edx    # poptr
	movl $mpqs3_FB_np_p,%ebp
	movl $mpqs3_FB_mm_inv,%ebx
	movl $mpqs3_FB_np_b,%esi
	movl $0x00010001,%eax
	movd %eax,%mm7
	psllq $32,%mm7
	movd %eax,%mm6
	paddw %mm6,%mm7    # 0x0001000100010001
	xorl %eax,%eax

np1_mainloop:
	movq (%ebp),%mm0     # p
	movq (%ebx),%mm2     # mm_inv

	movq (%edx),%mm3     # pr=poptr[0]
	movq mpqs3_FB_mm_16(%eax),%mm4  # m16
	movq %mm3,%mm6
	pmullw %mm4,%mm6     # low pr*m16
	pmulhuw %mm3,%mm4    # high pr*m16
	pmullw %mm2,%mm6     # h=low(pr*m16)*mm_inv
	pxor %mm5,%mm5
	pcmpeqw %mm6,%mm5    # 0xffff iff h=0
	pand %mm7,%mm5       # 0x0001 iff h=0
	pmulhuw %mm0,%mm6    # high h*p
	paddw %mm7,%mm4
	psubw %mm5,%mm4      # carry
	paddw %mm6,%mm4      # res
	movq %mm4,%mm1

	movq 8(%edx),%mm3     # pr=poptr[1]
	movq mpqs3_FB_mm_32(%eax),%mm4  # m32
	movq %mm3,%mm6
	pmullw %mm4,%mm6     # low pr*m32
	pmulhuw %mm3,%mm4    # high pr*m32
	pmullw %mm2,%mm6     # h=low(pr*m32)*mm_inv
	pxor %mm5,%mm5
	pcmpeqw %mm6,%mm5    # 0xffff iff h=0
	pand %mm7,%mm5       # 0x0001 iff h=0
	pmulhuw %mm0,%mm6    # high h*p
	paddw %mm7,%mm4
	psubw %mm5,%mm4      # carry
	paddw %mm6,%mm4      # res
	paddw %mm4,%mm1

	movq 16(%edx),%mm3     # pr=poptr[2]
	movq mpqs3_FB_mm_48(%eax),%mm4  # m48
	movq %mm3,%mm6
	pmullw %mm4,%mm6     # low pr*m48
	pmulhuw %mm3,%mm4    # high pr*m48
	pmullw %mm2,%mm6     # h=low(pr*m48)*mm_inv
	pxor %mm5,%mm5
	pcmpeqw %mm6,%mm5    # 0xffff iff h=0
	pand %mm7,%mm5       # 0x0001 iff h=0
	pmulhuw %mm0,%mm6    # high h*p
	paddw %mm7,%mm4
	psubw %mm5,%mm4      # carry
	paddw %mm6,%mm4      # res
	paddw %mm4,%mm1

	movq 24(%edx),%mm3     # pr=poptr[3]
	movq mpqs3_FB_mm_64(%eax),%mm4  # m64
	movq %mm3,%mm6
	pmullw %mm4,%mm6     # low pr*m64
	pmulhuw %mm3,%mm4    # high pr*m64
	pmullw %mm2,%mm6     # h=low(pr*m64)*mm_inv
	pxor %mm5,%mm5
	pcmpeqw %mm6,%mm5    # 0xffff iff h=0
	pand %mm7,%mm5       # 0x0001 iff h=0
	pmulhuw %mm0,%mm6    # high h*p
	paddw %mm7,%mm4
	psubw %mm5,%mm4      # carry
	paddw %mm6,%mm4      # res
	paddw %mm4,%mm1

# reduction if res>4p
	movq %mm0,%mm5
	movq %mm1,%mm4       # if res>4p subtract 4p:
	psllw $2,%mm5        # 4p
	pcmpgtw %mm5,%mm4    # 0xffff iff res>4p
	pand %mm5,%mm4       # 4p iff res>4p
	psubw %mm4,%mm1

	movq 32(%edx),%mm3     # pr=poptr[4]
	movq mpqs3_FB_mm_80(%eax),%mm4  # m80
	movq %mm3,%mm6
	pmullw %mm4,%mm6     # low pr*m80
	pmulhuw %mm3,%mm4    # high pr*m80
	pmullw %mm2,%mm6     # h=low(pr*m80)*mm_inv
	pxor %mm5,%mm5
	pcmpeqw %mm6,%mm5    # 0xffff iff h=0
	pand %mm7,%mm5       # 0x0001 iff h=0
	pmulhuw %mm0,%mm6    # high h*p
	paddw %mm7,%mm4
	psubw %mm5,%mm4      # carry
	paddw %mm6,%mm4      # res
	paddw %mm4,%mm1

	movq 40(%edx),%mm3     # pr=poptr[5]
	movq mpqs3_FB_mm_96(%eax),%mm4  # m96
	movq %mm3,%mm6
	pmullw %mm4,%mm6     # low pr*m96
	pmulhuw %mm3,%mm4    # high pr*m96
	pmullw %mm2,%mm6     # h=low(pr*m96)*mm_inv
	pxor %mm5,%mm5
	pcmpeqw %mm6,%mm5    # 0xffff iff h=0
	pand %mm7,%mm5       # 0x0001 iff h=0
	pmulhuw %mm0,%mm6    # high h*p
	paddw %mm7,%mm4
	psubw %mm5,%mm4      # carry
	paddw %mm6,%mm4      # res
	paddw %mm4,%mm1      # mm1 is at most 8p<2^16
# now: p in mm0, 2^16*mpqs3_Bi[j] mod p in mm1, mm_inv in mm2, 1 in mm7 

	pmullw %mm2,%mm1     # h=mm1*mm_inv
	pxor %mm5,%mm5
	pcmpeqw %mm1,%mm5    # 0xffff iff h=0
	pand %mm7,%mm5       # 0x0001 iff h=0
	pmulhuw %mm0,%mm1    # high h*p
	psubw %mm7,%mm5      # -carry
	psubw %mm5,%mm1

	movq %mm1,%mm4       # if >=p subtract p
	paddw %mm7,%mm4      # res+1
	pcmpgtw %mm0,%mm4    # 0xffff iff res>=p
	pand %mm0,%mm4       # p iff res>=p
	psubw %mm4,%mm1      # res mod p

# mpqs3_FB_np_sum[i]+=(p-res)
	movq mpqs3_FB_np_sum(%eax),%mm3
	movq %mm0,%mm4
	psubw %mm1,%mm3
	paddw %mm4,%mm3
	movq %mm3,mpqs3_FB_np_sum(%eax)

	movq (%esi),%mm3     # b=FB_np_b[i]
	movq %mm3,%mm6
	pmullw %mm1,%mm6     # low b*res
	pmulhuw %mm3,%mm1    # high b*res
	pmullw %mm2,%mm6     # h=low(b*res)*mm_inv
	pxor %mm5,%mm5
	pcmpeqw %mm6,%mm5    # 0xffff iff h=0
	pand %mm7,%mm5       # 0x0001 iff h=0
	pmulhuw %mm0,%mm6    # high h*p
	paddw %mm7,%mm1
	psubw %mm5,%mm1      # carry
	paddw %mm6,%mm1      # res=mpqs3_Bi[j]*FB_np_b[i]/2^16 mod p

	movq %mm1,%mm4       # if >=p subtract p
	paddw %mm7,%mm4      # res+1
	pcmpgtw %mm0,%mm4    # 0xffff iff res>=p
	pand %mm0,%mm4       # p iff res>=p
	psubw %mm4,%mm1      # res mod p

	movq %mm1,(%edi)

	addl $8,%eax
	decl %ecx
	leal 8(%esi),%esi
	leal 8(%edi),%edi
	leal 16(%ebp),%ebp
	leal 8(%ebx),%ebx
	jnz np1_mainloop

	emms
	popl %ebp
	popl %edi
	popl %esi
	popl %ebx
	ret


# for (i=0; i<mpqs3_nFB; i++) {
#   p=fb[2*i]; mmi=mpqs3_FB_mm_inv[i];
#   cc=mpqs3_FB_np_sum[i];
#   bbb=mpqs3_FB_np_b[i];
#   if (bbb&1) bbb+=p;
#   bbb>>=1;
#   cc1=cc+fb[2*i+1]; cc2=cc+(p-fb[2*i+1]);
#   h32=cc1*bbb;
#   MMREDUCE; if (h32>=p) h32-=p;
#   cc1=h32+mpqs3_FB_disp[i]; if (cc1>=p) cc1-=p;
#   h32=cc2*bbb;
#   MMREDUCE; if (h32>=p) h32-=p;
#   cc2=h32+mpqs3_FB_disp[i]; if (cc2>=p) cc2-=p;
#   fbs[2*i]=(ushort)cc1; fbs[2*i+1]=(ushort)cc2;
# }

# asm3_next_pol2(len)
function_head(asm3_next_pol2)
	pushl %ebx
	pushl %esi
	pushl %edi
	pushl %ebp
	movl 20(%esp),%ecx    # len
	movl $mpqs3_FB_start,%edi
	movl $mpqs3_FB_np_p,%esi
	movl $mpqs3_FB_mm_inv,%ebx
	movl $mpqs3_FB_np_sum,%edx
	movl $mpqs3_FB_np_b,%ebp
	movl $0x00010001,%eax
	movd %eax,%mm7
	psllq $32,%mm7
	movd %eax,%mm6
	paddw %mm6,%mm7    # 0x0001000100010001
	movl $mpqs3_FB_disp,%eax

np2_mainloop:
	movq (%esi),%mm0     # p
	movq 8(%esi),%mm1    # sqrt
	movq (%ebp),%mm3     # b
	movq (%ebx),%mm2     # mm_inv
	leal 8(%ebx),%ebx
	movq %mm3,%mm4
	pand %mm7,%mm4       # b&1
	pcmpeqw %mm7,%mm4
	pand %mm0,%mm4
	paddw %mm4,%mm3      # b or b+p such that even
	psrlw $1,%mm3        # b=b/2 mod p
	movq (%edx),%mm5     # cc
	movq %mm0,%mm6
	psubw %mm1,%mm6      # p-sqrt
	paddw %mm5,%mm1      # cc1=cc+sqrt
	paddw %mm6,%mm5      # cc2=cc+(p-sqrt)

	movq %mm3,%mm6
	pmullw %mm1,%mm6     # low cc1*b
	pmulhuw %mm3,%mm1    # high cc1*b
	pmullw %mm2,%mm6     # h=low(cc1*b)*mm_inv
	pxor %mm4,%mm4
	pcmpeqw %mm6,%mm4    # 0xffff iff h=0
	pand %mm7,%mm4       # 0x0001 iff h=0
	pmulhuw %mm0,%mm6    # high h*p
	paddw %mm7,%mm1
	psubw %mm4,%mm1      # carry
	paddw %mm6,%mm1      # res1
	movq %mm1,%mm4       # if >=p subtract p
	paddw %mm7,%mm4      # res1+1
	pcmpgtw %mm0,%mm4    # 0xffff iff res1>=p
	pand %mm0,%mm4       # p iff res1>=p
	psubw %mm4,%mm1      # res1 mod p

	movq %mm3,%mm6
	pmullw %mm5,%mm6     # low cc2*b
	pmulhuw %mm3,%mm5    # high cc2*b
	pmullw %mm2,%mm6     # h=low(cc2*b)*mm_inv
	pxor %mm4,%mm4
	pcmpeqw %mm6,%mm4    # 0xffff iff h=0
	pand %mm7,%mm4       # 0x0001 iff h=0
	pmulhuw %mm0,%mm6    # high h*p
	paddw %mm7,%mm5
	psubw %mm4,%mm5      # carry
	paddw %mm6,%mm5      # res2
	movq %mm5,%mm4       # if >=p subtract p
	paddw %mm7,%mm4      # res2+1
	pcmpgtw %mm0,%mm4    # 0xffff iff res2>=p
	pand %mm0,%mm4       # p iff res2>=p
	psubw %mm4,%mm5      # res2 mod p

	movq (%eax),%mm4     # disp
	leal 8(%eax),%eax
	paddw %mm4,%mm1      # res1+=disp
	paddw %mm4,%mm5      # res2+=disp
	movq %mm7,%mm4
	movq %mm7,%mm6
	paddw %mm1,%mm4
	paddw %mm5,%mm6
	pcmpgtw %mm0,%mm4
	pcmpgtw %mm0,%mm6
	pand %mm0,%mm4
	pand %mm0,%mm6
	psubw %mm4,%mm1      # res1 mod p
	psubw %mm6,%mm5      # res2 mod p

	movq %mm1,%mm2
	movq %mm5,%mm3
	punpcklwd %mm3,%mm1
	punpckhwd %mm5,%mm2
	movq %mm1,(%edi)
	movq %mm2,8(%edi)

	decl %ecx
	leal 16(%esi),%esi
	leal 16(%edi),%edi
	leal 8(%ebp),%ebp
	leal 8(%edx),%edx
	jnz np2_mainloop

	emms
	popl %ebp
	popl %edi
	popl %esi
	popl %ebx
	ret


# asm3_next_pol3plus(len,*SI_add)
function_head(asm3_next_pol3plus)
	pushl %ebx
	pushl %esi
	pushl %edi
	pushl %ebp
	movl 20(%esp),%ecx    # len
	movl 24(%esp),%esi    # SI_add
	movl $mpqs3_FB_start,%edi
	movl $mpqs3_FB_np_p,%ebp
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


# asm3_next_pol3minus(len,*SI_add)
function_head(asm3_next_pol3minus)
	pushl %ebx
	pushl %esi
	pushl %edi
	pushl %ebp
	movl 20(%esp),%ecx    # len
	movl 24(%esp),%esi    # SI_add
	movl $mpqs3_FB_start,%edi
	movl $mpqs3_FB_np_p,%ebp
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
