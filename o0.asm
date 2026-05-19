; --- Define the constant ---
%assign BLOCKS 5
%assign LEN 0x20
%assign LOOPS 0x80
%assign TOTAL LEN*LOOPS
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

section .bss
    ; --- Reserve memory blocks ---
    ; resq reserves 64-bit (8-byte) quadwords
    sum: resq TOTAL
    fq1: resq LEN
    fq2: resq LEN
    rest1: resq LOOPS
    rest2: resq LOOPS
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
        
        fillzero sum, TOTAL
        fillzero rest1, LOOPS
        fillzero rest2, LOOPS

        ; dump10 sum
        mov rdi, fq1
        call init_to_1
        lea rax, [rest1]

        divid3 fq1,fq1,Q1, rax

        ;; dump_bits fq1
        ; dump10 fq1

        ; initial fq1 = 1/5, skipping the "3." at the beginning
        addto sum,fq1

        lea rax, [rest1]
        divid3 fq1, fq1, Q1S, rax

        ;; dump_bits fq1
        ; dump10 fq1

        ; print hello2

        ; all other fq1 = 16/5^u
        mov rdi, fq1
        mov rsi, fq1
        mov rdx, 16
        call mult

        ;; dump_bits fq1
        ; dump10 fq1

        ; print hello3

        mov rdi, fq2
        call init_to_1

        ; initial fq2 = 4/239
        ;; *4
        mov rax, [fq2]
        shl rax,2
        mov [fq2], rax

        lea rax, [rest1]
        divid3 fq2, fq2, Q2, rax

        ; dump10 fq2

        mov rdi, sum
        mov rsi, sum
        mov rdx, fq2
        call sub3

        ; print hello1
        ; dump10 sum

        lea rax, [rest1]
        divid3 fq2, fq2, Q2S, rax

        print hello1
        ; dump10 fq2

        mov r15, LOOPS
        mov r14, 3

        .lp1:

        ; print hello1
        ; print lfq1
        ; dump10 fq1
        ; print lfq2
        ; dump10 fq2

        subtract a,fq1, fq2

        ; dump10 a

        lea rax, [rest1]
        divid3 a, a, r14, rax
        add r14, 2

        ; dump10 a

        subtract sum,sum,a

        ; print lsum
        ; dump10 sum

        lea rax, [rest1]
        divid3 fq1, fq1, Q1S, rax
        lea rax, [rest1]
        divid3 fq2, fq2, Q2S, rax

        subtract a,fq1,fq2



        lea rax, [rest1]
        divid3 a, a, r14, rax
        add r14, 2
        ; dump10 a

        addto sum,a

        ; print lsum
        ; dump10 sum

        lea rax, [rest1]
        divid3 fq1, fq1, Q1S, rax
        lea rax, [rest1]
        divid3 fq2, fq2, Q2S, rax


        dec r15
        jnz .lp1

        dump10 sum
        dump10 fq1
        dump10 fq2

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
        mov rdi, fq2
        call init_to_1
        

        mov rdi, base10
        mov rsi, a
        call dump_b10


        mov rdi, fq2
        mov rsi, fq2
        mov rdx,Q2
        call divide 

      ;; pi = (16/5 - 4/239) - 1/3(16/5^3 - 4/239^3)

        ; mov rdi, debug
        ; mov rsi, sum
        ; call dump

        ;; mov rdi, b
        ;; mov rsi, sum
        ;; mov rdx,7
        ;; call divide

        call dump_b10

        ;mov rdi, debug
        ;mov rsi, b
        ;call dump


        exit 0

        ; mov rdi, debug
        ; mov rsi, b
        ; call dump

        

; Compile/Link
;
; nasm -f elf64 -o hello-stack_64.o hello-stack_64.asm
; ld  -o hello-stack_64 hello-stack_64.o
