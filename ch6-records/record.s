.include "record-def.s"
.include "linux.s"

# PURPOSE: Reads a record from a file descriptor
#
# INPUT: The file descriptor and a buffer
#
# OUTPUT: Writes data to the buffer and returns status code

# STACK LOCAL VARIABLES:
.equ ST_READ_BUFFER, 8
.equ ST_FILEDEFS, 12

.section .text
.globl read_record
.type read_record, @function
read_record:
  pushl %ebp
  movl %esp, %ebp

  pushl %eb
  movl ST_FILEDEFS(%ebp), %ebx
  movl ST_READ_BUFFER(%ebp), %ecx
  movl $RECORD_SIZE, %edx
  movl $SYS_READ, %eax
  int $LINUX_SYSCALL

  # Note - %eax has the return value, which we pass on
  popl %ebx

  movl %ebp, %esp
  popl %ebp
  ret
