.extern _printf
.align 4
.data
  msg:  .asciz  "hello, world\n"  

.text  
.global _main

_main:  
  push {r7,lr}  @将 r7 和 lr 寄存器入栈
  mov r7,sp		@将 sp 寄存器放入 r7
  sub sp,sp,#0x100 @开辟 100 个字节的空间

  ldr r0, =msg	@函数第一个参数
  bl _printf	@调用 printf 函数

  add sp,sp,#0x100	@将开避的 100 个字节空间收回
  pop  {r7,pc}  @将 r7 和 lr 出栈