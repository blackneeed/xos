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
    mov ah, 07h
    mov al, 00h
    mov bh, 0fh
    xor cx, cx
    mov dl, 80
    mov dh, 25
    int 10h

    ; resetting the disk controller
    ; http://www.ctyme.com/intr/rb-0605.htm
    mov ah, 00h
    mov dl, [boot_disk_number]
    int 13h

    ; reading the next sectors on the disk
    ; http://www.ctyme.com/intr/rb-0607
    push dx
    stc
    mov ah, 02h
    mov al, 4 ; read 4 sectors
    mov ch, 0x00 ; cylinder number = 0x00
    mov cl, 0x02 ; sector number = 0x02
    mov dh, 0x00 ; head number = 0x00
    mov dl, [boot_disk_number]
    push ax
    xor ax, ax
    mov es, ax ; load at 0:?
    pop ax
    mov bx, 0x7e00 ; load at ?:0x7e00
    ; (load at 0:0x7e00)
    int 13h
    sti
    pop dx

    jmp 0:0x7e00 ; pass control to stage2

print_string:
    push bx
    push ax
    .loop:
    cmp [bx], byte 0
    je .end
    ; ah=0eh int 10h -- BUG: If the write causes the screen to scroll, BP is destroyed by BIOSes for which AH=06h destroys BP
    push ax
    mov ah, 0eh
    mov al, [bx]
    int 0x10
    pop ax
    inc bx
    jmp .loop
    .end:
    pop ax
    pop bx
    ret

boot_disk_number: db 0

times 512-2-($-$$) db 0
db 0x55, 0xaa