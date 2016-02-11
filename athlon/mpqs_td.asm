# Copyright (C) 2002 Jens Franke, T.Kleinjung
# This file is part of gnfs4linux, distributed under the terms of the
# GNU General Public Licence and WITHOUT ANY WARRANTY.

# You should have received a copy of the GNU General Public License along
# with this program; see the file COPYING.  If not, write to the Free
# Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
# 02111-1307, USA.

# Written by T. Kleinjung
# Modifications by J. Franke


.comm mpqs_sievearray,4
.comm mpqs_sievelen,4

define(fbptr,48(%esp))dnl
define(fbsptr,52(%esp))dnl
define(buffer,56(%esp))dnl
define(nr,60(%esp))dnl

define(byte1,4(%esp))dnl
define(byte2,5(%esp))dnl
define(byte3,6(%esp))dnl
define(byte4,7(%esp))dnl
define(byte5,8(%esp))dnl
define(byte6,9(%esp))dnl
define(byte7,10(%esp))dnl
define(byte8,11(%esp))dnl
define(pend,12(%esp))dnl
define(fbaux,16(%esp))dnl
define(fbsaux,20(%esp))dnl
define(s1aux,24(%esp))dnl
define(sv,%edx)dnl
define(svlen,%ebp)dnl
define(fb,%esi)dnl
define(fbs,%edi)dnl
define(p,%ecx)dnl
define(s1,%ebx)dnl
define(s1w,%bx)dnl
define(s2,%ebx)dnl
define(s3,%esi)dnl
define(iend,%edi)dnl


function_head(asm_tdsieve)
	pushl %edi
	pushl %esi
	pushl %ebx
	pushl %ebp
	subl $28,%esp

	movl fbptr,fb
	movl fbsptr,fbs
	movl fb,fbaux
	movl fbs,fbsaux
	movl mpqs_sievearray,sv
	movl mpqs_sievelen,svlen

	movl svlen,p
	shrl $2,p
	movl p,pend
tds4loop:
	movl fbaux,fb
	movzwl (fb),p
	cmpl pend,p
	jnc tds4loopend

	movl fbsaux,fbs
	leal 4(fb),fb
	movl fb,fbaux
	movzwl (fbs),s1
	movzwl 2(fbs),s3
	leal 4(fbs),fbs
	movl fbs,fbsaux
	movl s1,fbs
	cmpl s1,s3
	cmovcl s3,s1
	cmovcl fbs,s3    # now s1<s3
	movl svlen,iend
	subl p,iend
	subl p,iend
	subl p,iend

tds4innerloop:
	cmpl iend,s3
	jnc tds4innerloopend

	movb (sv,s1),%al
	addl p,s1
	movb %al,byte1
	movb %al,%ah
	movb (sv,s1),%al
	addl p,s1
	movb %al,byte2
	orb %al,%ah
	movb (sv,s1),%al
	addl p,s1
	movb %al,byte3
	orb %al,%ah
	movb (sv,s1),%al
	addl p,s1
	movb %al,byte4
	orb %al,%ah

	movb (sv,s3),%al
	addl p,s3
	movb %al,byte5
	orb %al,%ah
	movb (sv,s3),%al
	addl p,s3
	movb %al,byte6
	orb %al,%ah
	movb (sv,s3),%al
	addl p,s3
	movb %al,byte7
	orb %al,%ah
	movb (sv,s3),%al
	addl p,s3
	movb %al,byte8
	orb %al,%ah

	jz tds4innerloop
# compute mpqs_nFBk_1+i:
	movl s1,s1aux
	movl fbaux,s1
	subl fbptr,s1
	shrl $2,s1
	addl nr,s1
	movl buffer,p
# skip zeros in byte1-8:
	xorl sv,sv
	movb byte1,%al
	addb $0xff,%al
	adcl $0,sv
	movb byte2,%al
	movb %al,4(%esp,sv)
	addb $0xff,%al
	adcl $0,sv
	movb byte3,%al
	movb %al,4(%esp,sv)
	addb $0xff,%al
	adcl $0,sv
	movb byte4,%al
	movb %al,4(%esp,sv)
	addb $0xff,%al
	adcl $0,sv
	movb byte5,%al
	movb %al,4(%esp,sv)
	addb $0xff,%al
	adcl $0,sv
	movb byte6,%al
	movb %al,4(%esp,sv)
	addb $0xff,%al
	adcl $0,sv
	movb byte7,%al
	movb %al,4(%esp,sv)
	addb $0xff,%al
	adcl $0,sv
	movb byte8,%al
	movb %al,4(%esp,sv)
	addb $0xff,%al
	adcl $0,sv

# process entries
tds4store:
	movzbl 3(%esp,sv),%eax
	decl sv
	leal (p,%eax,4),svlen
	movl (svlen),%eax
	movw s1w,(%eax)
	leal 2(%eax),%eax
	movl %eax,(svlen)
	jnz tds4store

        movl fbaux,s1    # retrieve p and s1
        movzwl -4(s1),p
	movl s1aux,s1
	movl mpqs_sievearray,sv
	movl mpqs_sievelen,svlen
	jmp tds4innerloop

tds4innerloopend:
	leal (iend,p,2),iend
	xorl %eax,%eax
	movl %eax,byte1
	movl %eax,byte5
	cmpl iend,s3
	jnc tds4check2

	movb (sv,s1),%al
	addl p,s1
	movb %al,byte1
	movb %al,%ah
	movb (sv,s1),%al
	addl p,s1
	movb %al,byte2
	orb %al,%ah

	movb (sv,s3),%al
	addl p,s3
	movb %al,byte5
	orb %al,%ah
	movb (sv,s3),%al
	addl p,s3
	movb %al,byte6
	orb %al,%ah
tds4check2:
	cmpl svlen,s3
	jnc tds4check1

	movb (sv,s1),%al
	addl p,s1
	movb %al,byte3
	orb %al,%ah

	movb (sv,s3),%al
	addl p,s3
	movb %al,byte7
	orb %al,%ah
tds4check1:
	cmpl svlen,s1
	cmovncl svlen,s1
	movb (sv,s1),%al
	addl p,s1
	movb %al,byte4
	orb %al,%ah
	cmpl svlen,s3
	cmovncl svlen,s3
	movb (sv,s3),%al
	addl p,s3
	movb %al,byte8
	orb %al,%ah

	jz tds4loop
# compute mpqs_nFBk_1+i:
	movl fbaux,s1
	subl fbptr,s1
	shrl $2,s1
	addl nr,s1
	movl buffer,p
# skip zeros in byte1-8:
	xorl sv,sv
	movb byte1,%al
	addb $0xff,%al
	adcl $0,sv
	movb byte2,%al
	movb %al,4(%esp,sv)
	addb $0xff,%al
	adcl $0,sv
	movb byte3,%al
	movb %al,4(%esp,sv)
	addb $0xff,%al
	adcl $0,sv
	movb byte4,%al
	movb %al,4(%esp,sv)
	addb $0xff,%al
	adcl $0,sv
	movb byte5,%al
	movb %al,4(%esp,sv)
	addb $0xff,%al
	adcl $0,sv
	movb byte6,%al
	movb %al,4(%esp,sv)
	addb $0xff,%al
	adcl $0,sv
	movb byte7,%al
	movb %al,4(%esp,sv)
	addb $0xff,%al
	adcl $0,sv
	movb byte8,%al
	movb %al,4(%esp,sv)
	addb $0xff,%al
	adcl $0,sv

# process entries
tds4storex:
	movzbl 3(%esp,sv),%eax
	decl sv
	leal (p,%eax,4),svlen
	movl (svlen),%eax
	movw s1w,(%eax)
	leal 2(%eax),%eax
	movl %eax,(svlen)
	jnz tds4storex

	movl mpqs_sievearray,sv
	movl mpqs_sievelen,svlen
	jmp tds4loop

tds4loopend:
	movl fbsaux,fbs   # fb is ok

	movl svlen,%eax
	xorl %edx,%edx
	movl $3,s1
	divl s1
	movl %eax,pend
	movl mpqs_sievearray,sv   # sv is edx
tds3loop:
	movzwl (fb),p
	cmpl p,pend
	jc tds3loopend

	movzwl (fbs),s1
	leal 4(fb),fb
	movb (sv,s1),%al
	addl p,s1
	movb %al,byte1
	movb %al,%ah
	movb (sv,s1),%al
	addl p,s1
	movb %al,byte2
	orb %al,%ah
	movb (sv,s1),%al
	addl p,s1
	movb %al,byte3
	cmpl svlen,s1
	cmovncl svlen,s1
	orb %al,%ah
	movb (sv,s1),%al
	movzwl 2(fbs),s2
	movb %al,byte4
	orb %al,%ah

	movb (sv,s2),%al
	addl p,s2
	movb %al,byte5
	orb %al,%ah
	movb (sv,s2),%al
	addl p,s2
	movb %al,byte6
	orb %al,%ah
	movb (sv,s2),%al
	addl p,s2
	movb %al,byte7
	orb %al,%ah
	cmpl svlen,s2
	cmovncl svlen,s2
	movb (sv,s2),%al
	leal 4(fbs),fbs
	orb %al,%ah
	movb %al,byte8

	jz tds3loop
# compute mpqs_nFBk_1+i:
	movl fb,s1
	subl fbptr,s1
	shrl $2,s1
	addl nr,s1
	movl buffer,p
# skip zeros in byte1-8:
	xorl sv,sv
	movb byte1,%al
	addb $0xff,%al
	adcl $0,sv
	movb byte2,%al
	movb %al,4(%esp,sv)
	addb $0xff,%al
	adcl $0,sv
	movb byte3,%al
	movb %al,4(%esp,sv)
	addb $0xff,%al
	adcl $0,sv
	movb byte4,%al
	movb %al,4(%esp,sv)
	addb $0xff,%al
	adcl $0,sv
	movb byte5,%al
	movb %al,4(%esp,sv)
	addb $0xff,%al
	adcl $0,sv
	movb byte6,%al
	movb %al,4(%esp,sv)
	addb $0xff,%al
	adcl $0,sv
	movb byte7,%al
	movb %al,4(%esp,sv)
	addb $0xff,%al
	adcl $0,sv
	movb byte8,%al
	movb %al,4(%esp,sv)
	addb $0xff,%al
	adcl $0,sv

# process entries
tds3store:
	movzbl 3(%esp,sv),%eax
	decl sv
	leal (p,%eax,4),svlen
	movl (svlen),%eax
	movw s1w,(%eax)
	leal 2(%eax),%eax
	movl %eax,(svlen)
	jnz tds3store

	movl mpqs_sievearray,sv
	movl mpqs_sievelen,svlen
	jmp tds3loop

tds3loopend:

	movl svlen,p
	shrl $1,p
	movl p,pend
tds2loop:
	movzwl (fb),p
	cmpl pend,p
	jnc tds2loopend

	movzwl (fbs),s1
	leal 4(fb),fb
	movb (sv,s1),%al
	addl p,s1
	movb %al,byte1
	movb %al,%ah
	movb (sv,s1),%al
	addl p,s1
	movb %al,byte2
	cmpl svlen,s1
	cmovncl svlen,s1
	orb %al,%ah
	movb (sv,s1),%al
	movzwl 2(fbs),s2
	movb %al,byte3
	orb %al,%ah

	movb (sv,s2),%al
	addl p,s2
	movb %al,byte4
	orb %al,%ah
	movb (sv,s2),%al
	addl p,s2
	movb %al,byte5
	orb %al,%ah
	cmpl svlen,s2
	cmovncl svlen,s2
	movb (sv,s2),%al
	leal 4(fbs),fbs
	orb %al,%ah
	movb %al,byte6

	jz tds2loop
# compute mpqs_nFBk_1+i:
	movl fb,s1
	subl fbptr,s1
	shrl $2,s1
	addl nr,s1
	movl buffer,p
# skip zeros in byte1-6:
	xorl sv,sv
	movb byte1,%al
	addb $0xff,%al
	adcl $0,sv
	movb byte2,%al
	movb %al,4(%esp,sv)
	addb $0xff,%al
	adcl $0,sv
	movb byte3,%al
	movb %al,4(%esp,sv)
	addb $0xff,%al
	adcl $0,sv
	movb byte4,%al
	movb %al,4(%esp,sv)
	addb $0xff,%al
	adcl $0,sv
	movb byte5,%al
	movb %al,4(%esp,sv)
	addb $0xff,%al
	adcl $0,sv
	movb byte6,%al
	movb %al,4(%esp,sv)
	addb $0xff,%al
	adcl $0,sv

# process entries
tds2store:
	movzbl 3(%esp,sv),%eax
	decl sv
	leal (p,%eax,4),svlen
	movl (svlen),%eax
	movw s1w,(%eax)
	leal 2(%eax),%eax
	movl %eax,(svlen)
	jnz tds2store

	movl mpqs_sievearray,sv
	movl mpqs_sievelen,svlen
	jmp tds2loop

tds2loopend:


tds1loop:
	movzwl (fb),p
	cmpl svlen,p
	jnc tds1loopend

	movzwl (fbs),s1
	leal 4(fb),fb
	movb (sv,s1),%al
	addl p,s1
	movb %al,byte1
	cmpl svlen,s1
	cmovncl svlen,s1
	movb %al,%ah
	movb (sv,s1),%al
	movzwl 2(fbs),s2
	movb %al,byte2
	orb %al,%ah

	movb (sv,s2),%al
	addl p,s2
	movb %al,byte3
	orb %al,%ah
	cmpl svlen,s2
	cmovncl svlen,s2
	movb (sv,s2),%al
	leal 4(fbs),fbs
	orb %al,%ah
	movb %al,byte4

	jz tds1loop
# compute mpqs_nFBk_1+i:
	movl fb,s1
	subl fbptr,s1
	shrl $2,s1
	addl nr,s1
	movl buffer,p
# skip zeros in byte1-4:
	xorl sv,sv
	movb byte1,%al
	addb $0xff,%al
	adcl $0,sv
	movb byte2,%al
	movb %al,4(%esp,sv)
	addb $0xff,%al
	adcl $0,sv
	movb byte3,%al
	movb %al,4(%esp,sv)
	addb $0xff,%al
	adcl $0,sv
	movb byte4,%al
	movb %al,4(%esp,sv)
	addb $0xff,%al
	adcl $0,sv

# process entries
tds1store:
	movzbl 3(%esp,sv),%eax
	decl sv
	leal (p,%eax,4),svlen
	movl (svlen),%eax
	movw s1w,(%eax)
	leal 2(%eax),%eax
	movl %eax,(svlen)
	jnz tds1store

	movl mpqs_sievearray,sv
	movl mpqs_sievelen,svlen
	jmp tds1loop

tds1loopend:

tds0loop:
	movzwl (fb),p
	cmpl $0xffff,p
	jz tds0loopend

	movzwl (fbs),s1
	leal 4(fb),fb
	cmpl svlen,s1
	cmovncl svlen,s1
	movb (sv,s1),%al
	movzwl 2(fbs),s2
	movb %al,byte1
	movb %al,%ah

	cmpl svlen,s2
	cmovncl svlen,s2
	movb (sv,s2),%al
	leal 4(fbs),fbs
	orb %al,%ah
	movb %al,byte2

	jz tds0loop
# compute mpqs_nFBk_1+i:
	movl fb,s1
	subl fbptr,s1
	shrl $2,s1
	addl nr,s1
	movl buffer,p
# skip zeros in byte1-2:
	xorl sv,sv
	movb byte1,%al
	addb $0xff,%al
	adcl $0,sv
	movb byte2,%al
	movb %al,4(%esp,sv)
	addb $0xff,%al
	adcl $0,sv

# process entries
tds0store:
	movzbl 3(%esp,sv),%eax
	decl sv
	leal (p,%eax,4),svlen
	movl (svlen),%eax
	movw s1w,(%eax)
	leal 2(%eax),%eax
	movl %eax,(svlen)
	jnz tds0store

	movl mpqs_sievearray,sv
	movl mpqs_sievelen,svlen
	jmp tds0loop

tds0loopend:

	movl fbptr,fbs
	movl fb,%eax
	subl fbs,%eax
	shrl $1,%eax

	addl $28,%esp
	popl %ebp
	popl %ebx
	popl %esi
	popl %edi
	ret



define(relptr,40(%esp))dnl
define(minus,44(%esp))dnl
define(qx,48(%esp))dnl
define(ulqx,52(%esp))dnl


.comm mpqs_nFBk_1,2
.comm mpqs_td_begin,2
.comm mpqs_sievebegin,2
.comm mpqs_FB_inv_info,4
.comm mpqs_FB_start,4
.comm mpqs_256_inv_table,4
.comm mpqs_FB_inv,4
.comm stat_asm_div,4


# mm0: p,p
# mm1: inv,inv
# mm2: s1,s2
# mm3: ind,ind
# mm4: computing
# mm5: 0

function_head(asm_td)
	pushl %edi
	pushl %esi
	pushl %ebx
	pushl %ebp
	subl $20,%esp

	movl relptr,%ebp    # rel[i]
	movl (%ebp),%eax      # ind
	andl $0x0000ffff,%eax
	movl %eax,%ebx
	shll $16,%eax
	orl %ebx,%eax
	movd %eax,%mm3        # ind,ind
	psllq $32,%mm3
	movd %eax,%mm5
	paddd %mm5,%mm3        # ind,ind,ind,ind
	pxor %mm5,%mm5

#	movl $0,%edx
	movzwl 8(%ebp),%edx      # nr

#	movl $0,%ecx
	movzwl mpqs_td_begin,%ecx

	movl $mpqs_FB_inv_info,%esi
	movl $mpqs_FB_start,%edi

# prime mpqs_FB[1]
	movd 4(%esi),%mm0
	movd 12(%esi),%mm1
	movd 4(%edi),%mm2
	movq %mm0,%mm4
	psubw %mm2,%mm4
	paddw %mm3,%mm4        # ind+p-s1,ind+p-s2
	pmullw %mm1,%mm4
	pmulhw %mm0,%mm4
	pcmpeqw %mm5,%mm4
	movd %mm4,%eax
	orl $0,%eax
	jz loop2a
# found divisor mpqs_FB[1]
	movw mpqs_nFBk_1,%ax
	incw %ax
	movw %ax,10(%ebp,%edx,2)
	incl %edx

loop2a:
	leal 16(%esi),%esi
	leal 8(%edi),%edi
	movq (%esi),%mm0
	movq 8(%esi),%mm1
	movq (%edi),%mm2

loop2:
	subl $2,%ecx
	jz prod

	movq %mm0,%mm4
	psubw %mm2,%mm4
	paddw %mm3,%mm4        # ind+p-s1,ind+p-s2,ind+P-S1,ind+P-S2
	pmullw %mm1,%mm4
	movq 8(%edi),%mm2
	leal 16(%esi),%esi
	leal 8(%edi),%edi
	pmulhw %mm0,%mm4
	movq (%esi),%mm0
	movq 8(%esi),%mm1
	pcmpeqw %mm5,%mm4
	pmovmskb %mm4,%eax
	testl %eax,%eax
	jz loop2
	movw mpqs_nFBk_1,%bx
	addw mpqs_td_begin,%bx
	subw %cx,%bx
# found divisor
	testl $15,%eax
	jz testsecond

	movw %bx,10(%ebp,%edx,2)
	incl %edx
testsecond:
	testl $240,%eax
	jz loop2
	incw %bx
	movw %bx,10(%ebp,%edx,2)
	incl %edx
	jmp loop2

prod:
	movl $mpqs_FB,%esi
#	movl $0,%ebx
	movzwl mpqs_nFBk_1,%ebx
	addl %ebx,%ebx
	addl %ebx,%ebx
	subl %ebx,%esi
	movl $0,%ecx
	movl %edx,4(%esp)              # nr
	xorl %edx,%edx
	movl $1,%eax
	movl $0,%ebx
	movl %ebx,%edi
prodloop:
	addl %edi,%edx
	cmpl 4(%esp),%ecx
	jnc prodend
	movzwl 10(%ebp,%ecx,2),%ebx
	movl %eax,%edi
	movzwl (%esi,%ebx,4),%ebx
	movl %edx,%eax
	mull %ebx
	xchg %eax,%edi
	incl %ecx
	mull %ebx
	jmp prodloop
	
prodend:
	movl %eax,12(%esp)
	movl %edx,16(%esp)

	movl 4(%esp),%ebx          # nr
	movl minus,%eax
	testl $1,%eax
	jz positive
	movw $0,10(%ebp,%ebx,2)
	incl %ebx

positive:
	movl qx,%edi
	movl (%edi),%eax
	movl 4(%edi),%edx
posloop:
	testl $0x00000001,%eax
	jnz odd
	incl %ebx
	cmpl $27,%ebx
	jnc gotonext
	movw mpqs_nFBk_1,%cx
	movw %cx,8(%ebp,%ebx,2)
	shrl $1,%edx
	rcrl $1,%eax
	jmp posloop

odd:
	movw %bx,8(%ebp)

	cmpl $0,16(%esp)
	jnz division
	cmpl 12(%esp),%edx
	jnc gotonext

division:
	movl %eax,8(%esp)         # ax
	movl 12(%esp),%ebx         # ay
	movl %ebx,%edx
	movl $0,%ecx
	andl $0x000000ff,%edx
	shrl $1,%edx
	movl $mpqs_256_inv_table,%edi
	movb (%edi,%edx),%cl         # inv
	movl %ebx,%eax
	mull %ecx
	andl $0x0000ff00,%eax
	mull %ecx
	subl %eax,%ecx
	movl %ebx,%eax
	mull %ecx
	andl $0xffff0000,%eax
	mull %ecx
	subl %eax,%ecx

	movl 8(%esp),%eax
	mull %ecx

# trial divison of sieved primes
	movl $mpqs_FB_inv,%edi
#	movl $0,%ecx
	movzwl mpqs_nFBk_1,%ecx
	addl %ecx,%ecx
	addl %ecx,%ecx
	subl %ecx,%edi
	movl $0,%ecx
	movl 4(%esp),%edx
	movl %edx,(%esp)
	movl $0,%ebx
	movl %eax,8(%esp)
tdloop:
	movl 8(%esp),%eax
	cmpl $0,(%esp)
	jz tdend
	movl (%esp),%edx
	movzwl 8(%ebp,%edx,2),%ebx  # bx: ii
	decl (%esp)
	movzwl (%esi,%ebx,4),%ecx   # cx: p
	movl (%edi,%ebx,4),%edx  # edx: inv
	movl %edx,12(%esp)
divloop:
	mull %edx
	movl %eax,16(%esp)        # rr
	mull %ecx
	testl %edx,%edx
	jnz tdloop
	movw 8(%ebp),%dx
	cmpw $27,%dx
	jnc gotonext
	movw %bx,10(%ebp,%edx,2)
	incw 8(%ebp)
	movl 16(%esp),%eax
	movl 12(%esp),%edx
	movl %eax,8(%esp)
	jmp divloop


tdend:
# trial division of mpqs_FBk-primes
	cmpl $1,%eax
	jz end

	movl $mpqs_FBk_inv,%edi
#	movl $0,%ebx
	movl $mpqs_FBk,%esi
	xorl %ecx,%ecx
	movzwl mpqs_nFBk,%ebx
	incl %ebx
tdloopk:
	decl %ebx
	movl 8(%esp),%eax
	cmpl $0,%ebx
	jz tdendk
	movzwl -2(%esi,%ebx,2),%ecx   # cx: p
	movl -4(%edi,%ebx,4),%edx  # edx: inv
	movl %edx,12(%esp)
divloopk:
	mull %edx
	movl %eax,16(%esp)        # rr
	mull %ecx
	testl %edx,%edx
	jnz tdloopk
	movw 8(%ebp),%dx
	cmpw $27,%dx
	jnc gotonext
	movw %bx,10(%ebp,%edx,2)
	incw 8(%ebp)
	movl 16(%esp),%eax
	movl 12(%esp),%edx
	movl %eax,8(%esp)
	jmp divloopk

tdendk:
# trial division of mpqs_FB_Adiv-primes
	cmpl $1,%eax
	jz end

	movl $mpqs_FB_A_inv,%edi
	movl $0,%ecx
	movl $mpqs_Adiv_all,%esi
#	movl $0,%ebx
        movw mpqs_nFB,%cx
        addw mpqs_nFBk,%cx
	movzwl mpqs_nAdiv_total,%ebx
	incl %ebx
	movl %ecx,(%esp)           # mpqs_nFB+mpqs_nFBk
#	xorl %ecx,%ecx
tdloopa:
	decl %ebx
	movl 8(%esp),%eax
	cmpl $0,%ebx
	jz tdenda
	movzwl -2(%esi,%ebx,2),%ecx   # cx: p
	movl -4(%edi,%ebx,4),%edx  # edx: inv
	movl %edx,12(%esp)
divloopa:
	mull %edx
	movl %eax,16(%esp)        # rr
	mull %ecx
	testl %edx,%edx
	jnz tdloopa
	movw 8(%ebp),%dx
	cmpw $27,%dx
	jnc gotonext
	addl (%esp),%ebx
	movw %bx,10(%ebp,%edx,2)
	incw 8(%ebp)
	subl (%esp),%ebx
	movl 16(%esp),%eax
	movl 12(%esp),%edx
	movl %eax,8(%esp)
	jmp divloopa

tdenda:


end:
	movl 8(%esp),%eax
	movl ulqx,%edi
	movl %eax,(%edi)

	xorl %eax,%eax
	emms
	addl $20,%esp
	popl %ebp
	popl %ebx
	popl %esi
	popl %edi
	ret

gotonext:
	movl $1,%eax
	emms
	addl $20,%esp
	popl %ebp
	popl %ebx
	popl %esi
	popl %edi
	ret
# only used for debugging
dbg:
	addl $40,4(%esp)
	movl ulqx,%edi
	movl 8(%esp),%edx
	movl %edx,(%edi)
	jmp end
