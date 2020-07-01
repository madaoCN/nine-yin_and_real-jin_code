.extern _printf _fopen _fclose
.align 4
.data
  
  msg:  .asciz  "hello, world\n"  

.text  
.global _main

_main:  
  push {r7,lr}
  mov r7,sp
  sub sp,sp,#0x100
  add sp,sp,#0x100
  pop  {r7,pc}

_test:

  push {r7,lr}
  mov r7,sp
  sub sp,sp,#0x200
  blx _main
  add sp,sp,#0x200
  pop  {r7,pc}