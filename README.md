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

- \<operator\> \<dst\>, \<src\> 
- \<operator\> \<dst\>, \<immediate\>
- \<operator\> \<dst\>, [address] 

- Example: 
    - mov r0, #0x4 
    - this moves number 4 into register r0 

## Our first code 

```assembly
.global _start
.section .text

_start:
    mov r0, #4

.section .data
```

`.global _start` is what we call a 'entry point' , the entry point is where the execution will start. The default label name used to identify the entry point is **\_start**


to run above code :
```sh
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

[google has an awesome documentation for us](https://chromium.googlesource.com/chromiumos/docs/+/master/constants/syscalls.md#arm-32_bit_EABI)

from above link we know our syscall is 1, we will pass it using immidiate passing technique 

so we add a syscall in our previous program and assemble and link it again

out program looks like this : 

```assembly
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

We use `write` to print data on screen . 

Lets look at man page of write `man 2 write` 
and we found this : 

```
#include <unistd.h>

ssize_t write(int fd, const void *buf, size_t count);
```

Write takes 3 arguments: 
    - fd : file descriptor 
        - 0 stdin standard input 
        - 1 stdout standard output 
        - 2 stderr standard error 
    - buf : Basically what we want to write; we will be loading this from the memory 
    - `size_t` : Size of what we want to write, this too will be loaded from memory 



```assembly
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

so return value will be 1 : `mov r0,#1` (first argument)

We take data from memory and assign it to some registers: 
    ``` assembly
    ldr r1,=message
    ldr r2,=len
    ```
r1 - second argument to write 
r2 - third argument to write 

Now because we need to write on screen, our first syscall is for write which is 4 : 
    ```assembly
    mov r7,#4 
    swi 0 
    ```

Now we haven't exited from the program, for that another syscall for exit now : 
    ```asm
    mov r7, #1
    swi 0 
    ```

our full code : 
```assembly
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
## Third code (/bin/sh")

We are gonna start a `/bin/sh` using ARM ASM code. 

This code will be like hello word except this time instead of `write` we will use execve 

from man pages : 
```
#include <unistd.h>

int execve(const char *pathname, char *const argv[],
                  char *const envp[]);
```
- For pathname we will pass "/bin/sh"
- there are no argumnents to "/bin/sh" So null and null can be represented using 0 
- `envp`  is an array of strings, conventionally of the form key=value, which are passed as environment to the new program. (From man pages)  : THIS TOO IS NULL

We can pass null in many other forms, basically the principal remains same that we are passing a 0, 

### Passing NULL in ASM 

- **Method - 1**

Using a simple 0(immidiate) 

code: 
```assembly
.global _start 

.text 

_start : 
    ldr r0,=path 
    mov r1,#0
    mov r2,#0
    mov r7,#11
    swi 0


.data 
path:
    .asciz "/bin/sh"
```

- **Method - 2**

using subtraction 

We will basically use `sub` instruction, and subtract a register by itself and store the value in that register, i.e r1 = r1 - r1 

Which is basically 0 

code : 
```assembly 
.global _start 

.text 

_start : 
    ldr r0,=path
    sub r1,r1,r1 // r1 = r1 - r1 ; which is basically r1 = 0 
    sub r2,r2,r2 
    mov r7,#11 
    swi 0 

.data 
path : 
    .asciz "/bin/sh"
```

- **Method - 3** 

We can use `xor`, similar to `sub` instruction to get 0 result 

xoring a register by itself and then storing the result in that particulare register. 

code : 

```assembly
.global _start 

.text 

_start : 

    ldr r0,=path 
    eor r1,r1,r1
    eor r2,r2,r2 
    add r7,#11
    swi 0 

.data 
path:
    .asciz "/bin/sh"
``
## Funtions 

2 function code will look like this : 

```
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
```
As you can see instead of using 2 syscalls in `_start` we have made the code look neat by making 2 funtions 

In general assembler will assembly the code from line 1 to ending and will execute in that order as it is written, **IF NO BRANCHING IS DONE**

## PC register 
- Program counter - stores the value of program 
- PC is always 2 instructions aheah of current register. 


## Branching 
Branching is a way to "call" a "function" from a function. 
General syntax:  
```assembly 
b{cond} function_name
```

Lets see with this easy ex : 

```assembly 
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
```

lets look at the return code : 

```bash 
$ echo $? 
10 
```

Why we got 10 when r0 at the end of the code is 20, because we have branched the code, and have changed its control flow, We can do this by using PC register also.
So everything under the line `b func2` has been assembled but does not take affect because the program has exited before. 

**Using pc:** 
```
.text 

.global _start 

_start : 
    mov r1, #5 
    add r0, r1, #5 // r0 = 10 
    add pc,pc,#8  
    add r0, r0, #10 // r0 = 20 
    mov r7, #1
    swi 0 

func2: 
    mov r7, #1 
    swi 0 
```

Because pc contains the address of 2 instruction ahead and because every instruction is of 4 bytes, I added 4 + 4 + 4  = 12, So that pc points to first line of `func2`.  

## Thumb mode 
Some instructions doesn't need 32 bit of architecture to do their operation, they can do same using less bits. The ARM assembly programmers notices that some operations can do the same operation in 16 bit too. They identified that, a lot of memory is going in waste. To fix this they introduced thumb mode where user can do the operations in 16 bit mode. 

So basically thumb mode is a way to write code efficiently. In ARM mode(32 bit), an intruction uses 4 bits but in thumb mode(16 bit) an instruction uses 2 bits only. So we can use remaining 2 bits in some other operation. 

Thumb instruction set can improve
    - Code density 
    - power-efficiency 
    - Save cost 
    - Enhance performance 

Now how does the processor know when to enter thumb mode ? For this CPSR and `bx` instruction comes into play. 
## CPSR - Current program state register

The Current Program Status Register (CPSR) holds processor status and control information. It looks somethings like this: 

![http://izobs.github.io/picture/arm1.png]()


Above is a pic of a **register** and columns denote the **flag** in registers. Notice the thumb state register, this resgister denotes which state we are running our code in. 

If it is 1, we are doing our operations in thumb mode else in 32 bit armv7 mode. It is also known as **T bit**. 


## How to give instruction to switch to thumb mode ? 

How to give instruction to processor to change T bit to 1. For that we use `bx` instruction(Branch and exchange instruction).   
