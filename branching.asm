.text 

.global _start 

_start : 
    mov r1, #5 
    add r0, r1, #5 // r0 = 10 
    b func2 
    add r0, r0, #10 // r0 = 20 
    mov r7, #1
    swi 0 

func2: 
    mov r7, #1 
    swi 0 


