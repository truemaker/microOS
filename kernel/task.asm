[bits 32]
[global switch_context]
switch_context:
    pusha
    pushf
    mov eax, [ebp+56]
    mov [eax], esp
    mov esp, [ebp+52]
    popa
    ret