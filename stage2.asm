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
    ; ah=0eh int 10h -- BUG: If the write causes the screen to scroll, BP is destroyed by BIOSes for which AH=06h destroys BP
    push ax
    mov [save_bp], bp
    mov ah, 0eh
    mov al, [bx]
    int 0x10
    mov bp, [save_bp]
    pop ax
    inc bx
    jmp .loop
    .end:
    pop ax
    pop bx
    ret

save_bp: db 0
success: db "Successfully loaded stage2 of Xnix bootloader!", 0xD, 0xA, 0

times 2048-($-$$) db 0