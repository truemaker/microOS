[bits 32]
[extern main]
start:
    call main
    jmp $

%include "kernel/task.asm"

%macro isr_err_stub 1
isr_stub_%+%1:
    call exception_handler
    iret 
%endmacro
; if writing for 64-bit, use iretq instead
%macro isr_no_err_stub 1
isr_stub_%+%1:
    call exception_handler
    iret
%endmacro

extern exception_handler
isr_no_err_stub 0
isr_no_err_stub 1
isr_no_err_stub 2
isr_no_err_stub 3
isr_no_err_stub 4
isr_no_err_stub 5
isr_no_err_stub 6
isr_no_err_stub 7
isr_err_stub    8
isr_no_err_stub 9
isr_err_stub    10
isr_err_stub    11
isr_err_stub    12
isr_err_stub    13
isr_err_stub    14
isr_no_err_stub 15
isr_no_err_stub 16
isr_err_stub    17
isr_no_err_stub 18
isr_no_err_stub 19
isr_no_err_stub 20
isr_no_err_stub 21
isr_no_err_stub 22
isr_no_err_stub 23
isr_no_err_stub 24
isr_no_err_stub 25
isr_no_err_stub 26
isr_no_err_stub 27
isr_no_err_stub 28
isr_no_err_stub 29
isr_err_stub    30
isr_no_err_stub 31

global isr_stub_table
isr_stub_table:
%assign i 0 
%rep    32 
    dd isr_stub_%+i ; use DQ instead if targeting 64-bit
%assign i i+1 
%endrep

pic1_mask: db 0
pic2_mask: db 0

%macro outb 2
  mov al, %2
  out %1, al
%endmacro

[global remap_pic]
remap_pic:
  ;in al, 0x21
  ;mov [pic1_mask], al
  ;in al, 0xA1
  ;mov [pic2_mask], al
  outb 0x20, 0x11
  outb 0xA0, 0x11
  outb 0x21, 0x20
  outb 0xA1, 0x28
  outb 0x21, 0x04
  outb 0xA1, 0x02
  outb 0x21, 0x01
  outb 0xA1, 0x01
  ;outb 0x21, [pic1_mask]
  ;outb 0xA1, [pic2_mask]
  ret