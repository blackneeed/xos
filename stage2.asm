[bits 16]
[org 0x7e00]

%include "config.inc"

main:
    mov bx, success
    call print_string

    cli
    jmp $

print_string:
    mov al, [bx]
    test al, al
    jz .end
    
    mov ah, 0eh
    int 10h
    inc bx
    jmp print_string

.end:
    ret

success: db "Successfully loaded stage2 of Xnix bootloader!", 0xD, 0xA, 0

times 2048-($-$$) db 0