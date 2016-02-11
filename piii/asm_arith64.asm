dnl    Arithmetic for 64 Bit



.comm montgomery_modulo_n,4
.comm montgomery_inv_n,4

.text

dnl asm_zero64(a): a=0
function_head(asm_zero64)
	movl 4(%esp),%edx
	xorl %eax,%eax
	movl %eax,(%edx)
	movl %eax,4(%edx)
	ret

dnl asm_copy64(b,a): b=a
function_head(asm_copy64)
	movl 4(%esp),%edx
	movl 8(%esp),%ecx
	movl (%ecx),%eax
	movl %eax,(%edx)
	movl 4(%ecx),%eax
	movl %eax,4(%edx)
	ret


dnl asm_sub64_3(c,a,b): c=a-b mod N
function_head(asm_sub64_3)
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
	jnc sub_end
	movl montgomery_modulo_n,%edx
	movl (%edx),%eax
	addl %eax,(%ecx)
	movl 4(%edx),%eax
	adcl %eax,4(%ecx)
sub_end:
	popl %esi
	ret


dnl asm_half64(a): a/=2 mod N
function_head(asm_half64)
	movl 4(%esp),%ecx
	movl (%ecx),%eax
	testl $1,%eax
	jnz half_odd
dnl a is even
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
	addl (%ecx),%eax
	movl %eax,(%ecx)
	movl 4(%esi),%eax
	adcl 4(%ecx),%eax
	movl %eax,4(%ecx)

	rcrl $1,4(%ecx)
	rcrl $1,(%ecx)

	popl %esi
	ret


dnl asm_sub_n64(b,a): b-=a  mod 2^64
function_head(asm_sub_n64)
        movl 4(%esp),%edx
        movl 8(%esp),%ecx
        movl (%ecx),%eax
        subl %eax,(%edx)
        movl 4(%ecx),%eax
        sbbl %eax,4(%edx)
        ret


dnl asm_diff64(c,a,b): c=|a-b|
function_head(asm_diff64)
	pushl %esi
	pushl %edi
	pushl %ebx
	movl 20(%esp),%edi
	movl 24(%esp),%esi
	movl 16(%esp),%ebx
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
	jmp diff_end
a_smaller_b:
	movl (%esi),%eax
	subl (%edi),%eax
	movl %eax,(%ebx)
	movl 4(%esi),%eax
	sbbl 4(%edi),%eax
	movl %eax,4(%ebx)
	jmp diff_end
b_smaller_a:
	movl (%edi),%eax
	subl (%esi),%eax
	movl %eax,(%ebx)
	movl 4(%edi),%eax
	sbbl 4(%esi),%eax
	movl %eax,4(%ebx)
diff_end:
	popl %ebx
	popl %edi
	popl %esi
	ret

dnl asm_add64(b,a): b+=a mod N
function_head(asm_add64)
	pushl %esi
	pushl %edi
	movl 16(%esp),%esi
	movl 12(%esp),%edi
	movl (%esi),%eax
	addl %eax,(%edi)
	movl 4(%esi),%eax
	adcl %eax,4(%edi)
	movl montgomery_modulo_n,%esi
	jc sub
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
add_end:
	popl %edi
	popl %esi
	ret

dnl asm_add64_ui(b,a): b+=a mod N, a is ulong
function_head(asm_add64_ui)
        pushl %esi
	pushl %edi
        movl 12(%esp),%edi
        movl 16(%esp),%eax
        addl %eax,(%edi)
        adcl $0,4(%edi)
        jnc add_ui_end
        movl montgomery_modulo_n,%esi
        movl (%esi),%eax
        subl %eax,(%edi)
        movl 4(%esi),%eax
        sbbl %eax,4(%edi)
add_ui_end:
	popl %edi
        popl %esi
        ret



define(prod,52(%``''esp))dnl
define(f1,56(%``''esp))dnl
define(f2,60(%``''esp))dnl


dnl asm_mulm64(): prod=f1*f2 mod N
function_head(asm_mulm64)
	pushl %esi
	pushl %edi
	pushl %ebx
	pushl %ebp
	subl $32,%esp
dnl begin
	xorl %ebx,%ebx
	movl %ebx,4(%esp)
	movl %ebx,8(%esp)
	movl %ebx,12(%esp)
	movl %ebx,16(%esp)

	movl f1,%edi
        movl f2,%esi
	movl (%edi),%ecx
        movl (%esi),%eax
	mull %ecx
	movl %eax,4(%esp)
	movl %edx,%ebx

	movl 4(%esi),%eax
	mull %ecx
	addl %ebx,%eax
	movl %eax,8(%esp)
	movl $0,%ebx
	adcl %edx,%ebx

	movl 4(%edi),%ecx
	movl (%esi),%eax
	mull %ecx
	addl %eax,8(%esp)
	adcl %edx,%ebx
	movl %ebx,12(%esp)
	movl $0,%ebx
	adcl $0,%ebx

	movl 4(%esi),%eax
	mull %ecx
	addl %eax,12(%esp)
	adcl %edx,%ebx
	movl %ebx,16(%esp)

	movl montgomery_inv_n,%eax
	movl 4(%esp),%ecx
	mull %ecx
	movl %eax,%ecx
	movl montgomery_modulo_n,%esi

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
	adcl $0,16(%esp)

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

	movl prod,%edi
	movl 12(%esp),%eax
	movl %eax,(%edi)
	movl 16(%esp),%eax
	movl %eax,4(%edi)

	jc subtract
	cmpl 4(%esi),%eax
	jc ende
	jnz subtract
	movl (%edi),%eax
	cmpl (%esi),%eax
	jc ende

subtract:
        movl (%esi),%eax
        subl %eax,(%edi)
        movl 4(%esi),%eax
        sbbl %eax,4(%edi)
ende:
	addl $32,%esp
	popl %ebp
	popl %ebx
	popl %edi
	popl %esi
	ret



define(sq,52(%``''esp))dnl
define(f,56(%``''esp))dnl


function_head(asm_sqm64)
	pushl %esi
	pushl %edi
	pushl %ebx
	pushl %ebp
	subl $32,%esp

dnl begin of squaring

	xorl %ebx,%ebx
	movl %ebx,4(%esp)
	movl %ebx,8(%esp)
	movl %ebx,12(%esp)
	movl %ebx,16(%esp)

	movl f,%edi
	movl (%edi),%eax
	mull %eax
	movl %eax,4(%esp)
	movl %edx,8(%esp)

	movl 4(%edi),%eax
	mull %eax
	movl %eax,12(%esp)
	movl %edx,16(%esp)

	movl 4(%edi),%ecx
	movl (%edi),%eax
	mull %ecx
	addl %eax,%eax
	adcl %edx,%edx
	movl $0,%ebx
	adcl $0,%ebx

	addl %eax,8(%esp)
	adcl %edx,12(%esp)
	adcl %ebx,16(%esp)

dnl end of squaring

	movl montgomery_inv_n,%eax
	movl 4(%esp),%ecx
	mull %ecx
	movl %eax,%ecx
	movl montgomery_modulo_n,%esi

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
	adcl $0,16(%esp)

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

	movl sq,%edi
	movl 12(%esp),%eax
	movl %eax,(%edi)
	movl 16(%esp),%eax
	movl %eax,4(%edi)

	jc subtractsq
	cmpl 4(%esi),%eax
	jc endesq
	jnz subtractsq
	movl (%edi),%eax
	cmpl (%esi),%eax
	jc endesq

subtractsq:
        movl (%esi),%eax
        subl %eax,(%edi)
        movl 4(%esi),%eax
        sbbl %eax,4(%edi)
endesq:
	addl $32,%esp
	popl %ebp
	popl %ebx
	popl %edi
	popl %esi
	ret


dnl  inversion
dnl   not tested !!!

define(res,56(%``''esp))dnl
define(b,60(%``''esp))dnl
define(t10,4(%``''esp))dnl
define(t11,8(%``''esp))dnl
define(t20,12(%``''esp))dnl
define(t21,16(%``''esp))dnl
define(v10,20(%``''esp))dnl
define(v11,24(%``''esp))dnl
define(v20,28(%``''esp))dnl
define(v21,32(%``''esp))dnl


.comm montgomery_inv_shift_table,64
.comm montgomery_inv_add_table,4

dnl asm_inv64(res,b)
function_head(asm_inv64)
	pushl %esi
	pushl %edi
	pushl %ebx
	pushl %ebp
	subl $36,%esp

	xorl %eax,%eax
	movl %eax,t21
	movl %eax,v20
	movl %eax,v21
	incl %eax
	movl %eax,t20    # t2=1, v2=0
	movl montgomery_modulo_n,%ebp
	movl b,%esi
	movl (%esi),%ebx    # b[0]
	andl $1,%ebx        # flag for jmp below
	movl (%ebp),%eax
	movl %eax,v10
	movl 4(%ebp),%ecx
	movl %ecx,v11    # v1=N
	jz inv_beven
	movl (%esi),%eax
	movl %eax,t10
	movl 4(%esi),%ecx
	movl %ecx,t11     # t1=b
	jmp inv_while_loop
.align 16
inv_beven:
	movl (%ebp),%eax
	subl (%esi),%eax
	movl %eax,t10
	movl 4(%ebp),%ecx
	sbbl 4(%esi),%ecx
	movl %ecx,t11     # t1=N-b

inv_while_loop:
	movl t10,%eax
	subl v10,%eax
	movl t11,%edi
	sbbl v11,%edi

	jc inv_v1bigger
	orl %eax,%edi
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
	sbbl %ecx,4(%esi)    # s1-=d1
	movl 8(%edi),%eax
	subl %eax,8(%esi)
	movl 12(%edi),%ecx
	sbbl %ecx,12(%esi)    # s2-=d2
	movl $montgomery_inv_shift_table,%edi
	jnc inv_no_add_N
	movl (%ebp),%eax
	addl %eax,8(%esi)
	movl 4(%ebp),%ecx
	adcl %ecx,12(%esi)    # if s2<0: s2+=N
inv_no_add_N:
inv_shift_while_loop:
	movl (%esi),%eax
	andl $0x0f,%eax
	movl (%edi,%eax,4),%ecx    # shift
	movl $1,%eax
	shll %cl,%eax
	movl %eax,%ebp
	decl %eax
	andl 8(%esi),%eax         # t
	addl %eax,%ebp             # (1<<s)+t

	movd %ecx,%mm6
	movq (%esi),%mm0
	psrlq %mm6,%mm0
	movq %mm0,(%esi)
	movq 8(%esi),%mm1
	psrlq %mm6,%mm1
	movq %mm1,8(%esi)

	movl $montgomery_inv_add_table,%ebx
	shll $3,%ebp
	leal (%ebx,%ebp,4),%ebp    # montgomery_inv_add_table[(1<<s)+t]

	movl (%ebp),%eax
	addl %eax,8(%esi)
	movl 4(%ebp),%eax
	adcl %eax,12(%esi)        # s2+=montgomery_inv_add_table[(1<<s)+t]
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
	jmp inv_end
inv_bodd_end:
	movl t20,%ecx
	movl %ecx,(%edi)
	movl t21,%eax
	movl %eax,4(%edi)
inv_end:
	subl $12,%esp
	movl $montgomery_modulo_R4, 4(%esp)
	movl %edi,(%esp)
	movl %edi,8(%esp)
	call asm_mulm64
	addl $12,%esp

	movl t10,%eax
	decl %eax
	addl t11,%eax
	adcl $0,%eax
	subl $1,%eax    # carry iff t10=1, t11=0, t12=0
	movl $0,%eax
	adcl $0,%eax
	emms
	addl $36,%esp
	popl %ebp
	popl %ebx
	popl %edi
	popl %esi
	ret

	.END
