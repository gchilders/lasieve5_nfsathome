# Copyright (C) 2002 Jens Franke, T.Kleinjung
# This file is part of gnfs4linux, distributed under the terms of the
# GNU General Public Licence and WITHOUT ANY WARRANTY.

# You should have received a copy of the GNU General Public License along
# with this program; see the file COPYING.  If not, write to the Free
# Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
# 02111-1307, USA.

# Written by T. Kleinjung

.comm mpqs_nFBk_1,2
.comm mpqs_td_begin,2
.comm mpqs_sievebegin,2
.comm mpqs_FB_inv_info,4
.comm mpqs_FB,4
.comm mpqs_FB_start,4
.comm mpqs_sievearray,4
.comm mpqs_sievelen,4
.comm mpqs_FB_log,4
.comm mpqs_FB0,4



# 4(%esp)  mpqs_FB-ptr
# 8(%esp)  mpqs_FB_start-ptr
# 12(%esp) mpqs_FB_log-ptr
# 16(%esp) mpqs_sievelen/4


function_head(asm_sieve)
	pushl %edi
	pushl %esi
	pushl %ebx
	pushl %ebp

	subl $20,%esp

	movl $mpqs_FB,%eax
	movzwl mpqs_sievebegin,%ebx
	addl %ebx,%ebx
	addl %ebx,%ebx
	addl %ebx,%eax
	movl %eax,4(%esp)

	movl $mpqs_FB_start,%eax
	addl %ebx,%eax
	movl %eax,8(%esp)

	movl $mpqs_FB_log,%eax
	movzwl mpqs_sievebegin,%ebx
	addl %ebx,%eax
	movl %eax,12(%esp)

	movl mpqs_sievelen,%eax
	shrl $2,%eax
	movl %eax,16(%esp)

mainloop:
	movl 4(%esp),%esi
	movzwl (%esi),%ecx   # p
	cmpl %ecx,16(%esp)
	leal 4(%esi),%esi
	movl %esi,4(%esp)
	jc end

	movl 8(%esp),%esi
	movzwl (%esi),%ebp   # s1
	movzwl 2(%esi),%edi  # s2
	leal 4(%esi),%esi
	cmpl %ebp,%edi
	movl %ebp,%ebx
	movl %edi,%edx
	cmovcl %edi,%ebx     # min(s1,s2)
	cmovcl %ebp,%edx     # max(s1,s2)
	movl %esi,8(%esp)

	movl 12(%esp),%esi
	movb (%esi),%al      # lo
	leal 1(%esi),%esi
	movl %esi,12(%esp)

	movl mpqs_sievearray,%edi
	movl mpqs_sievelen,%esi
	subl %edx,%ebx
	addl %edi,%esi
	addl %edx,%edi
	movl %ebx,%ebp
	leal (%ecx,%ecx,2),%ebx
	addl %edi,%ebp
	subl %ebx,%esi

loop4:
	addb %al,(%edi)
	addb %al,(%ebp)
	addb %al,(%edi,%ecx)
	addb %al,(%ebp,%ecx)
	addb %al,(%edi,%ecx,2)
	addb %al,(%ebp,%ecx,2)
	addb %al,(%edi,%ebx)
	addb %al,(%ebp,%ebx)
	leal (%edi,%ecx,4),%edi
	leal (%ebp,%ecx,4),%ebp
	cmpl %esi,%edi
	jc loop4

	addl %ecx,%esi
	addl %ecx,%esi
	cmpl %esi,%edi
	jnc check
	addb %al,(%edi)
	addb %al,(%ebp)
	addb %al,(%edi,%ecx)
	addb %al,(%ebp,%ecx)
	leal (%edi,%ecx,2),%edi
	leal (%ebp,%ecx,2),%ebp
check:
	addl %ecx,%esi
	cmpl %esi,%edi
	jnc check1
	addb %al,(%edi)
	addb %al,(%ebp)
	addl %ecx,%ebp
check1:
	cmpl %esi,%ebp
	jnc mainloop
	addb %al,(%ebp)

	jmp mainloop


end:
        addl $20,%esp
	popl %ebp
	popl %ebx
	popl %esi
	popl %edi
	ret



# 4(%esp)  mpqs_FB-ptr
# 8(%esp)  mpqs_FB_start-ptr
# 12(%esp) mpqs_FB_log-ptr
# 16(%esp) mpqs_sievelen/4 or mpqs_sievelen/3


function_head(asm_sievea)
	pushl %edi
	pushl %esi
	pushl %ebx
	pushl %ebp

	subl $20,%esp

	movl $mpqs_FB_start,%eax
	movzwl mpqs_sievebegin,%ebx
	addl %ebx,%ebx
	addl %ebx,%ebx
	addl %ebx,%eax
	movl %eax,8(%esp)
	movl $mpqs_FB0,%eax
	movl %eax,4(%esp)

#.align 16
mainloop8a:
	movl 4(%esp),%esi
	movzwl (%esi),%ecx   # p
	testl %ecx,%ecx
	leal 2(%esi),%esi
	jz update8a
return8a:
	movl %esi,4(%esp)

	movl 8(%esp),%esi
	movzwl (%esi),%ebp   # s1
	movzwl 2(%esi),%edi  # s2
	leal 4(%esi),%esi
	cmpl %ebp,%edi
	movl %ebp,%ebx
	movl %edi,%edx
	cmovcl %edi,%ebx     # min(s1,s2)
	cmovcl %ebp,%edx     # max(s1,s2)
	movl %esi,8(%esp)

	movl mpqs_sievearray,%edi
	movl mpqs_sievelen,%esi
	subl %edx,%ebx
	addl %edi,%esi
	addl %edx,%edi
	movl %ebx,%ebp
	leal (%ecx,%ecx,2),%ebx
	addl %edi,%ebp
	subl %ebx,%esi

loop8a:
	addb %al,(%edi)
	addb %al,(%ebp)
	addb %al,(%edi,%ecx)
	addb %al,(%ebp,%ecx)
	addb %al,(%edi,%ecx,2)
	addb %al,(%ebp,%ecx,2)
	addb %al,(%edi,%ebx)
	addb %al,(%ebp,%ebx)
	leal (%edi,%ecx,4),%edi
	leal (%ebp,%ecx,4),%ebp
	cmpl %esi,%edi
	jc loop8a

	addl %ecx,%esi
	addl %ecx,%esi
	cmpl %esi,%edi
	jnc check8a
	addb %al,(%edi)
	addb %al,(%ebp)
	addb %al,(%edi,%ecx)
	addb %al,(%ebp,%ecx)
	leal (%edi,%ecx,2),%edi
	leal (%ebp,%ecx,2),%ebp
check8a:
	addl %ecx,%esi
	cmpl %esi,%edi
	jnc check81a
	addb %al,(%edi)
	addb %al,(%ebp)
	addl %ecx,%ebp
check81a:
	cmpl %esi,%ebp
	cmovncl %esi,%ebp
	addb %al,(%ebp)
	jmp mainloop8a

update8a:
	movzwl (%esi),%ecx
        testl %ecx,%ecx
        leal 2(%esi),%esi
        jz loop4begina
	movb %cl,%al
	movzwl (%esi),%ecx    # p
	leal 2(%esi),%esi
	jmp return8a

loop4begina:
	movl %esi,4(%esp)

	movl mpqs_sievearray,%edi
	movl mpqs_sievelen,%ebp

mainloop4a:
	movl 4(%esp),%esi
	movzwl (%esi),%ecx   # p
	testl %ecx,%ecx
	leal 2(%esi),%esi
	jz update4a
return4a:
	movl %esi,4(%esp)

	movl 8(%esp),%esi
	movzwl (%esi),%ebx   # s1
	movzwl 2(%esi),%edx  # s2
	leal 4(%esi),%esi
	movl %esi,8(%esp)

	addb %al,(%edi,%ebx)
	addb %al,(%edi,%edx)
	addl %ecx,%ebx
	addl %ecx,%edx
	addb %al,(%edi,%ebx)
	addb %al,(%edi,%edx)
	addl %ecx,%ebx
	addl %ecx,%edx

	movl %ebx,%esi
	cmpl %edx,%ebx
	cmovncl %edx,%esi

	addb %al,(%edi,%ebx)
	addb %al,(%edi,%edx)
	addl %ecx,%ebx
	addl %ecx,%edx
	addb %al,(%edi,%ebx)
	addb %al,(%edi,%edx)
	addl %ecx,%ebx
	addl %ecx,%edx

	leal (%esi,%ecx,4),%esi  # min(ebx,edx)+2*ecx
	cmpl %ebp,%esi
	jnc checka
	addb %al,(%edi,%ebx)
	addb %al,(%edi,%edx)
	addl %ecx,%ebx
	addl %ecx,%edx
	addb %al,(%edi,%ebx)
	addb %al,(%edi,%edx)
	addl %ecx,%ebx
	addl %ecx,%edx
	leal (%esi,%ecx,2),%esi
checka:
	sub %ecx,%esi
	cmpl %ebp,%esi
	jnc check1a
	addb %al,(%edi,%ebx)
	addb %al,(%edi,%edx)
	addl %ecx,%ebx
	addl %ecx,%edx
check1a:
	cmpl %ebp,%ebx
	cmovncl %ebp,%ebx
	cmpl %ebp,%edx
	cmovncl %ebp,%edx

	addb %al,(%edi,%ebx)
	addb %al,(%edi,%edx)
        jmp mainloop4a
update4a:
	movzwl (%esi),%ecx
        testl %ecx,%ecx
        jz loop3begina
	movb %cl,%al
	movzwl 2(%esi),%ecx    # p
	leal 4(%esi),%esi
	jmp return4a



loop3begina:
        leal 2(%esi),%esi
	movl %esi,4(%esp)

.IF 1
	movl mpqs_sievelen,%ebp
	movl mpqs_sievearray,%edi

	movl 4(%esp),%esi
	movl 8(%esp),%edx
mainloop3a:
	movzwl (%esi),%ecx   # p
	testl %ecx,%ecx
	leal 2(%esi),%esi
	jz update3a
return3a:
	movzwl (%edx),%ebx

	addb %al,(%edi,%ebx)
	addl %ecx,%ebx
	addb %al,(%edi,%ebx)
	addl %ecx,%ebx
	addb %al,(%edi,%ebx)
	addl %ecx,%ebx
	cmpl %ebp,%ebx
	cmovncl %ebp,%ebx
	addb %al,(%edi,%ebx)

	movzwl 2(%edx),%ebx
	addb %al,(%edi,%ebx)
	addl %ecx,%ebx
	addb %al,(%edi,%ebx)
	addl %ecx,%ebx
	addb %al,(%edi,%ebx)
	addl %ecx,%ebx
	cmpl %ebp,%ebx
	cmovncl %ebp,%ebx
	addb %al,(%edi,%ebx)

	leal 4(%edx),%edx
loopend3a:
	jmp mainloop3a
update3a:
	movzwl (%esi),%ecx
        testl %ecx,%ecx
        jz loop2begina
	movb %cl,%al
	movzwl 2(%esi),%ecx    # p
	leal 4(%esi),%esi
	jmp return3a

loop2begina:
        leal 2(%esi),%esi
	movl %esi,4(%esp)
	movl %edx,8(%esp)
.ENDIF
.IF 1
	movl mpqs_sievelen,%ebp
	movl mpqs_sievearray,%edi

mainloop2a:
	movzwl (%esi),%ecx   # p
	testl %ecx,%ecx
	leal 2(%esi),%esi
	jz update2a
return2a:
	movzwl (%edx),%ebx
	addb %al,(%edi,%ebx)
	addl %ecx,%ebx
	addb %al,(%edi,%ebx)
	addl %ecx,%ebx
	cmpl %ebp,%ebx
	cmovncl %ebp,%ebx
	addb %al,(%edi,%ebx)

	movzwl 2(%edx),%ebx
	addb %al,(%edi,%ebx)
	addl %ecx,%ebx
	addb %al,(%edi,%ebx)
	addl %ecx,%ebx
	cmpl %ebp,%ebx
	cmovncl %ebp,%ebx
	addb %al,(%edi,%ebx)

	leal 4(%edx),%edx
loopend2a:
	jmp mainloop2a
update2a:
	movzwl (%esi),%ecx
        testl %ecx,%ecx
        jz loop1begina
	movb %cl,%al
	movzwl 2(%esi),%ecx    # p
	leal 4(%esi),%esi
	jmp return2a

loop1begina:
        leal 2(%esi),%esi
	movl %esi,4(%esp)
	movl %edx,8(%esp)
.ENDIF

.IF 1
mainloop1a:
	movzwl (%esi),%ecx   # p
	testl %ecx,%ecx
	leal 2(%esi),%esi
	jz update1a
return1a:
	movzwl (%edx),%ebx
	addb %al,(%edi,%ebx)
	addl %ecx,%ebx
	cmpl %ebp,%ebx
	cmovncl %ebp,%ebx
	addb %al,(%edi,%ebx)

	movzwl 2(%edx),%ebx
	addb %al,(%edi,%ebx)
	addl %ecx,%ebx
	cmpl %ebp,%ebx
	cmovncl %ebp,%ebx
	addb %al,(%edi,%ebx)

	leal 4(%edx),%edx
	jmp mainloop1a
update1a:
	movzwl (%esi),%ecx
        testl %ecx,%ecx
        jz loop0begina
	movb %cl,%al
	movzwl 2(%esi),%ecx    # p
	leal 4(%esi),%esi
	jmp return1a

loop0begina:
        leal 2(%esi),%esi
	movl %esi,4(%esp)
	movl %edx,8(%esp)

mainloop0a:
	movzwl (%esi),%ecx   # p
	testl %ecx,%ecx
	leal 2(%esi),%esi
	jz update0a
return0a:
	movzwl (%edx),%ebx
	movzwl 2(%edx),%ecx
	cmpl %ebp,%ebx
	cmovncl %ebp,%ebx
	cmpl %ebp,%ecx
	cmovncl %ebp,%ecx
	addb %al,(%edi,%ebx)
	addb %al,(%edi,%ecx)
	leal 4(%edx),%edx
	jmp mainloop0a
update0a:
	movzwl (%esi),%ecx
        testl %ecx,%ecx
        jz loopmbegina
	movb %cl,%al
	movzwl 2(%esi),%ecx    # p
	leal 4(%esi),%esi
	jmp return0a

loopmbegina:
        leal 2(%esi),%esi
	movl %esi,4(%esp)
	movl %edx,8(%esp)
.ENDIF

enda:
        addl $20,%esp
	popl %ebp
	popl %ebx
	popl %esi
	popl %edi
	ret
