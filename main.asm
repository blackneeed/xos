[org 0x7c00] ; say all memory addresses have to be offsetted by 0x7c00 (where the bios loads us)
[bits 16]

main:
    xor ax, ax
    mov ds, ax
    mov es, ax

    jmp 0:.after_far_jump
.after_far_jump:
    ; setting up the stack
    mov ss, ax
    mov bp, 0x7c00
    mov sp, 0x7c00

    ; saving the drive number
    mov [boot_disk_number], dl

    ; clearing the screen
    ; ah=07h int 10h -- BUGS: Some implementations (including the original IBM PC) have a bug which destroys BP. The Trident TVGA8900CL (BIOS dated 1992/9/8) clears DS to 0000h when scrolling in an SVGA mode (800x600 or higher)
    ; http://www.ctyme.com/intr/rb-0097.htm
    mov [save_bp], bp
    mov ah, 07h
    mov al, 00h
    mov bh, 0fh
    xor cx, cx
    mov dl, 80
    mov dh, 25
    int 10h
    mov bp, [save_bp]


    jmp $

print_string:
    ; push bx
    ; push ax
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

boot_disk_number: db 0
save_bp: db 0

times 512-2-($-$$) db 0
db 0x55, 0xaa