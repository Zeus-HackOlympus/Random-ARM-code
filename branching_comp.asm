.text 

.global _start 

_start : 
    mov r1, #15  // r1 = 5 
    mov r2, #10 // r2 = 10  
    cmp r1,r2  // r1 < r2 
    beq r1_r2_equal 
    bgt r1_r2_greater 
    blt r1_r2_less 

r1_r2_equal :
    mov r7, #4 
    mov r0, #1 
    ldr r1, =eq
    ldr r2, =eq_len
    swi 0 
    b exit

r1_r2_greater :
    mov r7, #4 
    mov r0, #1 
    ldr r1, =gr
    ldr r2, =gr_len
    swi 0
    b exit 

r1_r2_less :
    mov r7, #4 
    mov r0, #1 
    ldr r1, =le
    ldr r2, =le_len
    swi 0 
    b exit

exit : 
    mov r7, #1 
    swi 0 

.data 
    eq: .ascii "r1 and r2 are equal\n\0"
    eq_len = .-eq
    gr: .ascii "r1 greater\n\0"
    gr_len = .-gr
    le: .ascii "r1 less than\n\0"
    le_len = .-le


