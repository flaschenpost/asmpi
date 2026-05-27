; --- Define the constant ---
%assign LEN 0x4
%assign Q1 5
%assign Q2 239
%assign Q1S Q1*Q1
%assign Q2S Q2*Q2
%assign NEWLINE 0xa
%assign DIGITS 19


%include "print.s"
%include "mem.s"
;; fillzero RDI
%include "calc.s"

;; 4 arctan(1/5) - arctan(1/239)
;; arctan(x) = x - x^3/3 + x^5/5 - x^7/7
;; pi = (16/5 - 4/239) - 1/3(16/5^3 - 4/239^3)

section .data
    space   db ' '
    ;; qword mal 19.265919
    D19 dq 1

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
    sum: resq LEN
    fq1: resq LEN
    fq2: resq LEN
    a: resq LEN
    b: resq LEN
    c: resq LEN
    temp: resq LEN
    base10: resb DIGITS+1 ;; \n
    base10.len equ $ - base10
    debug: resb 73*(LEN)+2


;; rdi, rsi, rdx, rcx, r8, r9

section .text
    global _start

%macro exit 1
    mov rdi, %1          ; %1 refers to the first argument passed
    mov rax, 60          ; syscall number for sys_exit
    syscall
%endmacro

_start:

    mov rax, 10
    mov rbx, 10
    mov rcx, DIGITS-1
    .init_d19:
    mul rbx
    dec rcx
    jnz .init_d19
    mov [D19], rax

    ;; offset fq1 (qwords with zero)
    xor r15, r15

    ; offset fq2 (qwords with zero)
    xor r14, r14
    mov r13, 3


    dividRem fq1, Q1, 16
    dividRem fq2, Q2, 4

    subtract sum, fq1, fq2, r14

    dump10 sum

    .loop1:
      ; print hello1 
      ; dump_bits fq2

      divid fq1, fq1, Q1S, r15
      divid fq2, fq2, Q2S, r14

      subtract a, fq1, fq2, r14

      ;; dump_bits fq2

      mov r8, r14
      divid a, a, r13, r8
      add r13,2
      subtract sum, sum, a, r8

      dump10 sum

      divid fq1, fq1, Q1S, r15
      divid fq2, fq2, Q2S, r14

      subtract a, fq1, fq2, r14
      mov r8, r14
      divid a, a, r13, r8
      add r13,2

      addto sum, a, r8
      dump10 sum

      cmp r14, LEN
      jae .postloop1
    jmp .loop1

    .postloop1:

    print hello3
    dump10 sum

    .loop2:
      divid fq1, fq1, Q1S, r15

      memcp a, fq1

      ;; dump_bits fq2

      mov r8, r14
      divid a, a, r13, r8
      add r13,2
      subtract sum, sum, a, r8

      divid fq1, fq1, Q1S, r15
      memcp a, fq1

      mov r8, r14
      divid a, a, r13, r8
      add r13,2

      addto sum, a, r8
      cmp r15, LEN
      jae .endloop
    jmp .loop2

    .endloop:

    print hello2
    dump10 sum
    exit 3

    print hello1
    dump_bits sum

    mov rdi, a
    mov rsi, sum
    memcp a, sum
    dump10 a

    dump_bits sum
    dump_bits a

    exit 3
    print lsum
    dump10 sum


    print hello2
    dump_bits fq1
    print hello3
    dump_bits fq2
    .endtst:

    print hello1
    dump_bits fq1
    print hello1
    dump_bits fq2
    exit 7


    exit 0

    ; mov rdi, debug
    ; mov rsi, b
    ; call dump

    

; Compile/Link
;
; nasm -f elf64 -o hello-stack_64.o hello-stack_64.asm
; ld  -o hello-stack_64 hello-stack_64.o
