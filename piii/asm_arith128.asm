dnl Arithmetic for 128 Bit



.comm montgomery_modulo_n,4
.comm montgomery_inv_n,4

.text


dnl asm_zero128(a): a=0
function_head(asm_zero128)
	movl 4(%esp),%edx
	xorl %eax,%eax
	movl %eax,(%edx)
	movl %eax,4(%edx)
	movl %eax,8(%edx)
	movl %eax,12(%edx)
	ret

dnl asm_copy128(b,a): b=a
function_head(asm_copy128)
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
	ret

dnl asm_sub_n128(b,a): b-=a  mod 2^128
function_head(asm_sub_n128)
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
	ret

dnl asm_sub128_3(c,a,b): c=a-b mod N
function_head(asm_sub128_3)
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
sub_end:
	popl %esi
	ret


dnl asm_half128(a): a/=2 mod N
function_head(asm_half128)
	movl 4(%esp),%ecx
	movl (%ecx),%eax
	testl $1,%eax
	jnz half_odd
dnl a is even
	movl 12(%ecx),%eax
	shrl $1,%eax
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
	adcl 12(%ecx),%eax
	rcrl $1,%eax
	movl %eax,12(%ecx)
	rcrl $1,8(%ecx)
	rcrl $1,4(%ecx)
	rcrl $1,(%ecx)

	popl %esi
	ret

dnl asm_diff128(c,a,b): c=|a-b|
function_head(asm_diff128)
	pushl %esi
	pushl %edi
	pushl %ebx
	movl 20(%esp),%edi
	movl 24(%esp),%esi
	movl 16(%esp),%ebx

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
diff_end:
	popl %ebx
	popl %edi
	popl %esi
	ret

dnl asm_add128(b,a): b+=a mod N
function_head(asm_add128)
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

	movl montgomery_modulo_n,%esi
	jc sub
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

dnl asm_add128_ui(b,a): b+=a mod N, a is ulong
function_head(asm_add128_ui)
	pushl %esi
	pushl %edi
	movl 12(%esp),%edi
	movl 16(%esp),%eax
	addl %eax,(%edi)
	adcl $0,4(%edi)
	adcl $0,8(%edi)
	adcl $0,12(%edi)
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


dnl asm_mulm128(c,a,b): c=a*b mont-mod N
function_head(asm_mulm128)
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
	movl f2,%edx
	movl $0,%esi
	movl $0,%edi

mulloop:
	movl (%edx,%ecx,4),%ebx

	movl (%ebp),%eax
	mull %ebx
	 movl %esi,tmp4
	 movl %edi,tmp3
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
	 movl tmp4,%edi
	 adcl $0,%edi
	 movl tmp0,%ebx
	addl %eax,%esi
	adcl %edx,%edi

	movl montgomery_inv_n,%eax
	mull %ebx
	 movl %esi,tmp3
	 movl %edi,tmp4
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
	 movl tmp4,%edi
	 adcl $0,%edi
	 movl f1,%ebp

	addl %eax,%esi
	adcl %edx,%edi
	movl %esi,tmp2
	movl $0,%esi
	adcl $0,%esi

	incl %ecx
	cmpl $4,%ecx
	movl f2,%edx
	jnz mulloop
mllend:
			# now tmp3 in edi, tmp4 in esi
        movl montgomery_modulo_n,%ebp
        movl prod,%edx

        movl tmp0,%eax
	movl %eax,(%edx)
        subl (%ebp),%eax
	movl tmp1,%ebx
	movl %ebx,4(%edx)
	sbbl 4(%ebp),%ebx
	movl tmp2,%ecx
	movl %ecx,8(%edx)
	sbbl 8(%ebp),%ecx
	movl %edi,12(%edx)
	sbbl 12(%ebp),%edi
	sbbl $0,%esi
	jc nosub

	movl %eax,(%edx)
	movl %ebx,4(%edx)
	movl %ecx,8(%edx)
	movl %edi,12(%edx)
nosub:
	addl $40,%esp
	popl %ebp
	popl %ebx
	popl %edi
	popl %esi
	ret

dnl  inversion

define(res,88(%``''esp))dnl
define(b,92(%``''esp))dnl
define(t10,4(%``''esp))dnl
define(t11,8(%``''esp))dnl
define(t12,12(%``''esp))dnl
define(t13,16(%``''esp))dnl
define(t20,20(%``''esp))dnl
define(t21,24(%``''esp))dnl
define(t22,28(%``''esp))dnl
define(t23,32(%``''esp))dnl
define(v10,36(%``''esp))dnl
define(v11,40(%``''esp))dnl
define(v12,44(%``''esp))dnl
define(v13,48(%``''esp))dnl
define(v20,52(%``''esp))dnl
define(v21,56(%``''esp))dnl
define(v22,60(%``''esp))dnl
define(v23,64(%``''esp))dnl


.comm montgomery_inv_shift_table,64
.comm montgomery_inv_add_table,4

.text
dnl asm_inv128(res,b)
function_head(asm_inv128)
	pushl %esi
	pushl %edi
	pushl %ebx
	pushl %ebp
	subl $68,%esp

	movl $64,%ecx
	xorl %eax,%eax
	movd %ecx,%mm7
	movl %eax,t21
	movl %eax,t22
	movl %eax,t23
	movl %eax,v20
	movl %eax,v21
	movl %eax,v22
	movl %eax,v23
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
	movl %eax,v13    # v1=N
	jz inv_beven128
	movl (%esi),%eax
	movl %eax,t10
	movl 4(%esi),%ecx
	movl %ecx,t11
	movl 8(%esi),%eax
	movl %eax,t12
	movl 12(%esi),%eax
	movl %eax,t13     # t1=b
	jmp inv_while_loop128
.align 16
inv_beven128:
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
	movl %ecx,t13     # t1=N-b

inv_while_loop128:
	movl t10,%eax
	subl v10,%eax
	movl t11,%edi
	sbbl v11,%edi
	movl t12,%esi
	sbbl v12,%esi
	movl t13,%ecx
	sbbl v13,%ecx

	jc inv_v1bigger128
	orl %eax,%edi
	orl %esi,%ecx
	orl %edi,%ecx
	jz inv_while_loop_end128   # t1=v1
	leal t10,%esi
	leal v10,%edi
	jmp inv_sub128
inv_v1bigger128:
	leal v10,%esi
	leal t10,%edi
inv_sub128:                     # (esi)1 > (edi)1
	movl (%edi),%eax
	subl %eax,(%esi)
	movl 4(%edi),%ecx
	sbbl %ecx,4(%esi)
	movl 8(%edi),%eax
	sbbl %eax,8(%esi)
	movl 12(%edi),%ecx
	sbbl %ecx,12(%esi)    # s1-=d1
	movl 16(%edi),%eax
	subl %eax,16(%esi)
	movl 20(%edi),%ecx
	sbbl %ecx,20(%esi)
	movl 24(%edi),%eax
	sbbl %eax,24(%esi)
	movl 28(%edi),%ecx
	sbbl %ecx,28(%esi)    # s2-=d2
	jnc inv_no_add_N128
	movl (%ebp),%eax
	addl %eax,16(%esi)
	movl 4(%ebp),%ecx
	adcl %ecx,20(%esi)
	movl 8(%ebp),%eax
	adcl %eax,24(%esi)
	movl 12(%ebp),%ecx
	adcl %ecx,28(%esi)    # if s2<0: s2+=N
inv_no_add_N128:
	movl $montgomery_inv_shift_table,%edi
inv_shift_while_loop128:
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
	andl 16(%esi),%eax         # t
	addl %eax,%ebp             # (1<<s)+t

	movq 8(%esi),%mm2
	movq (%esi),%mm0
	movq %mm2,%mm1
	psllq %mm5,%mm2
	psrlq %mm6,%mm0
	movq 24(%esi),%mm3
	psrlq %mm6,%mm1
	movq 16(%esi),%mm4
	pxor %mm2,%mm0
	movq %mm3,%mm2
	movq %mm1,8(%esi)
	psrlq %mm6,%mm4
	movq %mm0,(%esi)
	psrlq %mm6,%mm2
	movq %mm2,24(%esi)
	psllq %mm5,%mm3
	pxor %mm3,%mm4
	movq %mm4,16(%esi)

	movl $montgomery_inv_add_table,%ebx
	shll $3,%ebp
	leal (%ebx,%ebp,4),%ebp    # montgomery_inv_add_table[(1<<s)+t]

	movl (%ebp),%eax
	addl %eax,16(%esi)
	movl 4(%ebp),%eax
	adcl %eax,20(%esi)
	movl 8(%ebp),%eax
	adcl %eax,24(%esi)
	movl 12(%ebp),%eax
	adcl %eax,28(%esi)        # s2+=montgomery_inv_add_table[(1<<s)+t]
	movl (%esi),%eax
	andl $1,%eax
	jz inv_shift_while_loop128
	movl montgomery_modulo_n,%ebp
	jmp inv_while_loop128

inv_while_loop_end128:
	movl b,%esi
	movl (%esi),%ebx    # b[0]
	testl $1,%ebx
	movl res,%edi
	jnz inv_bodd_end128
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
	jmp inv_end128
inv_bodd_end128:
	movl t20,%ecx
	movl %ecx,(%edi)
	movl t21,%eax
	movl %eax,4(%edi)
	movl t22,%ecx
	movl %ecx,8(%edi)
	movl t23,%eax
	movl %eax,12(%edi)
inv_end128:
	subl $12,%esp
	movl $montgomery_modulo_R4, 4(%esp)
	movl %edi,(%esp)
	movl %edi,8(%esp)
	call asm_mulm128
	addl $12,%esp

	movl t10,%eax
	decl %eax
	addl t11,%eax
	adcl t12,%eax
	adcl t13,%eax
	adcl $0,%eax
	adcl $0,%eax
	subl $1,%eax    # carry iff t10=1, t11=0, t12=0, t13=0
	movl $0,%eax
	adcl $0,%eax
	emms
	addl $68,%esp
	popl %ebp
	popl %ebx
	popl %edi
	popl %esi
	ret
