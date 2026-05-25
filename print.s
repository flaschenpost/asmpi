
%macro print 1
        mov rsi, %1
        mov rdx, %1.len
        mov rax, 1
        mov rdi, rax
        syscall
%endmacro

%macro dump_bits 1
      mov rdi, debug
      mov rsi, %1
      call dump
%endmacro


; LEN qwords in rdi and rsi

; targetstring: rdi : resb 73*(LEN)+2
; sourcenumber: rsi
; const: LEN
dump:
    mov r9, rdi
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

    mov rsi, r9
    mov rdx, LEN*73+1
    mov rax, 1
    mov rdi, rax
    syscall
    ret

init_buffer:
  push r12
  push r13
    ; digit loops, target debug
    mov r12, base10
    mov r13, [digits]
    mov rdi, base10
    mov rcx, [digits]
    mov rax, 'Y'

    cld
    rep stosb
    mov rax,0xa
    stosb
    mov rsi, b
    mov rdi, base10
  pop r13
  pop r12

ret

;; rdi: source (wird verändert)
;; destroys r8, r9, r10, rdx, rcx, rsi, rax
mult10:
    ;; r8: übertrag
    mov rcx, LEN-1
    lea rsi, [rsi+8*rcx]
    xor r8,r8
    mov r9, 10
    mov r10, 1
    ;; shl r10, REMA
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
    ;; shr rax, REMA
    ret

%macro dump10 1
        memcp temp, %1
        mov rdi, base10
        mov rsi, temp
        call dump_b10
%endmacro

;; rdi: Target (digits), rsi: source (wird verändert)
dump_b10:
    push r12
    push r13
    ; digit loops, target debug
    mov r12, rdi
    mov r11, rsi
    mov r13, [digits]

    .t1:
    mov rdi, r11
    call mult10
    mov byte [r12], '0'
    add [r12], al
    inc r12
    ; debug out
    ; mov rdx,[digits]
    ; inc rdx
    ; mov rsi, base10
    ; mov rax,1
    ; mov rdi, rax
    ; syscall

    ;; HUGE debug out
    ;; mov rdi, debug
    ;; mov rsi, b
    ;; call dump
    ; end debug out

    dec r13
    jnz .t1

    mov rdx,[digits]
    inc rdx
    mov rsi, base10
    mov rax,1
    mov rdi, rax
    syscall
    pop r13
    pop r12
    ret

