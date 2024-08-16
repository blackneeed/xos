[org 0x7c00] ; say all memory addresses have to be offsetted by 0x7c00 (where the bios loads us)
[bits 16]

%include "config.inc"

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
    stc
    mov ah, 02h
    mov al, 4
    mov ch, 0x00
    mov cl, 0x02
    mov dh, 0x00
    mov dl, [boot_disk_number]
    push ax
    xor ax, ax
    mov es, ax
    pop ax
    mov bx, 0x7e00
    int 13h
    sti
    %ifdef QEMU
    jc .disk_read_error
    %else
    jnc .disk_read_error
    %endif

    jmp 0:0x7e00 ; pass control to stage2
.disk_read_error:

    mov bx, disk_read_error
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

boot_disk_number: db 0
disk_read_error: db "Could not read stage2!", 0xA, 0xD, 0

times 512-2-($-$$) db 0
db 0x55, 0xaa