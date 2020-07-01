.extern _printf
.align 4

.text  
.global _main

_main:

  stp x29, x30, [sp,#-0x10]!  ;保存 x29 和 x30 寄存器到栈
  mov x29, sp           ;将 sp 寄存器放入 x29 寄存器
  sub sp,sp,#0x20       ;分配栈空间

  adr x0,msg			;第一个参数
  bl _printf

  add sp,sp,#0x20       ;释放栈空间
  mov sp,x29			;将 x29 给 sp
  ldp x29,x30,[sp],0x10  ;出栈给 x29 和 x30

  ret  ;返回

msg:
      .asciz "exchen\n"






