dnl tdslinie1(aux_ptr,aux_ptr_ub,sieve_interval,tds_buffer)
dnl We save %ebx,%esi,%edi,%ebp and also have one auto variable and the
dnl return address on the stack. Therefore, the stack offset of the
dnl first arg is 24.
define(aux_ptr_arg,24(%esp))dnl
define(aux_ptr_ub,28(%esp))dnl
define(sieve_interval,32(%esp))dnl
define(tds_buffer_arg,36(%esp))dnl
dnl Now, the registers which we are going to use
define(sieve_ptr,%edi)dnl
define(sieve_ptr_ub,%ebp)dnl
define(root,%edx)dnl
define(root16,%dx)dnl
define(prime,%ecx)dnl
define(tds_buffer,%eax)dnl
define(sv0,%bh)dnl
dnl The bx-register may also be used for auxilliary 32-bit values if sv1
dnl is not used
define(auxreg,%ebx)dnl
define(aux_ptr,%esi)dnl
dnl Offset of the various things from this pointer
define(prime_src,(%esi))dnl
define(proot_src,2(%esi))dnl
define(root_src,6(%esi))dnl
dnl We store the int difference projective_root-prime here:
define(proot,(%esp))dnl
dnl This macro is taken from the GNU info documentation of m4.
function_head(tdslinie1)
	pushl %ebx
	pushl %esi
	pushl %edi
	pushl %ebp
	subl $4,%esp
	movl aux_ptr_arg,aux_ptr
	movl $-8,auxreg
	cmpl aux_ptr,aux_ptr_ub
	jbe tdslinie1_ende
	addl auxreg,aux_ptr_ub
	movl tds_buffer_arg,tds_buffer
tdslinie1_fbi_loop:
	movzwl proot_src,auxreg
	movzwl prime_src,prime
	movzwl root_src,root
	subl prime,auxreg
	movl auxreg,proot	
	movl sieve_interval,sieve_ptr_ub
forloop(`i',1,j_per_strip,`
	movl root,sieve_ptr
	xorl auxreg,auxreg
	addl proot,root
	leal (sieve_ptr_ub,sieve_ptr),sieve_ptr
	cmovncl prime,auxreg
	addl $n_i,sieve_ptr_ub
	addl auxreg,root
	subl prime,sieve_ptr_ub
	movb (sieve_ptr),sv0
	cmpl sieve_ptr,sieve_ptr_ub
	leal (sieve_ptr_ub,prime),sieve_ptr_ub
	jbe tdslinie1_t2_`'i
	orb (sieve_ptr,prime),sv0
tdslinie1_t2_`'i:
	testb sv0,sv0
	jz tdslinie1_next_j`'i
	movzbl (sieve_ptr),auxreg
	testl auxreg,auxreg
	leal (sieve_ptr,prime),sieve_ptr
	jz tdslinie1_s1_`'i
	decl auxreg
	pushl tds_buffer
	leal (tds_buffer,auxreg,4),auxreg
	movl (auxreg),tds_buffer
	movl prime,(tds_buffer)
	leal 4(tds_buffer),tds_buffer
	movl tds_buffer,(auxreg)
	popl tds_buffer
tdslinie1_s1_`'i:
	cmpl sieve_ptr,sieve_ptr_ub
	jbe tdslinie1_next_j`'i
        movzbl (sieve_ptr),auxreg
        testl auxreg,auxreg
        jz tdslinie1_next_j`'i
        decl auxreg
        leal (tds_buffer,auxreg,4),auxreg
        movl (auxreg),sieve_ptr
        movl prime,(sieve_ptr)
        leal 4(sieve_ptr),sieve_ptr
        movl sieve_ptr,(auxreg)
tdslinie1_next_j`'i:
')
	cmpl aux_ptr,aux_ptr_ub
	movw root16,root_src
	leal 8(aux_ptr),aux_ptr
	ja tdslinie1_fbi_loop
tdslinie1_ende:
	addl $4,%esp
	popl %ebp
	popl %edi
	popl %esi
	popl %ebx
	ret
