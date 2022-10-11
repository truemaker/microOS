[bits 32]
[extern main]
start:
    call main
    jmp $

%include "kernel/task.asm"