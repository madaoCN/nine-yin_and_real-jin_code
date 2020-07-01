.extern _printf
.align 4
.data
  strformat: .asciz "num %d %d %d\n"
  msg:  .asciz  "exchen\n"  

.text  
.global _main

_main:  
  push {r7,lr}  @将 r7 和 lr 寄存器入栈
  mov r7,sp		@将 sp 寄存器放入 r7
  sub sp,sp,#0x100 @开辟 0x100 个字节的空间

  ldr r0,=strformat  @第一个参数
  mov r1,#0x1        @第二个参数
  mov r2,#0x2        @第三个参数
  mov r3,#0x3        @第四个参数
  bl _printf

  add sp,sp,#0x100	@将开避的 0x100 个字节空间收回
  pop  {r7,pc}  @将 r7 和 lr 出栈