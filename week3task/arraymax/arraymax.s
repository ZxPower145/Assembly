.section .data
text1: .asciz "This application will calculate the max num from the following array: \n"
.set len1, . - text1
text2: .asciz "[18,2,36,1,86,42] \n"
.set len2, . - text2
output: .asciz "Max: "
.set lenOutput, . - output
newline: .asciz "\n"

.section .bss
.balign 8
max: .skip 8
buffer: .skip 12  # Buffer to hold the string representation of the maximum number

.section .data
numbers: .byte 18, 2, 36, 1, 86, 42
numCount = 6

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

# Function to convert integer to ASCII
_intToAscii:
    mov $0, %rcx         # Counter for digits
    mov $10, %rbx        # Base 10 divisor

convert_int_loop:
    xor %rdx, %rdx       # Clear dx for division
    div %rbx             # Divide rax by rbx, remainder in rdx, quotient in rax
    add $'0', %dl        # Convert remainder to ASCII digit
    push %rdx            # Push ASCII digit to stack
    inc %rcx             # Increment digit counter
    test %rax, %rax      # Check if quotient is zero
    jnz convert_int_loop # If not, continue conversion

print_digits_loop:
    pop %rax             # Pop ASCII digit from stack
    mov %al, (%rsi)      # Store ASCII digit in result buffer
    inc %rsi             # Move to next position in buffer
    loop print_digits_loop

    ret
    
# Function to print the maximum number
_printMax:
    # Print the "Max: " prefix
    mov $1, %rax
    mov $1, %rdi
    lea output(%rip), %rsi
    mov $lenOutput, %rdx
    syscall

    # Convert max to ASCII and print it
    mov max(%rip), %edi          # Load the maximum number into edi
    lea buffer(%rip), %rsi       # Load buffer address into rsi
    call _intToAscii             # Convert integer to ASCII

    # Print the converted ASCII number
    mov $1, %rax
    mov $1, %rdi
    lea buffer(%rip), %rsi
    mov $12, %rdx                # Assume maximum length of 12 digits
    syscall

    # Print the newline character
    mov $1, %rax
    mov $1, %rdi
    lea newline(%rip), %rsi
    mov $1, %rdx
    syscall

    ret

