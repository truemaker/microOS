[bits 32]
[global switch_context]
switch_context:
    push ebp
    mov ebp, esp
    pusha
    pushf
    mov eax, cr3
    push eax
    push ebp

    mov edx, [ebp+16]
    mov [edx], esp
    mov esp, [ebp+12]
    
    pop ebp 
    pop ebx
    cmp eax, ebx
    je .dir_set
    mov cr3, ebx
.dir_set:
    popf
    popa
    mov esp, ebp
    pop ebp
    ret