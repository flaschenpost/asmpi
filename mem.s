;; rdi, rsi, rdx, rcx, r8, r9

;; external LEN, REMA
; rdi : target, rsi: count
%macro fillzero 2
    mov rdi, %1
    mov rcx, %2
    mov rax, 0
    cld
    rep stosq
%endmacro

%macro init_to 2
    mov rdi, %1
    mov rax, %2
    mov [rdi], rax
    add rdi, 8
    mov rcx, LEN
    dec rcx
    mov rax, 0
    cld
    rep stosq
%endmacro

; copy LEN qw from rsi to rdi
%macro memcp 2
  mov rdi, %1
  mov rsi, %2
  mov rcx, LEN                    ; RCX = number of QWORDs to copy

  cld                             ; Clear Direction Flag (DF=0) 
  ; ensures RSI/RDI increment forward

  rep movsq                       ; Repeat "move qword" RCX times
%endmacro

