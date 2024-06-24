.section .data
text1: .asciz "Type in a number to calculate its factorial? \n"
.set len1, . - text1
text2: .asciz "The factorial is: \n"
.set len2, . - text2
newline: .asciz "\n"

.section .bss
.balign 4
num1: .skip 4
.balign 8
result: .skip 8

.section .text
.globl _start
_start:
    # Get num1, num2, result
    call _printText1
    call _getNum1
    call _calculateFactorial
    call _printText2
    call _printRes
    call _printNewline

    mov $60, %rax
    xor %rdi, %rdi
    syscall

_printText1:
    # Print text 1
    mov $1, %rax
    mov $1, %rdi
    lea text1(%rip), %rsi
    mov $len1, %rdx
    syscall
    ret

_getNum1:
    # Get num 1 from user
    mov $0, %rax
    mov $0, %rdi
    lea num1(%rip), %rsi
    mov $4, %rdx
    syscall
    ret

_printText2:
    # Print text 2
    mov $1, %rax
    mov $1, %rdi
    lea text2(%rip), %rsi
    mov $len2, %rdx
    syscall
    ret

_calculateFactorial:
    # Convert num1 from ASCII to integer
    lea num1(%rip), %rsi
    call _asciiToInt
    mov %rax, %rbx # store first number in rbx

    # Initialize factorial result to 1
    mov $1, %rax

    # Calculate the factorial
    mov %rbx, %rcx
    mov %rax, %rdx
    loop_start:
        mul %rcx
        loop loop_start

    # Store the result in the `result` buffer
    mov %rax, result(%rip)

    # Convert the result back to ASCII
    lea result(%rip), %rsi
    call _intToAscii
    ret

_asciiToInt:
    xor %rax, %rax
    xor %rcx, %rcx

convert_loop:
    movzbl (%rsi,%rcx), %rdx
    cmp $0xA, %rdx   # Check for newline character
    je end_convert
    sub $'0', %rdx
    imul $10, %rax
    add %rdx, %rax
    inc %rcx
    jmp convert_loop

end_convert:
    ret

_intToAscii:
    mov $0, %rcx
    mov $10, %rbx

convert_int_loop:
    xor %rdx, %rdx
    div %rbx
    add $'0', %dl
    push %rdx
    inc %rcx
    test %rax, %rax
    jnz convert_int_loop

print_result_loop:
    pop %rax
    mov %al, (%rsi)
    inc %rsi
    loop print_result_loop
    ret

_printRes:
    mov $1, %rax
    mov $1, %rdi
    lea result(%rip), %rsi
    mov $8, %rdx
    syscall
    ret

_printNewline:
    mov $1, %rax
    mov $1, %rdi
    lea newline(%rip), %rsi
    mov $1, %rdx
    syscall
    ret
