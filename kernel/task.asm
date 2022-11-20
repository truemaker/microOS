[bits 32]
[global switch_context]
switch_context:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    pushf
    
    mov eax, [esp+36]
    mov [eax], esp
    mov esp, [esp+40]
    
    popf
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret