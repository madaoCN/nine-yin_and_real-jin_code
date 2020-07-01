.extern _printf _fopen _fclose
.align 4
.data
  
  msg:  .asciz  "hello, world\n"  

.text  
.global _main

_main:  
  stp x29, x30, [sp,#-0x10]!
  mov x29, sp
  sub sp,sp,#0x10
  add sp,sp,#0x10
  mov sp,x29
  ldp x29,x30,[sp],0x10
  ret

_test:
  stp x29, x30, [sp,#-0x10]!
  mov x29, sp
  sub sp,sp,#0x20
  bl _main
  add sp,sp,#0x20
  mov sp,x29
  ldp x29,x30,[sp],0x10
  ret