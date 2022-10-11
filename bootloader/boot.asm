[bits 16]
[org 0x7c00]
start:
    cli
    mov [boot_disk], dl
    xor ax,ax
    mov ds,ax
    mov es,ax
    mov ebp,0x7c00
    mov esp,ebp
    sti

    mov ah, 0x00
	mov al, 0x2
	int 0x10

    mov bx, load
    mov dh, 2

    mov ah, 0x02
    mov al, dh 
    mov ch, 0x00
    mov dh, 0x00
    mov cl, 0x02
    mov dl, [boot_disk]
    int 0x13

    jc error

    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp CODE_SEG:start_pm
jmp $
print_string:
    mov ah, 0xe
.ploop:
    mov al, [bx]
    cmp al, 0
    je end
    int 0x10
    inc bx
    jmp .ploop
end:
    ret

error:
    mov bx, msg_error
    call print_string
    jmp $

boot_disk: db 0

msg_error: db "!Error!",0xD,0xA,0

gdt_start:
    gdt_null:
        dd 0x0
        dd 0x0

    gdt_code:
        dw 0xffff
        dw 0x0
        db 0x0
        db 0b10011010
        db 0b11001111
        db 0x0

    gdt_data:
        dw 0xffff
        dw 0x0
        db 0x0
        db 0b10010010
        db 0b11001111
        db 0x0
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

[bits 32]
start_pm:
    mov ax, DATA_SEG
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax

    mov ebp, 0x7c00
	mov esp, ebp

    mov eax, 0x0f01
    mov [0xb8000], eax

    mov bx, msg_pm
    call print_string_pm

    jmp CODE_SEG:load
    jmp $

print_string_pm:
    pusha
    mov ecx, [vid_ptr]
.print_loop:
    mov ax, [bx]

    cmp ax, 0
    je .end_print
    
    mov [ecx], ax
    inc ecx
    
    mov ax, 0x0f
    mov [ecx], ax
    inc ecx

    inc bx
    
    jmp .print_loop
.end_print:
    mov [vid_ptr], ecx
    popa
    ret

msg_pm: db "Reached Protected Mode! ", 0x1, 0
vid_ptr: dd 0xb8000
times 510-($-$$) db 0
dw 0xaa55
load: