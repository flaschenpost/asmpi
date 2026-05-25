; --- Define the constant ---
%assign LEN 0x5
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
    sum: resq LEN
    fq1: resq LEN
    fq2: resq LEN
    a: resq LEN
    b: resq LEN
    c: resq LEN
    temp: resq LEN
    base10: resb LEN*19+1
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

    call init_buffer

    ;; offset fq1 (qwords with zero)
    xor r15, r15

    ; offset fq2 (qwords with zero)
    xor r14, r14
    mov r13, 3

    dividRem fq1, Q1, 16
    ;; dump_bits fq1

    dividRem fq2, Q2, 4
    ;; dump_bits fq2

    ;; dump_bits fq1
    ; dump10 fq1

    subtract sum, fq1, fq2, r14

    .loop1:
      print hello1 
      dump_bits fq2

      divid fq1, fq1, Q1S, r15
      divid fq2, fq2, Q2S, r14

      print hello2
      dump_bits fq2

      subtract a, fq1, fq2, r14

      print hello3
      dump_bits fq2

      mov r8, r14
      divid a, a, r13, r8
      add r13,2
      addto sum, a, r8
      mov rax, LEN
      cmp rax,r14
      jz .loop2
    jmp .loop1

    print hello3
    dump_bits fq2

    .loop2:
      divid fq1, fq1, Q1S, r15
      mov rax, LEN
      cmp rax,r15
      jz .endloop

      memcp a, fq1

      mov r8, r14
      divid a, a, r13, r8
      add r13,2
      addto sum, a, r8
    jmp .loop2

    .endloop:

    print lsum
    dump_bits sum

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
