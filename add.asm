.global _start 

.text
_start: 
    mov r1, #2 
    mov r2, #3 
    ADD r0,r1,r2 // r1= 2 ; r2 = 3 ; r0 = r1 + r2 = 5
    mov r7, #1 
    swi 0 



