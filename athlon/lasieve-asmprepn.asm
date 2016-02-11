# Copyright (C) 2002 Jens Franke, T.Kleinjung
# This file is part of gnfs4linux, distributed under the terms of the
# GNU General Public Licence and WITHOUT ANY WARRANTY.

# You should have received a copy of the GNU General Public License along
# with this program; see the file COPYING.  If not, write to the Free
# Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
# 02111-1307, USA.


define(aux0,0(%esp))
define(aux1,4(%esp))
define(aux2,8(%esp))
define(r,12(%esp))
define(rr,16(%esp))
define(FB,40(%esp))
define(proots,44(%esp))
define(fbsz,48(%esp))
define(a0,52(%esp))
define(a1,56(%esp))
define(b0,60(%esp))
define(b1,64(%esp))
define(ri_ptr,68(%esp))

# %eax and %edx are used in the division.

# In general we have to calculate
#  ( +- a_1 + rb_1 ) / (+- a_0 - rb_0 ) modulo p.
# The signs of a_0 and a_1 depend on the lattice; for each choice we have
# a function asm_lasieve_mm_setup'i' , i=0,1,2,3.
#
# The calculation is done as follows:
# Let p be fixed and R(a)=a/2^32 mod p.
# We first compute num=R(+- a_1 + rb_1) and den=R(R(+- a_0 - rb_0)).
# For den!=0 the result is R(num*den^-1).
# If two successive prime ideals of the factor base lie over the same prime p
# we try to save one inversion using a trick of Montgomery (rarely one of the
# denominators is zero; in this case we do the two calculations seperately).
# R(a) is calculated as in Montgomery multiplication.


# case a0>=0, a1>=0

forloop(i,0,3,`
function_head(asm_lasieve_mm_setup`'i)
# asm_lasieve_mm_setup0(FB,proots,fbsz,absa0,b0_ul,absa1,b1_ul,ri_ptr)
	pushl %ebx
	fld1
	pushl %esi
	fld1
	pushl %edi
	fadd %st(1)
	pushl %ebp
	subl $20,%esp
	fdivrp
	xorl %ecx,%ecx
	movl %ecx,aux0
loop`'i:
	movl aux0,%ecx
	cmpl fbsz,%ecx
	jnc loop_end`'i   # rarely taken
	movl FB,%esi
	incl %ecx
	movl proots,%edi
	movl -4(%esi,%ecx,4),%ebx  # p
	movl %ecx,aux0
	movl -4(%edi,%ecx,4),%edx  # r
	movl %edx,r
	cmpl %ebx,%edx
	jz infprime`'i        # rarely taken
# now check whether i+1<fbsz, FB[i]==FB[i+1] and proots[i+1]!=FB[i+1]:
	cmpl fbsz,%ecx
	jz one_p`'i         # rarely taken
	movl (%esi,%ecx,4),%ebp  # next p
	cmpl %ebx,%ebp
	movl (%edi,%ecx,4),%edx  # next r
	movl %ebx,modulo32
	movl $mpqs_256_inv_table,%esi
	movl $0xff,%eax
	jnz one_p`'i`'a       # unpredictible
	cmpl %edx,%ebx
	jz one_p`'i`'a        # rarely taken
	movl %edx,rr
# now we have two regular pairs (p,r) and (p,rr)
# first compute mminv used for Montgomery multiplication
	andl %ebx,%eax
	shrl $1,%eax
	movzbl (%esi,%eax),%edi  # inv
	movl %ebx,%eax
	mull %edi
	andl $0xff00,%eax
	mull %edi
	subl %eax,%edi
	movl %ebx,%eax
	mull %edi
	andl $0xffff0000,%eax
	mull %edi
	subl %edi,%eax
	movl %eax,%ebp  # mminv

dnl case 0,1 now compute 2^64*((p-r)*b0+a0) mod p
dnl case 2,3 now compute 2^64*(r*b0+a0) mod p
ifelse(eval(i*(i-1)),0,`
	movl %ebx,%eax
	subl r,%eax',dnl p-r
`
	movl r,%eax'dnl r
)
	mull b0
	movl a0,%edi
	xorl %esi,%esi
	addl %eax,%edi
	adcl %edx,%esi
dnl case 0,1 esi:edi=(p-r)*b0+a0
dnl case 2,3 esi:edi=r*b0+a0
	movl %ebp,%eax
	mull %edi
	mull %ebx
	xorl %ecx,%ecx
	addl %eax,%edi
	adcl %edx,%esi
	cmpl %ebx,%esi
	cmovae %ebx,%ecx
	subl %ecx,%esi
dnl case 0,1 esi: 2^32*((p-r)*b0+a0) mod p
dnl case 2,3 esi: 2^32*(r*b0+a0) mod p
	movl %ebx,%eax
	jz gri`'i    # rarely taken
	movl %esi,%eax
	mull %ebp
	mull %ebx
	xorl %edi,%edi
	xorl %ecx,%ecx
	addl %eax,%esi
	adcl %edx,%edi
	cmpl %ebx,%edi
	cmovae %ebx,%ecx
	subl %ecx,%edi
dnl case 0,1 edi: 2^64*((p-r)*b0+a0) mod p
dnl case 2,3 edi: 2^64*(r*b0+a0) mod p
	movl %edi,aux1

dnl case 0,1 now compute 2^64*((p-rr)*b0+a0) mod p
dnl case 2,3 now compute 2^64*(rr*b0+a0) mod p
ifelse(eval(i*(i-1)),0,`
	movl %ebx,%eax
	subl rr,%eax',dnl p-rr
`
	movl rr,%eax'dnl rr
)
	mull b0
	movl a0,%edi
	xorl %esi,%esi
	addl %eax,%edi
	adcl %edx,%esi
dnl case 0,1 esi:edi=(p-rr)*b0+a0
dnl case 2,3 esi:edi=rr*b0+a0
	movl %ebp,%eax
	mull %edi
	mull %ebx
	xorl %ecx,%ecx
	addl %eax,%edi
	adcl %edx,%esi
	cmpl %ebx,%esi
	cmovae %ebx,%ecx
	subl %ecx,%esi
dnl case 0,1 esi: 2^32*((p-rr)*b0+a0) mod p
dnl case 2,3 esi: 2^32*(rr*b0+a0) mod p
	movl %ebx,%eax
	jz one_p`'i      # rarely taken, we skip processing two pairs
	movl %esi,%eax
	mull %ebp
	mull %ebx
	xorl %edi,%edi
	xorl %ecx,%ecx
	addl %eax,%esi
	adcl %edx,%edi
	cmpl %ebx,%edi
	cmovae %ebx,%ecx
	subl %ecx,%edi
dnl case 0,1 edi: 2^64*((p-rr)*b0+a0) mod p
dnl case 2,3 edi: 2^64*(rr*b0+a0) mod p
	movl %edi,aux2

# 2 inversions via Montgomerys trick (and Mont. mult.)
	movl aux1,%eax
	mull aux2
	movl %eax,%esi
	movl %edx,%edi
	mull %ebp
	mull %ebx
	xorl %ecx,%ecx
	addl %eax,%esi
	adcl %edx,%edi
	cmpl %ebx,%edi
	cmovae %ebx,%ecx
	subl %ecx,%edi # edi: 2^32*product
	pushl %edi
	call asm_modinv32

ifelse(eval(i*(i-3)),0,`
	movl %ebx,%ecx
	addl $4,%esp   # eax: 2^-32*inverse of product
	subl %eax,%ecx # ecx: -2^-32*inverse of product

	movl %ecx,%eax',`
	addl $4,%esp   # eax: 2^-32*inverse of product

	movl %eax,%ecx')

	mull aux2
	movl %eax,%esi
	movl %edx,%edi
	mull %ebp
	mull %ebx
	addl %eax,%esi
	adcl %edx,%edi
	xorl %esi,%esi
	movl aux1,%eax # first read old aux1 and start next mul
	mull %ecx
	cmpl %ebx,%edi   # do reduction mod p
	cmovae %ebx,%esi
	subl %esi,%edi   # inverse of aux1
	movl %edi,aux1 # end of delayed reduction
	movl %eax,%esi
	movl %edx,%edi
	mull %ebp
	mull %ebx
	xorl %ecx,%ecx
	addl %eax,%esi
	adcl %edx,%edi
	cmpl %ebx,%edi
	cmovae %ebx,%ecx
	subl %ecx,%edi   # inverse of aux2
	movl %edi,aux2

ifelse(eval(i*(i-2)),0,`
	movl %ebx,%eax
	subl rr,%eax # p-rr',`
	movl rr,%eax # rr')dnl

	mull b1
	movl a1,%edi
	xorl %esi,%esi
	addl %eax,%edi
	adcl %edx,%esi
dnl case 0,2 esi:edi=(p-rr)*b1+a1
dnl case 1,3 esi:edi=rr*b1+a1
	movl %ebp,%eax
	mull %edi
	mull %ebx
	xorl %ecx,%ecx
	addl %eax,%edi
	adcl %edx,%esi
dnl case 0,2 esi: 2^32*((p-rr)*b1+a1) mod p
dnl case 1,3 esi: 2^32*(rr*b1+a1) mod p

	movl aux2,%eax
	mull %esi
	movl %eax,%edi
	movl %edx,%esi
	mull %ebp
	mull %ebx
	xorl %ecx,%ecx
	addl %eax,%edi
	adcl %edx,%esi
	cmpl %ebx,%esi
	cmovae %ebx,%ecx
	subl %ecx,%esi
	movl %esi,aux2

ifelse(eval(i*(i-2)),0,`
	movl %ebx,%eax
	subl r,%eax # p-r',`
	movl r,%eax # r')dnl
	mull b1
	movl a1,%edi
	xorl %esi,%esi
	addl %eax,%edi
	adcl %edx,%esi
dnl case 0,2 esi:edi=(p-r)*b1+a1
dnl case 1,3 esi:edi=r*b1+a1
	movl %ebp,%eax
	mull %edi
	mull %ebx
	xorl %ecx,%ecx
	addl %eax,%edi
	adcl %edx,%esi
dnl case 0,2 esi: 2^32*((p-r)*b1+a1) mod p
dnl case 1,3 esi: 2^32*(r*b1+a1) mod p

	movl aux1,%eax
	mull %esi
	movl %eax,%edi
	movl %edx,%esi
	mull %ebp
	mull %ebx
	xorl %ecx,%ecx
	addl %eax,%edi
	adcl %edx,%esi
	cmpl %ebx,%esi
	cmovae %ebx,%ecx
	subl %ecx,%esi
	movl %esi,%eax

# apply get_recurrence_info
	movl aux2,%esi
	movl ri_ptr,%edi
	pushl %eax   # x
	pushl %ebx   # p
	pushl %edi   # ri_ptr
	call get_recurrence_info
	leal (%edi,%eax,4),%edi
	movl %esi,8(%esp)
	movl %ebx,4(%esp) # unnecessary if get_recurrence_info
			  # does not modify 8(%esp) 
	movl %edi,0(%esp)
	call get_recurrence_info
	addl $12,%esp
	leal (%edi,%eax,4),%eax
	movl aux0,%ecx
	movl %eax,ri_ptr
	incl %ecx
	movl %ecx,aux0
	jmp loop`'i

one_p`'i:
	movl $mpqs_256_inv_table,%esi
	movl %ebx,modulo32
	movl $0xff,%eax
one_p`'i`'a:
	andl %ebx,%eax
	shrl $1,%eax
	movzbl (%esi,%eax),%edi  # inv
	movl %ebx,%eax
	mull %edi
	andl $0xff00,%eax
	mull %edi
	subl %eax,%edi
	movl %ebx,%eax
	mull %edi
	andl $0xffff0000,%eax
	mull %edi
	subl %edi,%eax
	movl %eax,%ebp  # mminv

ifelse(eval(i*(i-1)),0,`
	movl %ebx,%eax
	subl r,%eax',dnl p-r
`
	movl r,%eax'dnl r
)
	mull b0
	movl a0,%edi
	xorl %esi,%esi
	addl %eax,%edi
	adcl %edx,%esi  # esi:edi=(p-r)*b0+a0
	movl %ebp,%eax
	mull %edi
	mull %ebx
	xorl %ecx,%ecx
	addl %eax,%edi
	adcl %edx,%esi
#	cmovc %ebx,%ecx
	cmpl %ebx,%esi
	cmovae %ebx,%ecx
	subl %ecx,%esi  # esi: 2^32*((p-r)*b0+a0) mod p
	movl %ebx,%eax
	jz gri`'i    # rarely taken
	movl %esi,%eax
	mull %ebp
	mull %ebx
	xorl %edi,%edi
	xorl %ecx,%ecx
	addl %eax,%esi
	adcl %edx,%edi
#	cmovc %ebx,%ecx
	cmpl %ebx,%edi
	cmovae %ebx,%ecx
	subl %ecx,%edi
dnl case 0,1 edi: 2^64*((p-r)*b0+a0) mod p
dnl case 2,3 edi: 2^64*(r*b0+a0) mod p
	pushl %edi
	call asm_modinv32
ifelse(eval(i*(i-3)),0,`
	movl %ebx,%edi
	addl $4,%esp
	subl %eax,%edi
	movl %edi,aux1',`
	addl $4,%esp
	movl %eax,aux1')
dnl case 0 -(2^64*((p-r)*b0+a0))^-1 mod p
dnl case 1  (2^64*((p-r)*b0+a0))^-1 mod p
dnl case 2  (2^64*(r*b0+a0))^-1 mod p
dnl case 3 -(2^64*(r*b0+a0))^-1 mod p

ifelse(eval(i*(i-2)),0,`
	movl %ebx,%eax
	subl r,%eax # p-r',`
	movl r,%eax # r')dnl
	mull b1
	movl a1,%edi
	xorl %esi,%esi
	addl %eax,%edi
	adcl %edx,%esi
dnl case 0,2 esi:edi=(p-r)*b1+a1
dnl case 1,3 esi:edi=r*b1+a1
	movl %ebp,%eax
	mull %edi
	mull %ebx
	xorl %ecx,%ecx
	addl %eax,%edi
	adcl %edx,%esi
dnl case 0,2 esi: 2^32*((p-r)*b1+a1) mod p
dnl case 1,3 esi: 2^32*(r*b1+a1) mod p

	movl aux1,%eax
	mull %esi
	movl %eax,%edi
	movl %edx,%esi
	mull %ebp
	mull %ebx
	xorl %ecx,%ecx
	addl %eax,%edi
	adcl %edx,%esi
#	cmovc %ebx,%ecx
	cmpl %ebx,%esi
	cmovae %ebx,%ecx
	subl %ecx,%esi
	movl %esi,%eax
gri`'i:

	movl ri_ptr,%edi
	pushl %eax   # x
	pushl %ebx   # p
	pushl %edi   # ri_ptr
	call get_recurrence_info
	addl $12,%esp
	leal (%edi,%eax,4),%eax
	movl %eax,ri_ptr
	jmp loop`'i
loop_end`'i:
	movl ri_ptr,%eax
	fistp aux0
	addl $20,%esp
	popl %ebp
	popl %edi
	popl %esi
	popl %ebx
	fincstp
	ret

infprime`'i:   # rare case, slow code
	movl b0,%eax
	xorl %edx,%edx
	divl %ebx
	testl %edx,%edx
	movl %ebx,modulo32
	jz gri`'i
	pushl %edx
	call asm_modinv32
	popl %edx        # result in eax
	movl %eax,%edi
	movl b1,%eax
	xorl %edx,%edx
	divl %ebx
	movl %edx,%eax
	mull %edi
	divl %ebx
	movl %ebx,%eax
	testl %edx,%edx
	cmovzl %ebx,%edx  # if edx=0: 0=p-p else p-edx
	subl %edx,%eax
	jmp gri`'i
')
