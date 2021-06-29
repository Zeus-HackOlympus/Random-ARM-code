.global _start 

.section .text

_start: 
    mov r0,#14 // according to our table, return values is stored in r0. Here r0 = 14 
    mov r4,#10 // just an extra line (for test) 
    mov r7,#1  // r7 stores syscall code, here syscall code = 1 which represents exit 
    swi #0     // calling syscall

.section .data 
