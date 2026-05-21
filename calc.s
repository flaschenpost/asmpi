;; rdi: target, rsi: source, rdx: divisor, rcx: remainder
%macro divid3 4
        mov rdi, %1
        mov rsi, %2
        mov rdx, %3
        mov rcx, [%4]
        call divide
%endmacro

%macro dividRem 3
  mov rdi, %1
  mov rsi, %2
  mov rdx, %3
  call divideRem
%endmacro

%macro addto 2
        mov rdi, %1
        mov rsi, %2
        call add2
%endmacro

%macro subtract 3
        mov rdi, %1
        mov rsi, %2
        mov rdx, %3
        call sub3
%endmacro

;; external LEN
;; rdi: target, rsi: divisor, rdx: last remainder
;; return remainder
divideRem:
    mov rcx, LEN
    xor rax, rax
    .loop1:
    test rdx, rdx
    jnz .calc
    test rax, rax
    jnz .calc
      mov [rdi], rax
      add rdi,8
      jmp .endloop1
    .calc:
    div rsi
    mov [rdi], rax
    add rdi,8
    .endloop1:
    dec rcx
    jnz .loop1
    mov rax, rdx
    ret

;; external LEN
;; rdi: target, rsi: source, rdx: divisor, rcx: last remainder
;; return remainder
divide:
    mov r8, rdx
    mov rdx, rcx
    mov rcx, LEN
    .loop1:
    mov rax, [rsi]
    test rdx, rdx
    jnz .calc
    test rax, rax
    jnz .calc
      mov [rdi], rax
      add rdi,8
      add rsi,8
      jmp .endloop1
    .calc:
    div r8
    mov [rdi], rax
    add rdi,8
    add rsi,8
    .endloop1:
    dec rcx
    jnz .loop1
    mov rax, r8
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

