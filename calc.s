;; external LEN
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

;; rdi: Target (digits), rsi: source1; rdx: source2 rdi = rsi - rdx
sub3:
    ;; r8: übertrag
    mov rcx, LEN
    lea rsi, [rsi+8*rcx]
    lea rdi, [rdi+8*rcx]
    lea rdx, [rdx+8*rcx]
    clc
    .loop1:
      lea rsi, [rsi - 8]
      lea rdi, [rdi - 8]
      lea rdx, [rdx - 8]
      mov rax, [rsi]
      sbb rax, [rdx]
      mov [rdi], rax
      dec rcx
    jnz .loop1
    ret
;; rdi: Target (digits), rsi: source; rdi=rdi+rsi
add2:
    ;; r8: übertrag
    mov rcx, LEN
    lea rsi, [rsi+8*rcx]
    lea rdi, [rdi+8*rcx]
    clc
    .loop1:
      lea rsi, [rsi-8]
      lea rdi, [rdi-8]
      mov rax, [rsi]
      adc rax, [rdi]
      mov [rdi], rax
      dec rcx
    jnz .loop1
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

