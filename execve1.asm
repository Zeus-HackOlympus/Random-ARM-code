.text 

.global _start 
_start: 
    add r0,pc,#12
    mov r1,#0 
    mov r2,#0
    mov r7,#11
    swi 0 
    .ascii "/bin/sh\0"
