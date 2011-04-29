#Calculates 7!

.section .data

.section .text

.globl _start
_start:
push $5                     # push argument
call factorial
addl $4, %esp               # restore stack

movl %eax, %ebx             # make result exit code
movl $1, %eax               # code for kernel exit function
int $0x80

# INPUT: (number)
# OUTPUT: number!
# VARIABLES:
#   8(%ebp) = number to decrement per factorial
#  (4(%ebp) = return address)
#   %eax = working result
#
.type factorial, @function
factorial:
  pushl %ebp                # save old base pointer
  movl %esp, %ebp           # copy stack pointer to base pointer

  movl $1, %eax             # result for 0! and 1!

factorial_loop_start:
  cmpl $1, 8(%ebp)         # loop until <= 1
  jle end_factorial
  imull 8(%ebp), %eax      # do the multiplication
  decl 8(%ebp)             # decrement the loop counter
  jmp factorial_loop_start

end_factorial:
  movl %ebp, %esp           # restore stack pointer
  popl %ebp                 # restore base pointer
  ret
