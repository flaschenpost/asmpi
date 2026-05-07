; --- Define the constant ---
%assign LEN 2255
%assign LENX LEN+1
%assign OFFS 8
%assign REMA 64-OFFS
%assign Q1 5
%assign Q2 239
%assign Q1S Q1*Q1
%assign Q2S Q2*Q2

;; 4 arctan(1/5) - arctan(1/239)
;; arctan(x) = x - x^3/3 + x^5/5 - x^7/7
;; pi = (16/5 - 4/239) - 1/3(16/5^3 - 4/239^3)

section .data
    space   db ' '
    newline db 0xa
    ;; qword mal 19.265919
    digits dq LEN*19

    hello db  0xa, "  Hullo     BigNum!!!", 0xa, 0xa, 0
    .len equ $ - hello

section .bss
    ; --- Reserve memory blocks ---
    ; resq reserves 64-bit (8-byte) quadwords
    sum: resq LEN
    fq1: resq LEN
    fq2: resq LEN
    a: resq LEN
    b: resq LEN
    c: resq LEN
    t: resb LENX
    d: resb 73*(LEN)+2


;; rdi, rsi, rdx, rcx, r8, r9

section .text
    global _start

    ; rdi 
    fillzero:
        mov rcx, LEN
        mov rax, 0
        cld
        rep stosq
        ret

    init:
        mov rax,1
        shl rax, REMA
        mov [rdi], rax
        mov rcx, LEN
        dec rcx
        mov rax, 0
        mov rdi, a
        add rdi, 8
        cld
        rep stosq
        ret

    ; targetstring: rdi
    ; sourcenumber: rsi
    ; const: LEN
    dump:
        mov rdx, LEN
        xor r8,r8
        .qwloop:
          mov rcx, 64
          .bitloop:
            bt [rsi],r8
            setc al
            add al, '0'
            stosb

            inc r8
            test r8,7
            jnz .no_space
            mov al, ' '
            stosb
            .no_space:
            dec rcx
          jnz .bitloop

          mov al,0xa
          stosb
          dec rdx
        jnz .qwloop
        mov al, 0xa
        stosb
        mov al, 'X'
        mov rcx, 50
        rep stosb

        mov rsi, d
        mov rdx, LEN*73+1
        mov rax, 1
        mov rdi, rax
        syscall
        ret

;; rdi: target, rsi: source, rdx: divisor
   divide:
        mov r8, rdx
        xor rdx, rdx
        mov rcx, LEN
        .loop1:
        mov rax, [rsi]
        div r8
        mov [rdi], rax
        add rdi,8
        add rsi,8
        dec rcx
        jnz .loop1
        ret

;; rdi: Target (digits), rsi: source (wird verändert)
   mult10:
        ;; r8: übertrag
        mov rcx, LEN-1
        lea rsi, [rsi+8*rcx]
        xor r8,r8
        mov r9, 10
        mov r10, 1
        shl r10, REMA
        dec r10
        .loop1:
          mov rax, [rsi]
          mul r9
          add rax, r8
          adc rdx, 0
          mov r8, rdx
          mov [rsi], rax
          sub rsi,8
          dec rcx
        jnz .loop1
        mov rax, [rsi]
        mul r9
        add rax, r8
        ; rdx and Carry should be 0
        mov r8, rax
        and r8, r10
        mov [rsi], r8
        shr rax, REMA
        ret

    dump10:
        ; digit loops, target d
        mov r12, t
        mov r13, [digits]
        mov rdi, t
        mov rcx, [digits]
        mov rax, 'Y'

        cld
        rep stosb
        mov rax,0xa
        stosb
        
        .t1:
        mov rdi, t
        mov rsi, b
        call mult10
        mov byte [r12], '0'
        add [r12], al
        inc r12
        ; debug out
        ; mov rdx,[digits]
        ; inc rdx
        ; mov rsi, t
        ; mov rax,1
        ; mov rdi, rax
        ; syscall

        ;; HUGE debug out
        ;; mov rdi, d
        ;; mov rsi, b
        ;; call dump
        ; end debug out

        dec r13
        jnz .t1

        mov rdx,[digits]
        inc rdx
        mov rsi, t
        mov rax,1
        mov rdi, rax
        syscall
        ret

    _start:
        mov rdi, a
        call init

        ; mov rdi, d
        ; mov rsi, a
        ; call dump

        mov rdi, b
        mov rsi, a
        mov rdx,7
        call divide

        call dump10

        ;mov rdi, d
        ;mov rsi, b
        ;call dump



        ; mov rdi, d
        ; mov rsi, b
        ; call dump

        
        ; exit 
        xor     rdi,rdi             ; zero rdi (rdi hold return value)
        mov     rax, 0x3c           ; set syscall number to 60 (0x3c hex)
        syscall                     ; call kernel

; Compile/Link
;
; nasm -f elf64 -o hello-stack_64.o hello-stack_64.asm
; ld  -o hello-stack_64 hello-stack_64.o
