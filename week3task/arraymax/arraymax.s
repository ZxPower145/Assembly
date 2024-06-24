.section .data
text1: .asciz "This application will calculate the max num from the following array: \n"
.set len1, . - text1
text2: .asciz "[18,2,36,1,86,42] \n"
.set len2, . - text2
numbers: .byte 18, 2, 36, 1, 86, 42
numCount = 6
newline: .asciz "\n"
output: .asciz "Max: "
.set lenOutput, . - output

.section .bss
.balign 4
max: .skip 4
buffer: .skip 12  # Buffer to hold the string representation of the maximum number

.section .text
.globl _start

_start:
    # Print the prompt and the array
    call _printText1
    call _printText2

    # Calculate the maximum number
    call _calculateMax

    # Print the maximum number
    call _printMax

    # Exit the program
    mov $60, %rax
    xor %rdi, %rdi
    syscall

# Function to print text1
_printText1:
    mov $1, %rax
    mov $1, %rdi
    lea text1(%rip), %rsi
    mov $len1, %rdx
    syscall
    ret

# Function to print text2
_printText2:
    mov $1, %rax
    mov $1, %rdi
    lea text2(%rip), %rsi
    mov $len2, %rdx
    syscall
    ret

# Function to calculate the maximum number from the array
_calculateMax:
    lea numbers(%rip), %rsi      # Load the base address of numbers into rsi
    movb (%rsi), %al             # Load the first byte of numbers into al
    movzbl %al, %eax             # Zero-extend al to eax to use as the current max
    mov $1, %ebx                 # Initialize ebx (index) to 1

find_max_loop:
    cmp $numCount, %ebx          # Compare numCount to ebx
    jge not_bigger               # If ebx >= numCount, we are done

    movzbl (%rsi,%rbx,1), %ecx   # Load the next byte from numbers into ecx
    cmp %ecx, %eax               # Compare ecx to eax (current max)
    jle next_num                 # If current number <= max, go to next number

    mov %ecx, %eax               # Update max with current number

next_num:
    inc %ebx                     # Increment index
    jmp find_max_loop            # Loop again

not_bigger:
    mov %eax, max(%rip)          # Store the maximum value in max
    ret                          # Return from _calculateMax

# Function to convert integer to string
_intToStr:
    mov $buffer+11, %rdi         # Set rdi to end of buffer
    mov %edi, %eax               # Move the integer to eax
    mov $10, %ebx                # Base 10
    xor %ecx, %ecx               # Clear ecx for digit count

.convert_loop:
    xor %edx, %edx               # Clear edx
    div %ebx                     # Divide eax by 10, quotient in eax, remainder in edx
    add $'0', %dl                # Convert remainder to ASCII
    dec %rdi                     # Move backward in buffer
    mov %dl, (%rdi)              # Store the digit
    inc %ecx                     # Increment digit count
    test %eax, %eax              # Check if quotient is 0
    jnz .convert_loop            # If not, continue loop

    lea buffer(%rip), %rsi       # Load the buffer address
    add $12, %rsi                # Adjust to the end of the buffer
    sub %ecx, %esi               # Calculate the start of the number string
    ret                          # Return with rsi pointing to the start of the number string

# Function to print the maximum number
_printMax:
    mov $1, %eax                 # syscall number for sys_write
    mov $1, %edi                 # file descriptor 1 (stdout)
    lea output(%rip), %rsi       # Load effective address of output
    mov $lenOutput, %edx         # Length of output string
    syscall                      # Invoke syscall to print output

    mov max(%rip), %edi          # Load the maximum number into edi
    call _intToStr               # Convert integer to string

    mov $1, %eax                 # syscall number for sys_write
    mov $1, %edi                 # file descriptor 1 (stdout)
    mov %rdi, %rsi               # Load the string address
    mov $12, %edx                # Length of the string (max 12 bytes)
    syscall                      # Invoke syscall to print

    lea newline(%rip), %rsi      # Load newline address
    mov $1, %edx                 # Length of newline (1 byte)
    syscall                      # Invoke syscall to print newline

    ret                          # Return from _printMax
