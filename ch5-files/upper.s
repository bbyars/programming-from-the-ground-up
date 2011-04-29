# PURPOSE: Converts input file to output file with all letters uppercased
# PROCESSING: 1) open input file
#             2) open output file
#             3) while not at input EOF:
#               a) read part of file into memory buffer
#               b) convert each byte to upper
#               c) write memory buffer to output file

.section .data

####CONSTANTS####

# system call numbers
.equ SYS_OPEN, 5
.equ SYS_WRITE, 4
.equ SYS_READ, 3
.equ SYS_CLOSE, 6
.equ SYS_EXIT, 1

# options for open (look at /usr/include/asm/fcntl.h for values)
.equ O_RDONLY, 0
.equ O_CREAT_WRONLY_TRUNC, 03101

# standard file descriptors
.equ STDIN, 0
.equ STDOUT, 1
.equ STDERR, 2

# system call interrupt
.equ LINUX_SYSCALL, 0x80

.equ EOF, 0     # return value of read
.equ ARGC, 2


.section .bss
# Buffer - this is where the data is loaded into from the data file and
#          written from into the input file.  This should never exceed
#          16,000 for various reasons
.equ BUFFER_SIZE, 500
.lcomm BUFFER_DATA, BUFFER_SIZE


.section .text

# STACK POSITIONS
.equ ST_SIZE_RESERVE, 8
.equ ST_FD_IN, -4
.equ ST_FD_OUT, -8
.equ ST_ARGC, 0
.equ ST_ARGV_0, 4           # name of program
.equ ST_ARGV_1, 8           # name of input file
.equ ST_ARGV_2, 12          # name of output file

.globl _start
_start:
  ####INITIALIZE PROGRAM####
  # save the stack pointer
  movl %esp, %ebp

  # Allocate space for file descriptors on the stack
  subl $ST_SIZE_RESERVE, %esp

open_files:
open_fd_in:
  # open syscall
  movl $SYS_OPEN, %eax
  movl ST_ARGV_1(%ebp), %ebx        # input filename into %ebx
  movl $O_RDONLY, %ecx              # read/write flags into %ecx
  movl $0666, %edx                  # permissions into %edx
  int $LINUX_SYSCALL

store_fd_in:
  movl %eax, ST_FD_IN(%ebp)         # store file descriptor here

open_fd_out:
  # open the file
  movl $SYS_OPEN, %eax
  movl ST_ARGV_2(%ebp), %ebx        # filename into %ebx
  movl $O_CREAT_WRONLY_TRUNC, %ecx  # read/write flags into %ecx
  movl $0666, %edx                  # mode into %edx
  int $LINUX_SYSCALL

store_fd_out:
  movl %eax, ST_FD_OUT(%ebp)        # store the file descriptor here

read_loop_begin:
  # read in a block from the input file
  movl $SYS_READ, %eax
  movl ST_FD_IN(%ebp), %ebx         # get input file descriptor
  movl $BUFFER_DATA, %ecx           # the location to read into
  movl $BUFFER_SIZE, %edx
  int $LINUX_SYSCALL                # size of buffer read is returned in %eax

  cmpl $EOF, %eax
  jle end_loop                      # if EOF or error

continue_read_loop:
  # convert block to upper case
  pushl $BUFFER_DATA                # location of buffer
  pushl %eax                        # size of buffer
  call convert_to_upper
  popl %eax                         # get the size back
  addl $4, %esp                     # restore %esp

  # write block out to output file
  movl %eax, %edx                   # size of bufer
  movl $SYS_WRITE, %eax
  movl ST_FD_OUT(%ebp), %ebx        # file to use
  movl $BUFFER_DATA, %ecx           # location of buffer
  int $LINUX_SYSCALL

  jmp read_loop_begin

end_loop:
  # close the files
  # no need to do error checking, because error conditions dont' signify anything special here
  movl $SYS_CLOSE, %eax
  movl ST_FD_OUT(%ebp), %ebx
  int $LINUX_SYSCALL

  movl $SYS_CLOSE, %eax
  movl ST_FD_IN(%ebp), %ebx
  int $LINUX_SYSCALL

  # exit
  movl $SYS_EXIT, %eax
  movl $0, %ebx
  int $LINUX_SYSCALL


# PURPOSE: Converts to upper case
# INPUT: (location to buffer, length of buffer)
# OUTPUT: overwrites buffer with upper-cased version
# VARIABLES:
#   %eax - beginning of buffer
#   %ebx - length of buffer
#   %edi - current buffer offset
#   %cl - current byte being examined (first part of %ecx)

# constants
.equ LOWERCASE_A, 'a'           # lower bound of our search
.equ LOWERCASE_Z, 'z'           # upper bound of our search
.equ UPPER_CONVERSION, 'A' - 'a'

#  stack stuff
.equ ST_BUFFER_LEN, 8           # length of buffer
.equ ST_BUFFER, 12              # actual buffer

convert_to_upper:
  pushl %ebp
  movl %esp, %ebp

  # set up variables
  movl ST_BUFFER(%ebp), %eax
  movl ST_BUFFER_LEN(%ebp), %ebx
  movl $0, %edi

  # if a 0-length buffer was given to us, just leave
  cmpl $0, %ebx
  je end_convert_loop

convert_loop:
  movb (%eax,%edi,1), %cl       # get current byte

  # go to next byte unless it is between 'a' and 'z'
  cmpb $LOWERCASE_A, %cl
  jl next_byte
  cmpb $LOWERCASE_Z, %cl
  jg next_byte

  # otherwise convert the byte to uppercase
  addb $UPPER_CONVERSION, %cl
  movb %cl, (%eax,%edi,1)       # store it back

next_byte:
  incl %edi
  cmpl %edi, %ebx
  jne convert_loop

end_convert_loop:
  # no return value, just leave
  movl %ebp, %esp
  popl %ebp
  ret
