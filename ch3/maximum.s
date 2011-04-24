#PURPOSE:   This program finds the maximum number of a
#           set of data items.

#VARIABLES: The registers have the following uses:
#
# %edi - Holds thi index of the data item being examined
# %ebx - Largest data item found
# %eax - Current data item
#
# The following memory locations are used:
#
# data_items - contains the item data.  A 0 is used
#              to terminate the data
#

.section .data

data_items:
 .long 3,67,34,222,45,75,54,34,44,33,22,11,66,0

.section .text

.globl _start
_start:
 movl $0, %edi                      # Move 0 into index register
 movl data_items(,%edi,4), %eax     # Load first byte of data
 movl %eax, %ebx                    # Since this is the first item, %eax is
                                    # the biggest

start_loop:
 cmpl $0, %eax                      # Looks for sentinel value to end loop
 je loop_exit
 incl %edi                          # Load next value
 movl data_items(,%edi,4), %eax     # Load next value
 cmpl %ebx, %eax                    # Compare values
 jle start_loop                     # Jump if new value <=
 movl %eax, %ebx                    # Else record new biggest
 jmp start_loop

loop_exit:
 # %ebx is status code for exit system call
 # and it already has the maximum number
 movl $1, %eax                      # 1 is the exit() syscall
 int $0x80
