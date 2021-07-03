.global _start 

.text 

_start : 
    ldr r0,=path
    sub r1,r1,r1 // r1 = r1 - r1 ; which is basically r1 = 0 
    sub r2,r2,r2 
    mov r7,#11 
    swi 0 

.data 
path : 
    .asciz "/bin/sh"
