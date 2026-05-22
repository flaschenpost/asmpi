; --- Define the constant ---
%assign LEN 0x10
%assign DEPTH 0x200
%assign TOTAL LEN*DEPTH/4
%assign Q1 5
%assign Q2 239
%assign Q1S Q1*Q1
%assign Q2S Q2*Q2

%include "print.s"
%include "mem.s"
;; fillzero RDI
%include "calc.s"

;; 4 arctan(1/5) - arctan(1/239)
;; arctan(x) = x - x^3/3 + x^5/5 - x^7/7
;; pi = (16/5 - 4/239) - 1/3(16/5^3 - 4/239^3)

section .data
    space   db ' '
    newline db 0xa
    ;; qword mal 19.265919
    digits dq LEN*19

    lsum db  0xa, " sum= ", 0xa
    .len equ $ - lsum
    lfq2 db  0xa, " FQ2= ", 0xa
    .len equ $ - lfq2
    lfq1 db  0xa, " FQ1= ", 0xa
    .len equ $ - lfq1
    hello1 db  0xa, " h1", 0xa
    .len equ $ - hello1
    hello2 db  0xa, " h2", 0xa
    .len equ $ - hello2
    hello3 db  0xa, " h3", 0xa
    .len equ $ - hello3
    dummy dq 0
    position dq 0

section .bss
    ; --- Reserve memory blocks ---
    ; resq reserves 64-bit (8-byte) quadwords
    sum: resq TOTAL
    fq1: resq LEN
    fq2: resq LEN
    rest1: resq DEPTH
    rest2: resq DEPTH
    a: resq LEN
    b: resq LEN
    c: resq LEN
    temp: resq LEN
    base10: resq LEN*8
    debug: resq 9*(LEN)+1


;; rdi, rsi, rdx, rcx, r8, r9

section .text
    global _start


%macro exit 1
    mov rdi, %1          ; %1 refers to the first argument passed
    mov rax, 60          ; syscall number for sys_exit
    syscall
%endmacro

    _start:

        xor r12, r12
        call init_buffer
        
        ; dump_dec sum

        ; division into fq1

        ; last "remainder" = 1, initial value
        mov rax, 1
        dividRem fq1, Q1, rax
        ; remainder into rest1
        mov qword [rest1], rax
        dump_bits fq1

        ;;; start just test "loop"
        mov rax, [rest1]
        mov rbx, [position]
        add rbx, 8

        dividRem fq1, Q1, rax
        mov [rest1 + rbx ], rax
        dump_bits fq1
        ;;; end test "loop"
        exit 2

        memcp sum, fq1

        ; division into fq1
        ; last "remainder" = 16, initial value
        mov rax, 4
        dividRem fq2, Q2, rax
        ; remainder into rest1
        mov qword [rest2], rax

        dump_bits fq2
        add qword [position], 8


        subtract sum,sum,fq2

        mov rbx, [position]
        lea rax, [rest1]
        dividRem fq1, Q1S, rax
        ; store next remainder
        mov [rest1 + rbx], rax
        dump_bits fq1

        exit 5
        ;; dump_bits fq1
        ; dump_dec fq1

        ; print hello2

        ; all other fq1 = 16/5^u
        mov rdi, fq1
        mov rsi, fq1
        mov rdx, 16
        call mult

        ;; dump_bits fq1
        ; dump_dec fq1

        ; print hello3


        ; initial fq2 = 4/239
        ;; *4
        mov rax, [fq2]
        shl rax,2
        mov [fq2], rax

        lea rax, [rest1]
        divid3 fq2, fq2, Q2, rax

        ; dump_dec fq2


        ; print hello1
        ; dump_dec sum

        lea rax, [rest1]
        divid3 fq2, fq2, Q2S, rax

        print hello1
        ; dump_dec fq2

        mov r15, DEPTH
        mov r14, 3

        .lp1:

        ; print hello1
        print lfq1
        dump_dec fq1
        print lfq2
        dump_dec fq2

        subtract a,fq1, fq2

        ; dump_dec a

        lea rax, [rest1]
        divid3 a, a, r14, rax
        add r14, 2

        ; dump_dec a

        subtract sum,sum,a

        ; print lsum
        ; dump_dec sum

        lea rax, [rest1]
        divid3 fq1, fq1, Q1S, rax
        lea rax, [rest1]
        divid3 fq2, fq2, Q2S, rax

        subtract a,fq1,fq2

        lea rax, [rest1]
        divid3 a, a, r14, rax
        add r14, 2
        ; dump_dec a

        addto sum,a

        ; print lsum
        ; dump_dec sum

        lea rax, [rest1]
        divid3 fq1, fq1, Q1S, rax
        lea rax, [rest1]
        divid3 fq2, fq2, Q2S, rax


        dec r15
        jnz .lp1

        dump_dec sum
        dump_dec fq1
        dump_dec fq2

        exit 3

        mov rdi, sum
        mov rsi, fq1
        mov rdx, 7
        call mult

        mov rdi, debug
        mov rsi, sum
        call dump

        memcp temp, sum

        mov rdi, debug
        mov rsi, temp
        call dump_b10
        
        mov rdi, base10
        mov rsi, sum
        call dump_b10

        exit 2
        

; Compile/Link
;
; nasm -f elf64 -o hello-stack_64.o hello-stack_64.asm
; ld  -o hello-stack_64 hello-stack_64.o
