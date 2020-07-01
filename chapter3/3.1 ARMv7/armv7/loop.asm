.extern _printf
.align 4
.data
  msg:  .asciz  "exchen\n"  

.text  
.global _main

_main:  
  push {r7,lr}  @将 r7 和 lr 寄存器入栈
  mov r7,sp		@将 sp 寄存器放入 r7
  sub sp,sp,#0x100 @开辟 100 个字节的空间

  mov r2,#0x4	@循环 4 次，将值保存到 r2 寄存器
  str r2,[sp]	@将 r2 寄存器的数据保存到栈，以免被 printf 函数改变

  loop:
      
      ldr r0, =msg	@函数第一个参数
  	  bl _printf	@调用 printf 函数
  	  ldr r2,[sp]	@从栈中取值
      sub r2, r2, #1   @将 $r2 减去 1
      str r2,[sp]	@将运算过的值再给栈
      cmp r2,#0x0   @比较 r2 是否为 0
      bne loop		@如果 cmp 比较结果是 0, 则跳转

  add sp,sp,#0x100	@将开避的 100 个字节空间收回
  pop  {r7,pc}  @将 r7 和 lr 出栈