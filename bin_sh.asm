.global _start 

.text 

_start : 
    ldr r0,=path 
    mov r1,#0
    mov r2,#0
    mov r7,#11
    swi 0


.data 
path:
    .asciz "/bin/sh"
