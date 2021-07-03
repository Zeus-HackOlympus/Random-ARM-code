.global _start 

.text
_start : 
    
    mov r0,#1 // r0 = 1 (stdout)
    ldr r1,=5

    mov r2,#8 // r2 = 8 
    mov r7,#4 // r7 = 4 
    swi 0 
    mov r7,#1
    swi 0


