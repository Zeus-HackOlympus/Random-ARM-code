.global _start 

# execve (r7 = 11) 
# int execve(const char *filename, char *const argv[], char *const envp[]);


.text 
_start : 
    ldr r0,=program // 1st argument filename 
    mov r1,#0 // 2nd argument null 
    mov r2,#0 // 3rd argument null 
    mov r7,#11 
    swi 0 


.data 
program: 
    .asciz "/bin/sh" 
