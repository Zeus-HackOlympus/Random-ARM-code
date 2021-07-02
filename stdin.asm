.text 

.global _start 

_start :
    mov r0, #0 // stdin 
    ldr r1, =msg // put the characters in msg label 
    mov r2, #15 // read 15 character 
    mov r7, #3 // we are using read() syscall
    swi 0

write: 
    // this will write on screen what we have input
    mov r7, #4 
    mov r0, #1 
    ldr r1, =msg // print msg 
    mov r2, #15 // print 15 characters 
    swi 0 

exit: 
    mov r7, #1 
    swi 0 

.data 
msg : 
    .ascii " "
