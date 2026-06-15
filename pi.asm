; --- Define the constant ---
%assign LEN 51801
%assign Q1 5
%assign Q2 239
%assign Q1S Q1*Q1
%assign Q2S Q2*Q2
%assign NEWLINE 0xa
%assign DIGITS 19
%assign INVERTSIZE 1


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

    losum db  0xa, " sOm= "
    .len equ $ - losum
    lsum db  0xa, " sum= "
    .len equ $ - lsum
    lfq2 db  0xa, " FQ2= "
    .len equ $ - lfq2
    lfq1 db  0xa, " FQ1= "
    .len equ $ - lfq1
    hello1 db  " h1", 0xa
    .len equ $ - hello1
    hello2 db  0xa, " h2", 0xa
    .len equ $ - hello2
    hello3 db  0xa, " h3", 0xa
    .len equ $ - hello2
    l_pa db  0xa, " +a= "
    .len equ $ - l_pa
    l_ma db  0xa, " -a= "
    .len equ $ - l_ma
    newln db  0xa
    .len equ $ - newln

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
    base10: resb DIGITS ;; \n
    base10.len equ $ - base10
    debug: resb 73*(LEN)+2
    D_Q1S: resq INVERTSIZE
    D_Q2S: resq INVERTSIZE


;; rdi, rsi, rdx, rcx, r8, r9

section .text
    global _start

%macro exit 1
    mov rdi, %1          ; %1 refers to the first argument passed
    mov rax, 60          ; syscall number for sys_exit
    syscall
%endmacro

testsub:
    mov rcx, 13000000000
    dividRem fq1, rcx, 1
    ; print lfq1
    memcp sum, fq1
    dump10 sum
    xor r14,r14
    .loop:
    push rcx
    addto sum, fq1, r14
    dump10 sum
    pop rcx
    dec rcx
    jnz .loop
    exit 2
    ret

;; 64-bit inverse of RDI, returned in RAX
invert:
    mov rdx,1
    xor rax,rax
    div rdi
    ret

;; divide LEN qwords from rsi to rdi by mult with rdx with inverse
dmult:
    mov r9, LEN
    mov r8, rdx
    xor rcx, rcx
    .lp1
    mov rax, [rsi]
    shr rax, 32
    mul r8
    mov [rdi], rdx


_start:

    mov rax, 10
    mov rbx, 10
    mov rcx, DIGITS-1
    .init_d19:
    mul rbx
    dec rcx
    jnz .init_d19
    mov [D19], rax

    mov rdi, Q1S
    call invert
    mov [D_Q1S], rax

    dividRem fq1, Q1, 16
    dividRem fq2, Q2, 4

    ; print lfq1 
    ; dump10 fq1
    ; print lfq2 
    ; dump10 fq2

    subtract sum, fq1, fq2, r14
    ; print hello1
    ; dump10 sum

    ;; offset fq1 (qwords with zero)
    xor r15, r15

    ; offset fq2 (qwords with zero)
    xor r14, r14
    mov r13, 3

    mov r12,0
    .loop1:
      ; print hello1 

      divid fq1, fq1, Q1S, r15
      divid fq2, fq2, Q2S, r14
      ; print lfq1
      ; dump10 fq1
      ; print lfq2
      ; dump10 fq2

      subtract a, fq1, fq2, r14

      ;; dump_bits fq2

      mov r8, r15
      divid a, a, r13, r8
      add r13,2

      ; print l_ma
      ; dump10 a

      ;;print losum
      ;;dump10 sum
      subtract sum, sum, a, r15
      ;mov rax,r13
      ;xor rdx, rdx
      ;mov qword r8, 1000
      ;div r8
      ;cmp rdx, 3
      ;jne .noprint1
        ;dump10 sum
      ; .noprint1:
      ; print lsum


      divid fq1, fq1, Q1S, r15
      divid fq2, fq2, Q2S, r14

      ; print lfq1
      ; dump10 fq1
      ; print lfq2
      ; dump10 fq2

      subtract a, fq1, fq2, r14
      mov r8, r15
      divid a, a, r13, r8

      add r13,2
      ; print l_pa
      ; dump10 a

      ;;print l_a
      ;;dump10 a

      ;;print losum
      ;;dump10 sum

      addto sum, a, r15
      ; print lsum
      ; dump10 sum

      cmp r14, LEN
      jae .postloop1
    jmp .loop1

    .postloop1:

    .loop2:
      divid fq1, fq1, Q1S, r15

      memcp a, fq1

      ;; dump_bits fq2

      mov r8, r15
      divid a, a, r13, r8
      ; print hello1
      ; mov rax, r8
      ; call conv64
      cmp r8, LEN
      jae .endloop
      add r13,2
      subtract sum, sum, a, r15

      ;xor rdx, rdx
      ;mov rax,r13
      ;mov qword r8, 1000
      ;div r8
      ;cmp rdx, 5
      ;jne .noprint2
        ;dump10 sum
      ;.noprint2:
      divid fq1, fq1, Q1S, r15
      memcp a, fq1

      mov r8, r15
      divid a, a, r13, r8
      cmp r8, LEN
      jae .endloop
      add r13,2
      ; print l_pa
      ; dump10 a

      ; print hello2
      ; mov rax, r15
      ; call conv64
      ; dump10 a
      addto sum, a, r15
      ; print lsum
      ; dump10 sum

      cmp r15, LEN
      jae .endloop
    jmp .loop2

    .endloop:

    print hello2
    dump10 sum
    print newln
    exit 0
; Compile/Link
;
; nasm -f elf64 -o hello-stack_64.o hello-stack_64.asm
; ld  -o hello-stack_64 hello-stack_64.o
