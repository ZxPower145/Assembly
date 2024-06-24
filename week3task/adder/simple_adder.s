.section .data
text1: .asciz "What is the first number? \n"
.set len1, . - text1
text2: .asciz "What is the second number? \n"
.set len2, . - text2
text4: .asciz "The sum is: \n"
.set len3, . - text3
newline: .asciz "\n"

.section .bss
.balign 4
num1: .skip 4
num2: .skip 4
.balign 8
result: .skip 8

.section .text
.globl _start
_start:
    # Get num1, num2, result
    call _printText1
    call _getNum1
    call _printText2
    call _getNum2
    call _addNumbers
    call _printText3
    call _printSum
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

_getNum2:
    # Get num 2 from user
    mov $0, %rax
    mov $0, %rdi
    lea num2(%rip), %rsi
    mov $4, %rdx
    syscall
    ret

_printText3:
    # Print text 3
    mov $1, %rax
    mov $1, %rdi
    lea text3(%rip), %rsi
    mov $len3, %rdx
    syscall
    ret

_addNumbers:
    # Convert num1 from ASCII to integer
    lea num1(%rip), %rsi
    call _asciiToInt
    mov %rax, %rbx # store first number in rbx

    # Convert num2 from ASCII to integer
    lea num2(%rip), %rsi
    call _asciiToInt

    # Add the numbers
    add %rbx, %rax

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

_printSum:
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

