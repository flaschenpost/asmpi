
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

%macro dump10 1
  memcp temp, %1
  mov rdi, temp
  call dumpD10
  print newln
%endmacro

;; destroys rax and rdx
conv64:
   push rsi
   push rdi
   push rcx
   push r8

   mov rcx, DIGITS
   ; mov byte [base10+rcx], ' '
   mov r8,10
   .conv64l:
   dec rcx
   jz .conv64e
   xor rdx,rdx
   div r8
   add dx, '0'
   mov byte [base10+rcx], dl
   jmp .conv64l

   .conv64e:
   xor rdx,rdx
   div r8
   add dx, '0'
   mov byte [base10], dl
   print base10
    ; mov rsi, base10
    ; mov rdx, DIGITS+1
    ; mov rax, 1
    ; mov rdi, rax
    ; syscall
   pop r8
   pop rcx
   pop rdi
   pop rsi
ret


;; rdi: source (wird verändert)
;; destroys r8, r9, r10, rdx, rcx, rsi, rax
dumpD10:
    mov rbx, LEN
    .dumplp:

    ;; r8: übertrag
    mov rax, [rdi]
    call conv64
    mov qword [rdi], 0
    mov rcx, LEN-1
    xor r8,r8
    mov r9, [D19]
    .loop1:
      mov rax, [rdi+8*rcx]
      mul r9
      add rax, r8
      adc rdx, 0
      mov r8, rdx
      mov [rdi+8*rcx], rax
      dec rcx
    jnz .loop1
    mov rax, [rdi]
    mul r9
    add rax, r8
    mov [rdi], rax
    dec rbx
    jnz .dumplp
    ;; shr rax, REMA
    ; print newln
    mov rax, r8
    ret


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
