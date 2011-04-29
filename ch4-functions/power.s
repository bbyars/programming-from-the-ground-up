#Calculates 2^3 + 5^2

#Everything in the main program is stored in registers,
#so the data section doesn't have anything
.section .data

.section .text

.globl _start
_start:
pushl $0                # Push power (2nd arg)
pushl $2                # Push base (1st arg)
call power
addl $8, %esp           # Move the stack pointer back

pushl %eax              # Save first answer before calling next function

push $2
push $5
call power
addl $8, %esp

popl %ebx               # The 2nd answer is already in %eax
                        # We saved the first answer on the stack
addl %eax, %ebx         # Add them together; the result is in %ebx

movl $1, %eax           # exit (%ebx is returned)
int $0x80

# INPUT: 1st arg = base number
#        2nd arg = power to raise it to
# OUTPUT: the result
# VARIABLES:
#   %ebx - base number
#   %ecx - power
#   -4(%ebp) - current result
#   %eax = temporary storage
#
.type power, @function  # This tells the linker that the symbol power is a function
power:
  pushl %ebp            # save old base pointer
  movl %esp, %ebp       # make stack pointer the base pointer
  subl $4, %esp         # get room for our local storage

  movl 8(%ebp), %ebx    # put base in %ebx
  movl 12(%ebp), %ecx   # put power in %ecx

  movl $1, -4(%ebp)     # In case power is 0
  cmpl $0, %ecx         # if power is 0, return 1
  je end_power

  movl %ebx, -4(%ebp)   # store current result

power_loop_start:
  cmpl $1, %ecx         # if the power is 1, we are done
  je end_power
  movl -4(%ebp), %eax   # move the current result into %eax
  imull %ebx, %eax      # multiply the current result by the base number
  movl %eax, -4(%ebp)   # store the current result
  decl %ecx             # decrease the power
  jmp power_loop_start  # run for the next power

end_power:
  movl -4(%ebp), %eax   # return value goes into %eax
  movl %ebp, %esp       # restore the stack pointer
  popl %ebp             # restore the base pointer
  ret
