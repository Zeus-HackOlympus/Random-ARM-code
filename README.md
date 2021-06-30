# ARM 

## Architecture 
- RISC - reduced instruction set compiler which basically means easy language 
- Increasingly popular in embedded IOT devices 

- Registers : They are superfast small size memory which is present in processor itself 
    - ARM has 16 registers: R0-R15 
- Byte addressable 
- 2 operating modes 
    - ARM : 4 byte instruction 
    - THUMB : 2 byte instructions 


## ARM instructions 

- <operator> <dst>, <src> 
- <operator> <dst>, <immediate>
- <operator> <dst>, [address] 

- Example: 
    - mov r0, #0x4 
    - this moves number 4 into register r0 

## Our first code 

```arm
.global _start
.section .text

_start:
    mov r0, #4

.section .data
```

`.global _start` is what we call a 'entry point' , the entry point is where the execution will start. The default label name used to identify the entry point is **\_start**


to run above code :
```
# first we will assemble it and convert to machine code  
arm-linux-gnueabi-as first_code.asm -o first_code.o 
# then we will pass it to linker to make it executable
arm-linux-gnueabi-gcc first_code.o -o first_code -nostdlib 
```

Now we run the code, but it crashes. Why ? 

It crashes because we have defined a 'entry point' so logically we must also define a 'exit point' also. Now in general our code runs in user mode which means it doesn't have the privileges to exit by itself. 

So now we use a syscall in this case. 

## syscalls 

register **r0-r6** are used for passing system calls code and to to execute a fully functional syscall we use an instruction - `swi 0` 

Now we need to know the right syscall code to pass in **r7**. 

!(google has an awesome documentation for us:)
[https://chromium.googlesource.com/chromiumos/docs/+/master/constants/syscalls.md#arm-32_bit_EABI]

from above link we know our syscall is 1, we will pass it using immidiate passing technique 

so we add a syscall in our previous program and assemble and link it again

out program looks like this : 

```asm 
.global _start 

.section .text

_start: 
    mov r0,#14
    mov r4,#10
    mov r7,#1 
    swi #0

.section .data 
```
and we run it : 

it doesnt output anything on the console but if we look at the return value using `echo $?` command 

we see 14 in output, which is what we have commanded the program to do, so it was expected. 
`r0` register stores return values and that is what we got. 


## Defining data in data section 

**We will do the practical of this section in second file - hello.asm** 

before starting this, we need to learn some more technicalities 

`.asciz` and `.ascii` 

To understand above 2 labels, we first need to understand what ascii strings are. In C language, we declare strings in character arrays. So in these arrays there is something called null pointer which denotes the end of the string. Its fine to not use this null pointer('\0') but in that case OS will not know when the string ends and length operation on string will not work as expected. 

So to define a character array with null pointer, we use `.asciz` label while to just define a character array we use `.ascii` . 

Another thing we need to learn is `ldr` instruction

So LDR instruction is very similar to MOV instruction but there is a very minute and important to note change.

in mov register, we are taking some value/address from one **register** and assigning that value/address to another **register**. So **register** ---> **register**. Everything is happening inside memory. 

but suppose we want to take data from **memory** and use it in a **register**. **memory** --> **register** . IN THAT CASE WE USE **LDR** REGISTER. 

### practical 

```asm
.global _start 

.text 

_start: 
    mov r7, #1
    swi 0 


.data 
msg: 
    .asciz "Hello World\n"

len = .-msg
```

In above code we create 2 label : 
    - `msg` 
    - `len` 

`msg` is a null pointer character array 
`len` is a way of telling the assembler to automatically by itself calculate the size of character array msg and assign len that value. 

**notice**: We have defined the values in `.data` which means that we are assigning it in memory and not in any register(for now).

## Now only one job left TO Display the data 

0 - stdin 
1 - stdout 
2 - stderr 

here we are doing stdout 

so return value will be 1 : `mov r0,#1`

We take data from memory and assign it to some registers: 
    ``` asm
    ldr r1,=message
    ldr r2,=len
    ```

Now because we need to write on screen, our first syscall is for write which is 4 : 
    ```asm
    mov r7,#4 
    swi 0 
    ```

Now we haven't exited from the program, for that another syscall for exit now : 
    ```asm
    mov r7, #1
    swi 0 
    ```

our full code : 
```asm 
.global _start 

.text 

_start: 

    mov r0,#1 
    
    ldr r1,=msg 
    ldr r2,=len 
    
    mov r7,#4
    swi 0 

    mov r7, #1
    swi 0 


.data 
msg: 
    .asciz "Hello World\n"

len = .-msg
```

