dnl Arithmetic for 96 Bit



.comm montgomery_modulo_n,4
.comm montgomery_inv_n,4

.text


dnl asm_zero96(a): a=0
function_head(asm_zero96)
	movl 4(%esp),%edx
	xorl %eax,%eax
	movl %eax,(%edx)
	movl %eax,4(%edx)
	movl %eax,8(%edx)
	ret

dnl asm_copy96(b,a): b=a
function_head(asm_copy96)
	movl 4(%esp),%edx
	movl 8(%esp),%ecx
	movl (%ecx),%eax
	movl %eax,(%edx)
	movl 4(%ecx),%eax
	movl %eax,4(%edx)
	movl 8(%ecx),%eax
	movl %eax,8(%edx)
	ret

dnl asm_sub_n96(b,a): b-=a  mod 2^96
function_head(asm_sub_n96)
	movl 4(%esp),%edx
	movl 8(%esp),%ecx
	movl (%ecx),%eax
	subl %eax,(%edx)
	movl 4(%ecx),%eax
	sbbl %eax,4(%edx)
	movl 8(%ecx),%eax
	sbbl %eax,8(%edx)
	ret

dnl asm_sub96_3(c,a,b): c=a-b mod N
function_head(asm_sub96_3)
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
	jnc sub_end
	movl montgomery_modulo_n,%edx
	movl (%edx),%eax
	addl %eax,(%ecx)
	movl 4(%edx),%eax
	adcl %eax,4(%ecx)
	movl 8(%edx),%eax
	adcl %eax,8(%ecx)
sub_end:
	popl %esi
	ret


dnl asm_half96(a): a/=2 mod N
function_head(asm_half96)
	movl 4(%esp),%ecx
	movl (%ecx),%eax
	testl $1,%eax
	jnz half_odd
dnl a is even
	shrl $1,8(%ecx)
	rcrl $1,4(%ecx)
	rcrl $1,(%ecx)
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
	adcl 8(%ecx),%eax
	rcrl $1,%eax
	movl %eax,8(%ecx)
	rcrl $1,4(%ecx)
	rcrl $1,(%ecx)

	popl %esi
	ret

dnl asm_diff96(c,a,b): c=|a-b|
function_head(asm_diff96)
	pushl %esi
	pushl %edi
	pushl %ebx
	movl 20(%esp),%edi
	movl 24(%esp),%esi
	movl 16(%esp),%ebx
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
diff_end:
	popl %ebx
	popl %edi
	popl %esi
	ret

dnl asm_add96(b,a): b+=a mod N
function_head(asm_add96)
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

	movl montgomery_modulo_n,%esi
	jc sub
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
add_end:
	popl %edi
	popl %esi
	ret

dnl asm_add96_ui(b,a): b+=a mod N, a is ulong
function_head(asm_add96_ui)
	pushl %esi
	pushl %edi
	movl 12(%esp),%edi
	movl 16(%esp),%eax
	addl %eax,(%edi)
	adcl $0,4(%edi)
	adcl $0,8(%edi)
	jnc add_ui_end
	movl montgomery_modulo_n,%esi
	movl (%esi),%eax
	subl %eax,(%edi)
	movl 4(%esi),%eax
	sbbl %eax,4(%edi)
	movl 8(%esi),%eax
	sbbl %eax,8(%edi)
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


dnl asm_mulm96(c,a,b): c=a*b mont-mod N
function_head(asm_mulm96)
	pushl %esi
	pushl %edi
	pushl %ebx
	pushl %ebp
	subl $40,%esp

	movl $0,%ecx
	movl f1,%ebp
	movl %ecx,tmp0
	movl %ecx,tmp1
	movl f2,%edx
	movl $0,%esi
	movl $0,%edi

mulloop:
	movl (%edx,%ecx,4),%ebx

	movl (%ebp),%eax
	mull %ebx
	 movl %edi,tmp3
	 movl %esi,tmp2
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
	 movl tmp3,%esi
	 adcl $0,%esi
	 movl tmp0,%ebx
	addl %eax,%edi
	adcl %edx,%esi

	movl montgomery_inv_n,%eax
	mull %ebx
	 movl %edi,tmp2
	 movl %esi,tmp3
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
	 movl tmp3,%esi
	 adcl $0,%esi
	 movl f1,%ebp
	addl %eax,%edi
	adcl %edx,%esi
	movl %edi,tmp1
	movl $0,%edi
	adcl $0,%edi

	incl %ecx
	cmpl $3,%ecx
	movl f2,%edx
	jnz mulloop

        movl montgomery_modulo_n,%ebp
        movl prod,%edx

        movl tmp0,%eax
	movl %eax,(%edx)
        subl (%ebp),%eax
	movl tmp1,%ebx
	movl %ebx,4(%edx)
	sbbl 4(%ebp),%ebx
	movl %esi,8(%edx)
	sbbl 8(%ebp),%esi
	sbbl $0,%edi
	jc nosub

	movl %eax,(%edx)
	movl %ebx,4(%edx)
	movl %esi,8(%edx)
nosub:
	addl $40,%esp
	popl %ebp
	popl %ebx
	popl %edi
	popl %esi
	ret

undefine(`tmp0')
undefine(`tmp1')
define(sq,80(%``''esp))dnl
define(f,84(%``''esp))dnl
define(tmp0,52(%``''esp))dnl
define(tmp1,56(%``''esp))dnl

dnl slower than asm_mulm96 !!???
dnl asm_sqm96(b,a): b=a*a mont-mod N
function_head(asm_sqm96)
	pushl %esi
	pushl %edi
	pushl %ebx
	pushl %ebp
	subl $60,%esp

dnl begin of squaring

	movl f,%ebp
	movl (%ebp),%ecx
	movl 4(%ebp),%eax
	mull %ecx
	movl 8(%ebp),%esi      # a2
	xorl %ebx,%ebx
	movl %ebx,24(%esp)
	movl %eax,8(%esp)
	movl %edx,%ebx

	movl %ecx,%eax
	mull %esi
	xorl %edi,%edi
	addl %ebx,%eax
	movl %eax,12(%esp)
	adcl %edx,%edi

	movl 4(%ebp),%eax
	mull %esi
	xorl %ecx,%ecx
	addl %edi,%eax
	adcl $0,%edx

	shll $1,8(%esp)
	rcll $1,12(%esp)
	rcll $1,%eax
	movl %eax,16(%esp)
	rcll $1,%edx
	movl %edx,20(%esp)
	adcl %ecx,24(%esp)

	movl (%ebp),%eax
	mull %eax
	movl %eax,4(%esp)
	movl %edx,32(%esp)

	movl 4(%ebp),%eax
	mull %eax
	movl %eax,36(%esp)
	movl %edx,40(%esp)

	movl 8(%ebp),%eax
	mull %eax

	movl 32(%esp),%ebx
	addl %ebx,8(%esp)
	movl 36(%esp),%ecx
	adcl %ecx,12(%esp)
	movl 40(%esp),%ebx
	adcl %ebx,16(%esp)
	adcl %eax,20(%esp)
	adcl %edx,24(%esp)
dnl end of squaring

dnl begin of reduction

	movl montgomery_inv_n,%eax
	movl 4(%esp),%ecx
	mull %ecx
	movl montgomery_modulo_n,%esi
	movl %eax,%ecx

	movl (%esi),%eax
	mull %ecx
	xorl %ebx,%ebx
	addl %eax,4(%esp)
	adcl %edx,%ebx

	movl 4(%esi),%eax
	mull %ecx
	addl %ebx,%eax
	adcl $0,%edx
	addl %eax,8(%esp)
	adcl %edx,12(%esp)
	movl $0,%ebx
	adcl $0,%ebx

	movl 8(%esi),%eax
	mull %ecx
	addl %ebx,%edx
	addl %eax,12(%esp)
	adcl %edx,16(%esp)
	adcl $0,20(%esp)
	adcl $0,24(%esp)

	movl montgomery_inv_n,%eax
	movl 8(%esp),%ecx
	mull %ecx
	movl %eax,%ecx

	movl (%esi),%eax
	mull %ecx
	xorl %ebx,%ebx
	addl %eax,8(%esp)
	adcl %edx,%ebx

	movl 4(%esi),%eax
	mull %ecx
	addl %ebx,%eax
	adcl $0,%edx
	addl %eax,12(%esp)
	adcl %edx,16(%esp)
	movl $0,%ebx
	adcl $0,%ebx

	movl 8(%esi),%eax
	mull %ecx
	addl %ebx,%edx
	addl %eax,16(%esp)
	adcl %edx,20(%esp)
	adcl $0,24(%esp)

	movl montgomery_inv_n,%eax
	movl 12(%esp),%ecx
	mull %ecx
	movl %eax,%ecx

	movl (%esi),%eax
	mull %ecx
	xorl %ebx,%ebx
	addl %eax,12(%esp)
	adcl %edx,%ebx

	movl 4(%esi),%eax
	mull %ecx
	addl %ebx,%eax
	adcl $0,%edx
	addl %eax,16(%esp)
	adcl %edx,20(%esp)
	movl $0,%ebx
	adcl $0,%ebx

	movl 8(%esi),%eax
	mull %ecx
	addl %ebx,%edx
	addl %eax,20(%esp)
	adcl %edx,24(%esp)

	movl sq,%ebp
	movl 16(%esp),%eax
	movl %eax,(%ebp)
	movl 20(%esp),%eax
	movl %eax,4(%ebp)
	movl 24(%esp),%eax
	movl %eax,8(%ebp)

	jc subtractsq
	cmpl 8(%esi),%eax
	jc endesq
	jnz subtractsq
	movl 4(%ebp),%eax
	cmpl 4(%esi),%eax
	jc endesq
	jnz subtractsq
	movl (%ebp),%eax
	cmpl (%esi),%eax
	jc endesq

subtractsq:
	movl (%esi),%eax
	subl %eax,(%ebp)
	movl 4(%esi),%eax
	sbbl %eax,4(%ebp)
	movl 8(%esi),%eax
	sbbl %eax,8(%ebp)
endesq:
	addl $60,%esp
	popl %ebp
	popl %ebx
	popl %edi
	popl %esi
	ret


dnl  inversion

define(res,72(%``''esp))dnl
define(b,76(%``''esp))dnl
define(t10,4(%``''esp))dnl
define(t11,8(%``''esp))dnl
define(t12,12(%``''esp))dnl
define(t20,16(%``''esp))dnl
define(t21,20(%``''esp))dnl
define(t22,24(%``''esp))dnl
define(v10,28(%``''esp))dnl
define(v11,32(%``''esp))dnl
define(v12,36(%``''esp))dnl
define(v20,40(%``''esp))dnl
define(v21,44(%``''esp))dnl
define(v22,48(%``''esp))dnl

.comm montgomery_inv_shift_table,64
.comm montgomery_inv_add_table,4

.text
dnl asm_inv96(res,b)
function_head(asm_inv96)
	pushl %esi
	pushl %edi
	pushl %ebx
	pushl %ebp
	subl $52,%esp

	xorl %eax,%eax
	movl %eax,t21
	movl %eax,t22
	movl %eax,v20
	movl %eax,v21
	movl %eax,v22
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
	movl %eax,v12    # v1=N
	jz inv_beven
	movl (%esi),%eax
	movl %eax,t10
	movl 4(%esi),%ecx
	movl %ecx,t11
	movl 8(%esi),%eax
	movl %eax,t12     # t1=b
	jmp inv_while_loop
.align 16
inv_beven:
	movl (%ebp),%ecx
	subl (%esi),%ecx
	movl %ecx,t10
	movl 4(%ebp),%eax
	sbbl 4(%esi),%eax
	movl %eax,t11
	movl 8(%ebp),%ecx
	sbbl 8(%esi),%ecx
	movl %ecx,t12     # t1=N-b

inv_while_loop:
	movl t10,%eax
	subl v10,%eax
	movl t11,%edi
	sbbl v11,%edi
	movl t12,%esi
	sbbl v12,%esi

	jc inv_v1bigger
	orl %eax,%edi
	orl %esi,%edi
	jz inv_while_loop_end   # t1=v1
	leal t10,%esi
	leal v10,%edi
	jmp inv_sub
inv_v1bigger:
	leal v10,%esi
	leal t10,%edi
inv_sub:                     # (esi)1 > (edi)1
	movl (%edi),%eax
	subl %eax,(%esi)
	movl 4(%edi),%ecx
	sbbl %ecx,4(%esi)
	movl 8(%edi),%eax
	sbbl %eax,8(%esi)    # s1-=d1
	movl 12(%edi),%ecx
	subl %ecx,12(%esi)
	movl 16(%edi),%eax
	sbbl %eax,16(%esi)
	movl 20(%edi),%ecx
	sbbl %ecx,20(%esi)    # s2-=d2
	movl $montgomery_inv_shift_table,%edi
	jnc inv_no_add_N
	movl (%ebp),%eax
	addl %eax,12(%esi)
	movl 4(%ebp),%ecx
	adcl %ecx,16(%esi)
	movl 8(%ebp),%eax
	adcl %eax,20(%esi)    # if s2<0: s2+=N
inv_no_add_N:
inv_shift_while_loop:
	movl (%esi),%eax
	andl $0x0f,%eax
	movl (%edi,%eax,4),%ecx    # shift
	movl $1,%eax
	shll %cl,%eax
	movl %eax,%ebp
	decl %eax
	andl 12(%esi),%eax         # t
	addl %eax,%ebp             # (1<<s)+t

	movd %ecx,%mm6
	movq (%esi),%mm0
	movq 4(%esi),%mm1
	psrlq %mm6,%mm0
	psrlq %mm6,%mm1
	movd %mm0,(%esi)
	movq %mm1,4(%esi)
	movq 12(%esi),%mm0
	psrlq %mm6,%mm0
	movd %mm0,12(%esi)
	movq 16(%esi),%mm1
	psrlq %mm6,%mm1
	movq %mm1,16(%esi)

	movl $montgomery_inv_add_table,%ebx
	shll $3,%ebp
	leal (%ebx,%ebp,4),%ebp    # montgomery_inv_add_table[(1<<s)+t]

	movl (%ebp),%eax
	addl %eax,12(%esi)
	movl 4(%ebp),%eax
	adcl %eax,16(%esi)
	movl 8(%ebp),%eax
	adcl %eax,20(%esi)        # s2+=montgomery_inv_add_table[(1<<s)+t]
	movl (%esi),%eax
	andl $1,%eax
	jz inv_shift_while_loop
	movl montgomery_modulo_n,%ebp
	jmp inv_while_loop
inv_while_loop_end:
	movl b,%esi
	movl (%esi),%ebx    # b[0]
	testl $1,%ebx
	movl res,%edi
	jnz inv_bodd_end
	movl (%ebp),%ecx
	subl t20,%ecx
	movl %ecx,(%edi)
	movl 4(%ebp),%eax
	sbbl t21,%eax
	movl %eax,4(%edi)
	movl 8(%ebp),%ecx
	sbbl t22,%ecx
	movl %ecx,8(%edi)
	jmp inv_end
inv_bodd_end:
	movl t20,%ecx
	movl %ecx,(%edi)
	movl t21,%eax
	movl %eax,4(%edi)
	movl t22,%ecx
	movl %ecx,8(%edi)
inv_end:
	subl $12,%esp
	movl $montgomery_modulo_R4, 4(%esp)
	movl %edi,(%esp)
	movl %edi,8(%esp)
	call asm_mulm96
	addl $12,%esp

	movl t10,%eax
	decl %eax
	addl t11,%eax
	adcl t12,%eax
	adcl $0,%eax
	adcl $0,%eax
	subl $1,%eax    # carry iff t10=1, t11=0, t12=0
	movl $0,%eax
	adcl $0,%eax
	emms
	addl $52,%esp
	popl %ebp
	popl %ebx
	popl %edi
	popl %esi
	ret
