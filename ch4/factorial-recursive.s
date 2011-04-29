# PURPOSE: Compute factorial

.section .data
# This program has no global data

.section .text

.globl _start
.globl factorial # this is unneeded unless we want to share with other programs

_start:
  pushl $4              # push argument
  call factorial
  addl $4, %esp         # restore stack

  movl %eax, %ebx       # make result exit status
  movl $1, %eax         # call kernel's exit function
  int $0x80

.type factorial, @function
factorial:
  pushl %ebp            # save off %ebp so we can restore later
  movl %esp, %ebp       # use %ebp instead of stack pointer
  movl 8(%ebp), %eax    # moves argument to %eax
                        # 4(%ebp) holds return address
  cmpl $1, %eax         # exit case
  je end_factorial
  decl %eax             # otherwise, decrement value
  pushl %eax            # push it as argument for recursive call
  call factorial
  movl 8(%ebp), %ebx    # %eax has return value, so we reload
                        # our parameter into %ebx
  imull %ebx, %eax      # multiply that by the result of the last call

end_factorial:
  movl %ebp, %esp       # restore %ebp and %esp
  popl %ebp
  ret
