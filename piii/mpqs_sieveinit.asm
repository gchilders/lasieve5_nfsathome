

define(sv,16(%esp))dnl
define(len,20(%esp))dnl
define(tab,24(%esp))dnl
define(maskptr,28(%esp))dnl
define(tinyptr,32(%esp))dnl
define(tinylen,36(%esp))dnl
define(mask,%mm2)dnl
define(mask1,%mm3)dnl


function_head(asm_sieve_init)
	pushl %ebx
	pushl %esi
	pushl %edi
	movl maskptr,%eax
	movq (%eax),mask1
	movl sv,%edx
	movl tinyptr,%esi
	movl tinylen,%eax
	shll $4,%eax
	leal (%esi,%eax),%edi  # tinyend
	movl tab,%eax
	movzwl (%eax),%ebx     # this is 0
outerloop:
	movzwl 4(%eax),%ecx
	subl %ebx,%ecx       # length in byte
	shrl $4,%ecx         # length in 16 byte
	movzwl 2(%eax),%ebx
	leal 4(%eax),%eax

	pxor mask,mask
	testl %ebx,%ebx
	jz innerloop
mulloop:                    # %ebx is small
	decl %ebx
	paddb mask1,mask
	jnz mulloop

innerloop:
	movq (%esi),%mm0
	movq 8(%esi),%mm1
	leal 16(%esi),%esi
	cmpl %esi,%edi
	paddb mask,%mm0
	paddb mask,%mm1
	cmovzl tinyptr,%esi
	decl %ecx            # length>0
	movq %mm0,(%edx)
	movq %mm1,8(%edx)
	leal 16(%edx),%edx
	jnz innerloop

	movzwl (%eax),%ebx
	cmpl len,%ebx
	jnz outerloop

	emms
	popl %edi
	popl %esi
	popl %ebx
	ret
undefine(`sv')dnl
undefine(`len')dnl
undefine(`tab')dnl
undefine(`maskptr')dnl
undefine(`tinyptr')dnl
undefine(`tinylen')dnl
undefine(`mask')dnl
undefine(`mask1')dnl
define(ta,16(%esp))dnl
define(mask16,20(%esp))dnl
define(len,24(%esp))dnl
define(ms,%mm0)dnl
define(mt,%mm1)dnl
define(ms0,%mm2)dnl
define(msz,%mm3)dnl
define(mtz,%mm4)dnl
define(ms0z,%mm5)dnl
define(src,%esi)dnl
define(targ,%edi)dnl
define(len8,%ebx)dnl
define(sh,%mm6)dnl
define(ish,%mm7)dnl
function_head(asm_sieve_init0)
	pushl %ebx
	pushl %esi
	pushl %edi

#  memcpy(mpqs3_tinyarray+mpqs3_tiny_prod,mpqs3_tinyarray,mpqs3_tiny_prod);

	movl ta,src
	movl len,len8
	movl len8,%ecx
	shrl $3,len8
	leal (src,len8,8),targ
	andl $7,%ecx     # shift in byte
	shll $3,%ecx     # shift in bit
	movd %ecx,sh
	negl %ecx
	addl $64,%ecx
	movd %ecx,ish

	movq (src),ms
	movq (targ),mt
	movq ms,ms0
	psllq ish,mt
	psrlq ish,mt
	psllq sh,ms
	pxor ms,mt
	movq mt,(targ)
	testl $1,len8
	jz mcloop1begin
	decl len8
	movq 8(src),ms
	movq ms0,mt
	addl $8,src
	addl $8,targ
	psrlq ish,mt
	movq ms,ms0
	psllq sh,ms
	pxor ms,mt
	movq mt,(targ)

mcloop1begin:
	testl len8,len8
	leal 8(src),src
	leal 8(targ),targ
	jz mcloop1end
	shrl $1,len8

mcloop1:
	movq (src),ms
	movq 8(src),msz
	movq ms0,mt
	movq ms,mtz
	psrlq ish,mt
	psrlq ish,mtz
	movq msz,ms0
	psllq sh,ms
	psllq sh,msz
	pxor ms,mt
	pxor msz,mtz
	movq mt,(targ)
	movq mtz,8(targ)
	decl len8
	leal 16(src),src
	leal 16(targ),targ
	jnz mcloop1

mcloop1end:
	psrlq ish,ms0
	movq ms0,(targ)

#  memcpy(mpqs3_tinyarray+2*mpqs3_tiny_prod,mpqs3_tinyarray,2*mpqs3_tiny_prod);

	movl ta,src
	movl len,len8
	movl len8,%ecx
	shrl $2,len8
	leal (src,len8,8),targ
	andl $3,%ecx     # shift in words
	shll $4,%ecx     # shift in bit
	movd %ecx,sh
	negl %ecx
	addl $64,%ecx
	movd %ecx,ish

	movq (src),ms
	movq (targ),mt
	movq ms,ms0
	psllq ish,mt
	psrlq ish,mt
	psllq sh,ms
	pxor ms,mt
	movq mt,(targ)
	testl $1,len8
	jz mcloop2begin
	decl len8
	movq 8(src),ms
	movq ms0,mt
	addl $8,src
	addl $8,targ
	psrlq ish,mt
	movq ms,ms0
	psllq sh,ms
	pxor ms,mt
	movq mt,(targ)

mcloop2begin:
	testl len8,len8
	leal 8(src),src
	leal 8(targ),targ
	jz mcloop2end
	shrl $1,len8

mcloop2:
	movq (src),ms
	movq 8(src),msz
	movq ms0,mt
	movq ms,mtz
	psrlq ish,mt
	psrlq ish,mtz
	movq msz,ms0
	psllq sh,ms
	psllq sh,msz
	pxor ms,mt
	pxor msz,mtz
	movq mt,(targ)
	movq mtz,8(targ)
	decl len8
	leal 16(src),src
	leal 16(targ),targ
	jnz mcloop2

mcloop2end:
	psrlq ish,ms0
	movq ms0,(targ)

#  memcpy(mpqs3_tinyarray+4*mpqs3_tiny_prod,mpqs3_tinyarray,4*mpqs3_tiny_prod);

	movl ta,src
	movl len,len8
	movl len8,%ecx
	shrl $1,len8
	leal (src,len8,8),targ
	andl $1,%ecx     # shift in ints
	shll $5,%ecx     # shift in bit
	movd %ecx,sh
	negl %ecx
	addl $64,%ecx
	movd %ecx,ish

	movq (src),ms
	movq (targ),mt
	movq ms,ms0
	psllq ish,mt
	psrlq ish,mt
	psllq sh,ms
	pxor ms,mt
	movq mt,(targ)
	testl $1,len8
	jz mcloop3begin
	decl len8
	movq 8(src),ms
	movq ms0,mt
	addl $8,src
	addl $8,targ
	psrlq ish,mt
	movq ms,ms0
	psllq sh,ms
	pxor ms,mt
	movq mt,(targ)

mcloop3begin:
	testl len8,len8
	leal 8(src),src
	leal 8(targ),targ
	jz mcloop3end
	shrl $1,len8

mcloop3:
	movq (src),ms
	movq 8(src),msz
	movq ms0,mt
	movq ms,mtz
	psrlq ish,mt
	psrlq ish,mtz
	movq msz,ms0
	psllq sh,ms
	psllq sh,msz
	pxor ms,mt
	pxor msz,mtz
	movq mt,(targ)
	movq mtz,8(targ)
	decl len8
	leal 16(src),src
	leal 16(targ),targ
	jnz mcloop3

mcloop3end:
	psrlq ish,ms0
	movq ms0,(targ)

#  memcpy(mpqs3_tinyarray+8*mpqs3_tiny_prod,mpqs3_tinyarray,8*mpqs3_tiny_prod);
#  memcpy(mpqs3_tinyarray+16*mpqs3_tiny_prod,mpqs3_tinyarray,16);
#  mask0=m64[0]; mask1=m64[1];
#  ullsv=(u64_t *)mpqs3_tinyarray;
#  ullsvend=ullsv+2*mpqs3_tiny_prod+2;
#  while (ullsv<ullsvend) {
#    *ullsv+++=mask0;
#    *ullsv+++=mask1;
#  }

	movl ta,src
	movl len,len8
	leal (src,len8,8),targ
	movl mask16,%eax
	movq (%eax),mt
	movq 8(%eax),mtz
# len8 must be odd
	movq (src),ms
	movq ms,ms0
	paddb mt,ms
	paddb mtz,ms0
	movq ms,(src)
	movq ms0,(targ)

	shrl $1,len8
	testl len8,len8
	leal 8(src),src
	leal 8(targ),targ
	jz mcloop4end

mcloop4:
	movq (src),ms
	movq 8(src),msz
	movq ms,ms0
	movq msz,ms0z
	paddb mtz,ms
	paddb mt,msz
	paddb mt,ms0
	paddb mtz,ms0z
	movq ms,(src)
	movq msz,8(src)
	movq ms0,(targ)
	movq ms0z,8(targ)
	decl len8
	leal 16(src),src
	leal 16(targ),targ
	jnz mcloop4

mcloop4end:
	movl ta,src
	movq (src),ms
	movq 8(src),msz
	movq ms,(targ)
	movq msz,8(targ)


	emms
	popl %edi
	popl %esi
	popl %ebx
	ret


