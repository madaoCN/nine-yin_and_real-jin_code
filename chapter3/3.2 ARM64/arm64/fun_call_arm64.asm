.extern _printf
.align 4

.text  
.global _main

_main:

  stp x29, x30, [sp,#-0x10]!  ;保存 x29 和 x30 寄存器到栈
  mov x29, sp           ;将 sp 寄存器放入 x29 寄存器
  sub sp,sp,#0x20       ;分配栈空间

  mov x0,1    ;第一个参数
  mov x1,2    ;第二个参数
  mov x2,3    ;第三个参数
  mov x3,4    ;第四个参数
  mov x4,5    ;第五个参数
  mov x5,6    ;第六个参数
  mov x6,7    ;第七个参数
  mov x7,8    ;第八个参数
  
  mov x8,9
  str x8,[sp] ;第九个参数
  
  mov x8,10
  str x8,[sp,0x8] ;第十个参数
  bl _func_add   ;调用自定义函数 add

  mov x1,x0
  adr x0,strformat      ;第一个参数
  str x1,[sp]           ;第二个参数

  bl _printf

  add sp,sp,#0x20       ;释放栈空间
  mov sp,x29			;将 x29 给 sp
  ldp x29,x30,[sp],0x10  ;出栈给 x29 和 x30

  ret  ;返回

_func_add:

  stp x29, x30, [sp,#-0x10]!  
  mov x29, sp           

  add x0,x0,x1
  add x0,x0,x2
  add x0,x0,x3
  add x0,x0,x4
  add x0,x0,x5
  add x0,x0,x6
  add x0,x0,x7

  ldr x8,[sp,0x10]
  add x0,x0,x8

  ldr x8,[sp,0x18]
  add x0,x0,x8
    
  mov sp,x29      
  ldp x29,x30,[sp],0x10

  ret  ;返回

msg:  .asciz "exchen\n"
strformat: .asciz "num %d\n"