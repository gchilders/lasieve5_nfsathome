# Copyright (C) 2002 Jens Franke, T.Kleinjung
# This file is part of gnfs4linux, distributed under the terms of the
# GNU General Public Licence and WITHOUT ANY WARRANTY.

# You should have received a copy of the GNU General Public License along
# with this program; see the file COPYING.  If not, write to the Free
# Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
# 02111-1307, USA.

.comm mpqs_gauss_k,4
.comm mpqs_gauss_m,4
.comm mpqs_gauss_row,4
.comm mpqs_gauss_c,4
.comm mpqs_gauss_d,4
.comm mpqs_gauss_n32,4
.comm mpqs_gauss_mat,4
.comm mpqs_gauss_col,4
.comm mpqs_gauss_j,4



define(`tmp_j',4(%esp))dnl
define(`k32',8(%esp))dnl


divert
function_head(asm_gauss)
	pushl %edi
	pushl %esi
	pushl %ebx
	pushl %ebp
	subl $20,%esp

whileloop:
	movl mpqs_gauss_k,%eax
	decl %eax
	movl $1,%ebp
	movl %eax,mpqs_gauss_k
	jl end
	movl %eax,%ecx
	andl $31,%ecx
	shll %cl,%ebp
	movl %eax,%ecx
	shrl $5,%ecx      # k32
	movl %ecx,k32

# find j:
	movl mpqs_gauss_j,%ecx
	movl $mpqs_gauss_c,%edi
 
	movl mpqs_gauss_row,%esi
	movl (%esi,%ecx,4),%esi
	movl k32,%eax
	subl mpqs_gauss_n32,%eax
	leal (%esi,%eax,4),%esi
	decl %ecx
	movl mpqs_gauss_n32,%eax

.align 16 
loopj:        # ? cycles per iteration
	incl %ecx
entryj:
        cmpl mpqs_gauss_m,%ecx
        jnc  end_of_loop
	leal (%esi,%eax,4),%esi
	movl (%esi),%edx
	andl %ebp,%edx
	jz loopj

endj:       # j in %ecx

	cmpl mpqs_gauss_j,%ecx
	jz noxch_j
# exchange rows j and mpqs_gauss_j: uses %eax, %esi, %ebx, %edx

	movl mpqs_gauss_row,%esi
	movl (%esi,%ecx,4),%eax    # mpqs_gauss_row[j]
	movl mpqs_gauss_j,%edx
	movl (%esi,%edx,4),%ebx    # mpqs_gauss_row[mpqs_gauss_j]
	xorl %edx,%edx
xch_loop:
	movq (%eax,%edx,4),%mm0
	movq (%ebx,%edx,4),%mm1
	movq %mm0,(%ebx,%edx,4)
	movq %mm1,(%eax,%edx,4)
	addl $2,%edx
	cmpl mpqs_gauss_n32,%edx
	jc xch_loop

xch_loop_end:
	movl mpqs_gauss_j,%ecx
noxch_j:
	movl $mpqs_gauss_d,%esi
	movl mpqs_gauss_k,%eax
	movw %cx,(%esi,%eax,2)
	movw %ax,(%edi,%ecx,2)

# update mpqs_gauss_j:
	incl mpqs_gauss_j
	movl %ecx,tmp_j

	movl tmp_j,%ecx
	movl mpqs_gauss_mat,%esi
	movl $mpqs_gauss_col,%edi
	movl k32,%edx
	testl %ecx,%ecx
	movl mpqs_gauss_n32,%eax
	leal (%esi,%edx,4),%esi
	movl $2,%edx
	jz searchloopAend
	xorl %ecx,%ecx
.align 16
searchloopA:
	movl (%esi),%ebx
	andl %ebp,%ebx
	movl $0,%ebx
	movw %cx,(%edi)
	cmovnzl %edx,%ebx
	incl %ecx
	addl %ebx,%edi
	cmpl tmp_j,%ecx
	leal (%esi,%eax,4),%esi
	jc searchloopA

searchloopAend:
	incl %ecx
	cmpl mpqs_gauss_m,%ecx
	leal (%esi,%eax,4),%esi
	jnc searchloopBend
.align 16
searchloopB:
	movl (%esi),%ebx
	andl %ebp,%ebx
	movl $0,%ebx
	movw %cx,(%edi)
	cmovnzl %edx,%ebx
	incl %ecx
	addl %ebx,%edi
	cmpl mpqs_gauss_m,%ecx
	leal (%esi,%eax,4),%esi
	jc searchloopB

searchloopBend:
	movl $mpqs_gauss_col,%ebp
	cmpl %ebp,%edi
	jz whileloop
	movl tmp_j,%ecx
	movl mpqs_gauss_row,%esi
	movl (%esi,%ecx,4),%esi

	movl k32,%edx
	cmpl $2,%edx
	jc entry1
	cmpl $4,%edx
	jc entry2
	cmpl $6,%edx
	jc entry3
# generic code for >192 bit
.align 16
outerloop0:
	movzwl (%ebp),%ebx
	movl mpqs_gauss_row,%eax
	movl (%eax,%ebx,4),%eax
	xorl %ecx,%ecx
innerloop0:
	movl (%esi,%ecx,4),%edx
	xorl %edx,(%eax,%ecx,4)
	incl %ecx
	cmpl %ecx,k32
	jnc innerloop0

	leal 2(%ebp),%ebp
	cmpl %edi,%ebp
	jc outerloop0


	jmp whileloop



end:
	movl tmp_j,%eax
	emms
	addl $20,%esp
	popl %ebp
	popl %ebx
	popl %esi
	popl %edi
	ret

end_of_loop:
	movl $mpqs_gauss_d,%edi
	movl mpqs_gauss_k,%eax
	movw $-1,%bx
	movw %bx,(%edi,%eax,2)
	movl %ecx,tmp_j
	jmp end

# code for length <=64 bit
entry1:
	movzwl (%ebp),%ebx
	movq (%esi),%mm0
	movl mpqs_gauss_row,%esi
	movl (%esi,%ebx,4),%eax
outerloop1:
	movq (%eax),%mm1
	leal 2(%ebp),%ebp
	movzwl (%ebp),%ebx
	pxor %mm0,%mm1
	cmpl %edi,%ebp
	movq %mm1,(%eax)
	movl (%esi,%ebx,4),%eax
	jc outerloop1
	jmp whileloop

# code for length <=128 bit
entry2:
	movq (%esi),%mm0
	movzwl (%ebp),%ebx
	movq 8(%esi),%mm2
	movl mpqs_gauss_row,%esi
	movl (%esi,%ebx,4),%eax
outerloop2:
	movq (%eax),%mm1
	leal 2(%ebp),%ebp
	movq 8(%eax),%mm3
	pxor %mm0,%mm1
	movzwl (%ebp),%ebx
	pxor %mm2,%mm3
	cmpl %edi,%ebp
	movq %mm1,(%eax)
	movq %mm3,8(%eax)
	movl (%esi,%ebx,4),%eax
	jc outerloop2
	jmp whileloop

# code for length <=192 bit
entry3:
	movq (%esi),%mm0
	movzwl (%ebp),%ebx
	movq 8(%esi),%mm2
	movq 16(%esi),%mm4
	movl mpqs_gauss_row,%esi
	movl (%esi,%ebx,4),%eax
outerloop3:
	  movq (%eax),%mm1
	leal 2(%ebp),%ebp
	    movq 8(%eax),%mm3
	  pxor %mm0,%mm1
	      movq 16(%eax),%mm5
	movzwl (%ebp),%ebx
	    pxor %mm2,%mm3
	  movq %mm1,(%eax)
	      pxor %mm4,%mm5
	    movq %mm3,8(%eax)
	cmpl %edi,%ebp
	      movq %mm5,16(%eax)
	movl (%esi,%ebx,4),%eax
	jc outerloop3
	jmp whileloop

