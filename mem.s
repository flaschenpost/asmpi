;; rdi, rsi, rdx, rcx, r8, r9

;; external LEN
; rdi : target
fillzero:
    mov rcx, LEN
    mov rax, 0
    cld
    rep stosq
    ret

; rdi : target
init_to_1:
    mov rax,1
    mov [rdi], rax
    add rdi, 8
    mov rcx, LEN
    dec rcx
    mov rax, 0
    cld
    rep stosq
    ret

; copy LEN qw from rsi to rdi
%macro memcp 2
    mov rdi, %1
    mov rsi, %2
    mov rcx, LEN                    ; RCX = number of QWORDs to copy

    cld                             ; Clear Direction Flag (DF=0) 
    ; ensures RSI/RDI increment forward

    rep movsq                       ; Repeat "move qword" RCX times
%endmacro

