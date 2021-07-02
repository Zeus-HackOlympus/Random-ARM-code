.text 

.global _start 

_start : 
    mov r7, #4 // write 
    mov r0, #1 // stdout
    mov r2, #12 // len of msg 
    ldr r1, =msg
    swi 0 

end: 
    mov r7, #1 
    swi 0 


.data 

msg :   
    .ascii "Hello World\n"
