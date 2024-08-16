[bits 16]
[org 0x7e00]

main:
    mov bx, success
    call print_string

    jmp $

print_string:
    push bx
    push ax
    .loop:
    cmp [bx], byte 0
    je .end
    mov ah, 0eh
    mov al, [bx]
    int 0x10
    inc bx
    jmp .loop
    .end:
    pop ax
    pop bx
    ret

success: db "Successfully loaded stage2 of Xnix bootloader!", 0xD, 0xA, 0

times 2048-($-$$) db 0