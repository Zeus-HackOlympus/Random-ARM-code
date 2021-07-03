.global _start 

.text 

_start : 

    ldr r0,=path 
    eor r1,r1,r1
    eor r2,r2,r2 
    add r7,#11
    swi 0 

.data 
path:
    .asciz "/bin/sh"

