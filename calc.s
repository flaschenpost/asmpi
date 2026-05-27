;; rdi: target, rsi: source, rdx: divisor
%macro divid 4
        mov rdi, %1
        mov rsi, %2
        mov rdx, %3
        mov rcx, %4
        call divide
        mov %4, rax
%endmacro

%macro dividRem 3
  mov rdi, %1
  mov rsi, %2
  mov rdx, %3
  call divideRem
%endmacro

;; target, source, offset
%macro addto 3
        mov rdi, %1
        mov rsi, %2
        mov rdx, %3
        call add2
%endmacro

%macro subtract 4
        mov rdi, %1
        mov rsi, %2
        mov rdx, %3
        mov rcx, %4
        call sub3
%endmacro

;; external LEN
;; rdi: target, rsi: divisor, rdx: first number
;; return remainder
divideRem:
    mov rcx, LEN
    mov rax, rdx
    xor rdx, rdx
    .loop1:
    test rdx, rdx
    jnz .calc
    test rax, rax
    jnz .calc
      jmp .aftercalc
    .calc:
    div rsi
    .aftercalc:
    mov [rdi], rax
    xor rax, rax
    add rdi,8
    dec rcx
    jnz .loop1
    mov rax, rdx
    ret

;; external LEN
;; rdi: target, rsi: source, rdx: divisor, rcx: offset
;; return new offset with zeros
divide:

    mov r9,rcx
    .preloop:
    cmp rcx, LEN
    jae .ret
    mov rax, [rsi + 8*rcx]
    test qword rax, rax
    jnz .exitpreloop
    inc rcx
    mov r9,rcx
    jmp .preloop

    .exitpreloop:

    mov r8, rdx
    xor rdx, rdx

    .loop1:
    cmp rcx, LEN
    jae .ret
    mov rax, [rsi + 8*rcx]
    div r8
    mov [rdi+8*rcx], rax
    inc rcx
    jmp .loop1
    
    .ret:
    mov rax, r9
    ret

;; rdi: Target (digits), rsi: source1; rdx: source2 rdi = rsi - rdx, rcx: 0-offset
sub3:
    ;; r8: leading zeros
    push rdi
    push rsi
    push rcx
    lea rdi, [rdi+8*rcx]
    lea rsi, [rsi+8*rcx]
    lea rdx, [rdx+8*rcx]
    mov r8, rcx
    mov rcx, LEN
    sub rcx, r8
    .loop1:
      mov rax, [rsi+8*rcx-8]
      sbb rax, [rdx+8*rcx-8]
      mov [rdi+8*rcx-8], rax
      dec rcx
    jnz .loop1
    pop rcx
    pop rsi
    pop rdi
    test rcx, rcx
    jz .ret
    .cp:
      mov rax, [rsi+8*rcx-8]
      mov [rdi+8*rcx-8], rax
      dec rcx
      jnz .cp
    .ret:
    ret
;; rdi: Target (digits), rsi: source; rdi=rdi+rsi, rdx: number of leading zeros
add2:
    ;; r8: übertrag
    mov rcx, LEN
    clc
    .loop1:
      cmp rcx, rdx
      jbe .ret
      dec rcx
      mov rax, [rsi+8*rcx]
      adc rax, [rdi+8*rcx]
      mov [rdi+8*rcx], rax
    jmp .loop1
    jnc .ret
    ;; use last carry flag
    test rdx, rdx
    jz .ret
    mov rax, [rsi+8*rcx]
    adc rax, 0
    mov [rdi+8*rcx], rax
    dec rcx
    .ret:
    ret

;; rdi: Target (digits), rsi: source , rdx: multiplyer
mult:
    ;; r8: übertrag
    mov rcx, LEN
    lea rsi, [rsi+8*rcx]
    lea rdi, [rdi+8*rcx]
    xor r8,r8
    mov r9, rdx
    .loop1:
      sub rsi,8
      sub rdi,8
      mov rax, [rsi]
      mul r9
      add rax, r8
      adc rdx, 0
      mov r8, rdx
      mov [rdi], rax
      dec rcx
    jnz .loop1
    ret

