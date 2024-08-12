[org 7c00h] ; say all memory addresses have to be offsetted by 0x7c00 (where the bios loads us)
[bits 16]

main:
    xor ax, ax
    mov ds, ax
    mov es, ax

    jmp 0:.after_far_jump
.after_far_jump:
    ; setting up the stack
    mov ss, ax
    mov bp, 7c00h
    mov sp, 7c00h

    ; clearing the screen
    ; ah=07h int 10h -- BUGS: Some implementations (including the original IBM PC) have a bug which destroys BP. The Trident TVGA8900CL (BIOS dated 1992/9/8) clears DS to 0000h when scrolling in an SVGA mode (800x600 or higher)
    ; http://www.ctyme.com/intr/rb-0097.htm
    push bp
    mov ah, 07h
    mov al, 00h
    mov bh, 0fh
    xor cx, cx
    mov dl, 80
    mov dh, 25
    int 10h
    pop bp

    jmp $

times 512-2-($-$$) db 0
db 0x55, 0xaa