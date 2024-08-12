[org 0x7c00] ; say all memory addresses have to be offsetted by 0x7c00 (where the bios loads us)
[bits 16]

main:
    xor ax, ax
    mov ds, ax
    mov es, ax

    jmp 0:.after_far_jump
.after_far_jump:
    mov ss, ax
    mov bp, 0x7c00
    mov sp, 0x7c00

    jmp $

times 512-2-($-$$) db 0
db 0x55, 0xaa