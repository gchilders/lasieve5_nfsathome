dnl Arithmetic for 192 Bit


.comm montgomery_modulo_n,4
.comm montgomery_inv_n,4

.text


dnl asm_zero192(a): a=0
function_head(asm_zero192)
	movl 4(%esp),%edx
	xorl %eax,%eax
	movl %eax,(%edx)
	movl %eax,4(%edx)
	movl %eax,8(%edx)
	movl %eax,12(%edx)
	movl %eax,16(%edx)
	movl %eax,20(%edx)
	ret

dnl asm_copy192(b,a): b=a
function_head(asm_copy192)
	movl 4(%esp),%edx
	movl 8(%esp),%ecx
	movl (%ecx),%eax
	movl %eax,(%edx)
	movl 4(%ecx),%eax
	movl %eax,4(%edx)
	movl 8(%ecx),%eax
	movl %eax,8(%edx)
	movl 12(%ecx),%eax
	movl %eax,12(%edx)
	movl 16(%ecx),%eax
	movl %eax,16(%edx)
	movl 20(%ecx),%eax
	movl %eax,20(%edx)
	ret

dnl asm_sub_n192(b,a): b-=a  mod 2^192
function_head(asm_sub_n192)
	movl 4(%esp),%edx
	movl 8(%esp),%ecx
	movl (%ecx),%eax
	subl %eax,(%edx)
	movl 4(%ecx),%eax
	sbbl %eax,4(%edx)
	movl 8(%ecx),%eax
	sbbl %eax,8(%edx)
	movl 12(%ecx),%eax
	sbbl %eax,12(%edx)
	movl 16(%ecx),%eax
	sbbl %eax,16(%edx)
	movl 20(%ecx),%eax
	sbbl %eax,20(%edx)
	ret

dnl asm_sub192_3(c,a,b): c=a-b mod N
function_head(asm_sub192_3)
	pushl %esi
	movl 12(%esp),%edx
	movl 16(%esp),%esi
	movl 8(%esp),%ecx
	movl (%edx),%eax
	subl (%esi),%eax
	movl %eax,(%ecx)
	movl 4(%edx),%eax
	sbbl 4(%esi),%eax
	movl %eax,4(%ecx)
	movl 8(%edx),%eax
	sbbl 8(%esi),%eax
	movl %eax,8(%ecx)
	movl 12(%edx),%eax
	sbbl 12(%esi),%eax
	movl %eax,12(%ecx)
	movl 16(%edx),%eax
	sbbl 16(%esi),%eax
	movl %eax,16(%ecx)
	movl 20(%edx),%eax
	sbbl 20(%esi),%eax
	movl %eax,20(%ecx)
	jnc sub_end
	movl montgomery_modulo_n,%edx
	movl (%edx),%eax
	addl %eax,(%ecx)
	movl 4(%edx),%eax
	adcl %eax,4(%ecx)
	movl 8(%edx),%eax
	adcl %eax,8(%ecx)
	movl 12(%edx),%eax
	adcl %eax,12(%ecx)
	movl 16(%edx),%eax
	adcl %eax,16(%ecx)
	movl 20(%edx),%eax
	adcl %eax,20(%ecx)
sub_end:
	popl %esi
	ret


dnl asm_half192(a): a/=2 mod N
function_head(asm_half192)
	movl 4(%esp),%ecx
	movl (%ecx),%eax
	testl $1,%eax
	jnz half_odd
dnl a is even
	movl 20(%ecx),%eax
	shrl $1,%eax
	movl %eax,20(%ecx)
	movl 16(%ecx),%eax
	rcrl $1,%eax
	movl %eax,16(%ecx)
	movl 12(%ecx),%eax
	rcrl $1,%eax
	movl %eax,12(%ecx)
	movl 8(%ecx),%eax
	rcrl $1,%eax
	movl %eax,8(%ecx)
	movl 4(%ecx),%eax
	rcrl $1,%eax
	movl %eax,4(%ecx)
	movl (%ecx),%eax
	rcrl $1,%eax
	movl %eax,(%ecx)
	ret
dnl a is odd, compute (a+N)/2
half_odd:
	pushl %esi
	movl montgomery_modulo_n,%esi
	movl (%esi),%eax
	addl %eax,(%ecx)
	movl 4(%esi),%eax
	adcl %eax,4(%ecx)
	movl 8(%esi),%eax
	adcl %eax,8(%ecx)
	movl 12(%esi),%eax
	adcl %eax,12(%ecx)
	movl 16(%esi),%eax
	adcl %eax,16(%ecx)
	movl 20(%esi),%eax
	adcl 20(%ecx),%eax
	rcrl $1,%eax
	movl %eax,20(%ecx)
	rcrl $1,16(%ecx)
	rcrl $1,12(%ecx)
	rcrl $1,8(%ecx)
	rcrl $1,4(%ecx)
	rcrl $1,(%ecx)

	popl %esi
	ret

dnl asm_diff192(c,a,b): c=|a-b|
function_head(asm_diff192)
	pushl %esi
	pushl %edi
	pushl %ebx
	movl 20(%esp),%edi
	movl 24(%esp),%esi
	movl 16(%esp),%ebx

	movl 20(%esi),%eax
	cmpl 20(%edi),%eax
	jc b_smaller_a
	jnz a_smaller_b
	movl 16(%esi),%eax
	cmpl 16(%edi),%eax
	jc b_smaller_a
	jnz a_smaller_b
	movl 12(%esi),%eax
	cmpl 12(%edi),%eax
	jc b_smaller_a
	jnz a_smaller_b
	movl 8(%esi),%eax
	cmpl 8(%edi),%eax
	jc b_smaller_a
	jnz a_smaller_b
	movl 4(%esi),%eax
	cmpl 4(%edi),%eax
	jc b_smaller_a
	jnz a_smaller_b
	movl (%esi),%eax
	cmpl (%edi),%eax
	jc b_smaller_a
	subl (%edi),%eax
	movl %eax,(%ebx)
	xorl %eax,%eax
	movl %eax,4(%ebx)
	movl %eax,8(%ebx)
	movl %eax,12(%ebx)
	movl %eax,16(%ebx)
	movl %eax,20(%ebx)
	jmp diff_end
a_smaller_b:
	movl (%esi),%eax
	subl (%edi),%eax
	movl %eax,(%ebx)
	movl 4(%esi),%eax
	sbbl 4(%edi),%eax
	movl %eax,4(%ebx)
	movl 8(%esi),%eax
	sbbl 8(%edi),%eax
	movl %eax,8(%ebx)
	movl 12(%esi),%eax
	sbbl 12(%edi),%eax
	movl %eax,12(%ebx)
	movl 16(%esi),%eax
	sbbl 16(%edi),%eax
	movl %eax,16(%ebx)
	movl 20(%esi),%eax
	sbbl 20(%edi),%eax
	movl %eax,20(%ebx)
	jmp diff_end
b_smaller_a:
	movl (%edi),%eax
	subl (%esi),%eax
	movl %eax,(%ebx)
	movl 4(%edi),%eax
	sbbl 4(%esi),%eax
	movl %eax,4(%ebx)
	movl 8(%edi),%eax
	sbbl 8(%esi),%eax
	movl %eax,8(%ebx)
	movl 12(%edi),%eax
	sbbl 12(%esi),%eax
	movl %eax,12(%ebx)
	movl 16(%edi),%eax
	sbbl 16(%esi),%eax
	movl %eax,16(%ebx)
	movl 20(%edi),%eax
	sbbl 20(%esi),%eax
	movl %eax,20(%ebx)
diff_end:
	popl %ebx
	popl %edi
	popl %esi
	ret

dnl asm_add192(b,a): b+=a mod N
function_head(asm_add192)
	pushl %esi
	pushl %edi
	movl 16(%esp),%esi
	movl 12(%esp),%edi
	movl (%esi),%eax
	addl %eax,(%edi)
	movl 4(%esi),%eax
	adcl %eax,4(%edi)
	movl 8(%esi),%eax
	adcl %eax,8(%edi)
	movl 12(%esi),%eax
	adcl %eax,12(%edi)
	movl 16(%esi),%eax
	adcl %eax,16(%edi)
	movl 20(%esi),%eax
	adcl %eax,20(%edi)

	movl montgomery_modulo_n,%esi
	jc sub
	movl 20(%esi),%eax
	cmpl 20(%edi),%eax
	jc sub
	jnz add_end
	movl 16(%esi),%eax
	cmpl 16(%edi),%eax
	jc sub
	jnz add_end
	movl 12(%esi),%eax
	cmpl 12(%edi),%eax
	jc sub
	jnz add_end
	movl 8(%esi),%eax
	cmpl 8(%edi),%eax
	jc sub
	jnz add_end
	movl 4(%esi),%eax
	cmpl 4(%edi),%eax
	jc sub
	jnz add_end
	movl (%esi),%eax
	cmpl %eax,(%edi)
	jc add_end

sub:
	movl (%esi),%eax
	subl %eax,(%edi)
	movl 4(%esi),%eax
	sbbl %eax,4(%edi)
	movl 8(%esi),%eax
	sbbl %eax,8(%edi)
	movl 12(%esi),%eax
	sbbl %eax,12(%edi)
	movl 16(%esi),%eax
	sbbl %eax,16(%edi)
	movl 20(%esi),%eax
	sbbl %eax,20(%edi)

#	jnc add_end
#	movl montgomery_modulo_n,%esi
#	movl (%esi),%eax
#	subl %eax,(%edi)
#	movl 4(%esi),%eax
#	sbbl %eax,4(%edi)
#	movl 8(%esi),%eax
#	sbbl %eax,8(%edi)
add_end:
	popl %edi
	popl %esi
	ret

dnl asm_add192_ui(b,a): b+=a mod N, a is ulong
function_head(asm_add192_ui)
	pushl %esi
	pushl %edi
	movl 12(%esp),%edi
	movl 16(%esp),%eax
	addl %eax,(%edi)
	adcl $0,4(%edi)
	adcl $0,8(%edi)
	adcl $0,12(%edi)
	adcl $0,16(%edi)
	adcl $0,20(%edi)
	jnc add_ui_end
	movl montgomery_modulo_n,%esi
	movl (%esi),%eax
	subl %eax,(%edi)
	movl 4(%esi),%eax
	sbbl %eax,4(%edi)
	movl 8(%esi),%eax
	sbbl %eax,8(%edi)
	movl 12(%esi),%eax
	sbbl %eax,12(%edi)
	movl 16(%esi),%eax
	sbbl %eax,16(%edi)
	movl 20(%esi),%eax
	sbbl %eax,20(%edi)
add_ui_end:
	popl %edi
	popl %esi
	ret

define(prod,60(%``''esp))dnl
define(f1,64(%``''esp))dnl
define(f2,68(%``''esp))dnl
define(tmp0,4(%``''esp))dnl
define(tmp1,8(%``''esp))dnl
define(tmp2,12(%``''esp))dnl
define(tmp3,16(%``''esp))dnl
define(tmp4,20(%``''esp))dnl
define(tmp5,24(%``''esp))dnl
define(tmp6,28(%``''esp))dnl


dnl asm_mulm192(c,a,b): c=a*b mont-mod N

function_head(asm_mulm192)
	pushl %esi
	pushl %edi
	pushl %ebx
	pushl %ebp
	subl $40,%esp

	movl $0,%ecx
	movl f1,%ebp
	movl %ecx,tmp0
	movl %ecx,tmp1
	movl %ecx,tmp2
	movl %ecx,tmp3
	movl %ecx,tmp4
	movl f2,%edx
	movl $0,%esi
	movl $0,%edi

mulloop:
	movl (%edx,%ecx,4),%ebx

	movl (%ebp),%eax
	mull %ebx
	 movl %esi,tmp6
	 movl %edi,tmp5
	 movl tmp0,%edi
	 movl $0,%esi
	addl %eax,%edi
	adcl %edx,%esi
	movl 4(%ebp),%eax

	mull %ebx
	 movl %edi,tmp0
	 addl tmp1,%esi
	 movl $0,%edi
	 adcl $0,%edi
	addl %eax,%esi
	adcl %edx,%edi
	movl 8(%ebp),%eax

	mull %ebx
	 movl %esi,tmp1
	 addl tmp2,%edi
	 movl $0,%esi
	 adcl $0,%esi
	addl %eax,%edi
	adcl %edx,%esi
	movl 12(%ebp),%eax

	mull %ebx
	 movl %edi,tmp2
	 addl tmp3,%esi
	 movl $0,%edi
	 adcl $0,%edi
	addl %eax,%esi
	adcl %edx,%edi
	movl 16(%ebp),%eax

	mull %ebx
	 movl %esi,tmp3
	 addl tmp4,%edi
	 movl $0,%esi
	 adcl $0,%esi
	addl %eax,%edi
	adcl %edx,%esi
	movl 20(%ebp),%eax

	mull %ebx
	 movl %edi,tmp4
	 addl tmp5,%esi
	 movl tmp6,%edi
	 adcl $0,%edi
	 movl tmp0,%ebx
	addl %eax,%esi
	adcl %edx,%edi

	movl montgomery_inv_n,%eax
	mull %ebx
	 movl %esi,tmp5
	 movl %edi,tmp6
	 movl montgomery_modulo_n,%ebp
	movl %eax,%ebx

	movl (%ebp),%eax
	mull %ebx
	 movl tmp0,%edi
	 movl $0,%esi
	addl %eax,%edi
	adcl %edx,%esi
	movl 4(%ebp),%eax

	mull %ebx
	 addl tmp1,%esi
	 movl $0,%edi
	 adcl $0,%edi
        addl %eax,%esi
	adcl %edx,%edi
	movl 8(%ebp),%eax

	mull %ebx
	 movl %esi,tmp0
	 addl tmp2,%edi
	 movl $0,%esi
	 adcl $0,%esi
        addl %eax,%edi
	adcl %edx,%esi
	movl 12(%ebp),%eax

	mull %ebx
	 movl %edi,tmp1
	 addl tmp3,%esi
	 movl $0,%edi
	 adcl $0,%edi
        addl %eax,%esi
	adcl %edx,%edi
	movl 16(%ebp),%eax

	mull %ebx
	 movl %esi,tmp2
	 addl tmp4,%edi
	 movl $0,%esi
	 adcl $0,%esi
        addl %eax,%edi
	adcl %edx,%esi
	movl 20(%ebp),%eax

	mull %ebx
	 movl %edi,tmp3
	 addl tmp5,%esi
	 movl tmp6,%edi
	 adcl $0,%edi
	 movl f1,%ebp

	addl %eax,%esi
	adcl %edx,%edi
	movl %esi,tmp4
	movl $0,%esi
	adcl $0,%esi

	incl %ecx
	cmpl $6,%ecx
	movl f2,%edx
	jnz mulloop
mllend:
			# now tmp5 in edi, tmp6 in esi
        movl montgomery_modulo_n,%ebp
        movl prod,%edx

        movl tmp0,%eax
	movl %eax,(%edx)
        subl (%ebp),%eax
        movl tmp1,%eax
	movl %eax,4(%edx)
        sbbl 4(%ebp),%eax
        movl tmp2,%eax
	movl %eax,8(%edx)
        sbbl 8(%ebp),%eax
	movl tmp3,%ebx
	movl %ebx,12(%edx)
	sbbl 12(%ebp),%ebx
	movl tmp4,%ecx
	movl %ecx,16(%edx)
	sbbl 16(%ebp),%ecx
	movl %edi,20(%edx)
	sbbl 20(%ebp),%edi
	sbbl $0,%esi
	jc nosub

	movl %eax,8(%edx)
	movl %ebx,12(%edx)
	movl %ecx,16(%edx)
	movl %edi,20(%edx)
        movl tmp0,%eax
        subl (%ebp),%eax
	movl %eax,(%edx)
        movl tmp1,%eax
        sbbl 4(%ebp),%eax
	movl %eax,4(%edx)
nosub:
	addl $40,%esp
	popl %ebp
	popl %ebx
	popl %edi
	popl %esi
	ret

.IF 1
dnl  inversion

define(res,128(%``''esp))dnl
define(b,132(%``''esp))dnl
define(t10,4(%``''esp))dnl
define(t11,8(%``''esp))dnl
define(t12,12(%``''esp))dnl
define(t13,16(%``''esp))dnl
define(t14,20(%``''esp))dnl
define(t15,24(%``''esp))dnl
define(t20,28(%``''esp))dnl
define(t21,32(%``''esp))dnl
define(t22,36(%``''esp))dnl
define(t23,40(%``''esp))dnl
define(t24,44(%``''esp))dnl
define(t25,48(%``''esp))dnl
define(v10,52(%``''esp))dnl
define(v11,56(%``''esp))dnl
define(v12,60(%``''esp))dnl
define(v13,64(%``''esp))dnl
define(v14,68(%``''esp))dnl
define(v15,72(%``''esp))dnl
define(v20,76(%``''esp))dnl
define(v21,80(%``''esp))dnl
define(v22,84(%``''esp))dnl
define(v23,88(%``''esp))dnl
define(v24,92(%``''esp))dnl
define(v25,96(%``''esp))dnl


.comm montgomery_inv_shift_table,64
.comm montgomery_inv_add_table,4

.text
dnl asm_inv192(res,b)
function_head(asm_inv192)
	pushl %esi
	pushl %edi
	pushl %ebx
	pushl %ebp
	subl $108,%esp

	movl $64,%ecx
	xorl %eax,%eax
	movd %ecx,%mm7
	movl %eax,t21
	movl %eax,t22
	movl %eax,t23
	movl %eax,t24
	movl %eax,t25
	movl %eax,v20
	movl %eax,v21
	movl %eax,v22
	movl %eax,v23
	movl %eax,v24
	movl %eax,v25
	incl %eax
	movl %eax,t20    # t2=1, v2=0
	movl montgomery_modulo_n,%ebp
	movl b,%esi
	movl (%esi),%ebx    # b[0]
	andl $1,%ebx        # flag for jmp below
	movl (%ebp),%eax
	movl %eax,v10
	movl 4(%ebp),%ecx
	movl %ecx,v11
	movl 8(%ebp),%eax
	movl %eax,v12
	movl 12(%ebp),%eax
	movl %eax,v13
	movl 16(%ebp),%eax
	movl %eax,v14
	movl 20(%ebp),%eax
	movl %eax,v15    # v1=N
	jz inv_beven192
	movl (%esi),%eax
	movl %eax,t10
	movl 4(%esi),%ecx
	movl %ecx,t11
	movl 8(%esi),%eax
	movl %eax,t12
	movl 12(%esi),%eax
	movl %eax,t13
	movl 16(%esi),%eax
	movl %eax,t14
	movl 20(%esi),%eax
	movl %eax,t15     # t1=b
	jmp inv_while_loop192
.align 16
inv_beven192:
	movl (%ebp),%ecx
	subl (%esi),%ecx
	movl %ecx,t10
	movl 4(%ebp),%eax
	sbbl 4(%esi),%eax
	movl %eax,t11
	movl 8(%ebp),%ecx
	sbbl 8(%esi),%ecx
	movl %ecx,t12
	movl 12(%ebp),%ecx
	sbbl 12(%esi),%ecx
	movl %ecx,t13
	movl 16(%ebp),%ecx
	sbbl 16(%esi),%ecx
	movl %ecx,t14
	movl 20(%ebp),%ecx
	sbbl 20(%esi),%ecx
	movl %ecx,t15     # t1=N-b

inv_while_loop192:
	movl t10,%eax
	subl v10,%eax
	movl t11,%edi
	sbbl v11,%edi
	movl t12,%esi
	sbbl v12,%esi
	movl t13,%ecx
	sbbl v13,%ecx
	movl t14,%ebx
	sbbl v14,%ebx
	movl t15,%eax
	sbbl v15,%eax

	jc inv_v1bigger192
	orl %eax,%edi
	movl t10,%eax
	subl v10,%eax
	orl %esi,%ecx
	orl %edi,%ecx
	orl %ebx,%ecx
	orl %eax,%edi
	jz inv_while_loop_end192   # t1=v1
	leal t10,%esi
	leal v10,%edi
	jmp inv_sub192
inv_v1bigger192:
	leal v10,%esi
	leal t10,%edi
inv_sub192:                     # (esi)1 > (edi)1
	movl (%edi),%eax
	subl %eax,(%esi)
	movl 4(%edi),%ecx
	sbbl %ecx,4(%esi)
	movl 8(%edi),%eax
	sbbl %eax,8(%esi)
	movl 12(%edi),%ecx
	sbbl %ecx,12(%esi)
	movl 16(%edi),%eax
	sbbl %eax,16(%esi)
	movl 20(%edi),%eax
	sbbl %eax,20(%esi)    # s1-=d1
	movl 24(%edi),%ecx
	subl %ecx,24(%esi)
	movl 28(%edi),%eax
	sbbl %eax,28(%esi)
	movl 32(%edi),%ecx
	sbbl %ecx,32(%esi)
	movl 36(%edi),%eax
	sbbl %eax,36(%esi)
	movl 40(%edi),%ecx
	sbbl %ecx,40(%esi)
	movl 44(%edi),%ecx
	sbbl %ecx,44(%esi)    # s2-=d2
	jnc inv_no_add_N192
	movl (%ebp),%eax
	addl %eax,24(%esi)
	movl 4(%ebp),%ecx
	adcl %ecx,28(%esi)
	movl 8(%ebp),%eax
	adcl %eax,32(%esi)
	movl 12(%ebp),%ecx
	adcl %ecx,36(%esi)
	movl 16(%ebp),%eax
	adcl %eax,40(%esi)
	movl 20(%ebp),%ecx
	adcl %ecx,44(%esi)    # if s2<0: s2+=N
inv_no_add_N192:
	movl $montgomery_inv_shift_table,%edi
inv_shift_while_loop192:
	movl (%esi),%eax
	andl $0x0f,%eax
	movl (%edi,%eax,4),%ecx    # shift
	movl $1,%eax
	shll %cl,%eax
	movd %ecx,%mm6
	movq %mm7,%mm5
	movl %eax,%ebp
	decl %eax
	psubd %mm6,%mm5         # 64-shift
	andl 24(%esi),%eax         # t
	addl %eax,%ebp             # (1<<s)+t

.IF 0
	movq 12(%esi),%mm3
	movq 8(%esi),%mm2
	psrlq %mm6,%mm3
	movq (%esi),%mm0
	movq %mm2,%mm1
	psllq %mm5,%mm2
	psrlq %mm6,%mm0
	psrlq %mm6,%mm1
	movq %mm3,12(%esi)
	pxor %mm2,%mm0
	movd %mm1,8(%esi)
	movq %mm0,(%esi)

	movq 32(%esi),%mm1
	movq 28(%esi),%mm3
	psrlq %mm6,%mm1
	movq 20(%esi),%mm4
	movq %mm3,%mm2
	psllq %mm5,%mm3
	psrlq %mm6,%mm4
	psrlq %mm6,%mm2
	movq %mm1,32(%esi)
	pxor %mm3,%mm4
	movd %mm2,28(%esi)
	movq %mm4,20(%esi)
.ELSE
	movq (%esi),%mm0
	movq 4(%esi),%mm1
	movq 8(%esi),%mm2
	movq 12(%esi),%mm3
	movq 16(%esi),%mm4
	psrlq %mm6,%mm0
	psrlq %mm6,%mm1
	psrlq %mm6,%mm2
	psrlq %mm6,%mm3
	psrlq %mm6,%mm4
	movd %mm0,(%esi)
	movd %mm1,4(%esi)
	movd %mm2,8(%esi)
	movd %mm3,12(%esi)
	movq %mm4,16(%esi)

	movq 24(%esi),%mm0
	movq 28(%esi),%mm1
	movq 32(%esi),%mm2
	movq 36(%esi),%mm3
	movq 40(%esi),%mm4
	psrlq %mm6,%mm0
	psrlq %mm6,%mm1
	psrlq %mm6,%mm2
	psrlq %mm6,%mm3
	psrlq %mm6,%mm4
	movd %mm0,24(%esi)
	movd %mm1,28(%esi)
	movd %mm2,32(%esi)
	movd %mm3,36(%esi)
	movq %mm4,40(%esi)
.ENDIF

	movl $montgomery_inv_add_table,%ebx
	shll $3,%ebp
	leal (%ebx,%ebp,4),%ebp    # montgomery_inv_add_table[(1<<s)+t]

	movl (%ebp),%eax
	addl %eax,24(%esi)
	movl 4(%ebp),%eax
	adcl %eax,28(%esi)
	movl 8(%ebp),%eax
	adcl %eax,32(%esi)
	movl 12(%ebp),%eax
	adcl %eax,36(%esi)
	movl 16(%ebp),%eax
	adcl %eax,40(%esi)
	movl 20(%ebp),%eax
	adcl %eax,44(%esi)        # s2+=montgomery_inv_add_table[(1<<s)+t]
	movl (%esi),%eax
	andl $1,%eax
	jz inv_shift_while_loop192
	movl montgomery_modulo_n,%ebp
	jmp inv_while_loop192

inv_while_loop_end192:
	movl b,%esi
	movl (%esi),%ebx    # b[0]
	testl $1,%ebx
	movl res,%edi
	jnz inv_bodd_end192
	movl (%ebp),%ecx
	subl t20,%ecx
	movl %ecx,(%edi)
	movl 4(%ebp),%eax
	sbbl t21,%eax
	movl %eax,4(%edi)
	movl 8(%ebp),%ecx
	sbbl t22,%ecx
	movl %ecx,8(%edi)
	movl 12(%ebp),%eax
	sbbl t23,%eax
	movl %eax,12(%edi)
	movl 16(%ebp),%ecx
	sbbl t24,%ecx
	movl %ecx,16(%edi)
	movl 20(%ebp),%eax
	sbbl t25,%eax
	movl %eax,20(%edi)
	jmp inv_end192
inv_bodd_end192:
	movl t20,%ecx
	movl %ecx,(%edi)
	movl t21,%eax
	movl %eax,4(%edi)
	movl t22,%ecx
	movl %ecx,8(%edi)
	movl t23,%eax
	movl %eax,12(%edi)
	movl t24,%eax
	movl %eax,16(%edi)
	movl t25,%eax
	movl %eax,20(%edi)
inv_end192:
	subl $12,%esp
	movl $montgomery_modulo_R4, 4(%esp)
	movl %edi,(%esp)
	movl %edi,8(%esp)
	call asm_mulm192
	addl $12,%esp

	movl t10,%eax
	decl %eax
	addl t11,%eax
	adcl t12,%eax
	adcl t13,%eax
	adcl t14,%eax
	adcl t15,%eax
	adcl $0,%eax
	adcl $0,%eax
	subl $1,%eax    # carry iff t10=1, t11=0, t12=0, t13=0, t14=0
	movl $0,%eax
	adcl $0,%eax
	emms
	addl $108,%esp
	popl %ebp
	popl %ebx
	popl %edi
	popl %esi
	ret
.ENDIF
