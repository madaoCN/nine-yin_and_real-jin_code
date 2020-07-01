.extern _printf _fopen _fclose __dyld_get_image_header
.align 4
.data
  
  msg:  .asciz  "hello, world\n"  

.text  
.global _main

_main:  
  push {r7,lr}

  mov r7,sp
  sub sp,sp,#0x100

  push {r0,r1,r2,r3,r4,r12,lr}   @保存相关的寄存器

  @ 获取 image 地址
  eor r0,r0

  add lr, pc, #0xc
  ldr r12, [pc, #0x4] 
  add r12, pc, r12
  mov pc, r12
  mov r0, r0

  mov r4,r0       @ 保存基址

  ldr r0, =lazy_bind_info_src    @r0=源数据区指针
  ldr r1, =lazy_bind_info_dst    @r1=目标数据区指针
  
  add r0,r0,r4    @r0 加上 image 地址
  add r1,r1,r4    @r1 加上 image 地址

  mov r2, #0x8    @需要恢复的 lazy_bind_info 长度为 32 字节，每次恢复 4 字节，所以需要循环 8 次

  bl recovery_info  @恢复信息

  pop {r0,r1,r2,r3,r4,r12,lr}  @恢复相关的寄存器

  blx _main

  add sp,sp,#0x100
  pop     {r7,pc}

recovery_info:

      push {r7,lr}

      @ 循环恢复 lazy_bind_info
      loop:
      ldr r3, [r0], #4  
      str r3, [r1], #4
      subs r2, r2, #1
      bne loop

      @ 恢复 la_symbol_ptr
      ldr r0, =la_symbol_ptr_src             @r0=源数据区指针
      ldr r1, =la_symbol_ptr_dst             @r1=目标数据区指针

      add r0,r0,r4   @r0 加上 image 地址
      add r1,r1,r4   @r1 加上 image 地址

      ldr r3, [r0]
      add r3,r3,r4   @ la_symbol_ptr_dst 需要加上 image 地址
      str r3, [r1]

      pop {r7,pc}

lazy_bind_info_src:
      .byte 0x72,0x08,0x13,0x40,0x5F,0x5F,0x64,0x79,0x6C,0x64,0x5F,0x67,0x65,0x74,0x5F,0x69,0x6D,0x61,0x67,0x65,0x5F,0x68,0x65,0x61,0x64,0x65,0x72,0x00,0x90,0x00,0x00,0x00

lazy_bind_info_dst: .byte 0x00,0x00,0x00,0x00

la_symbol_ptr_src:
      .byte 0x00,0x00,0x6c,0x60

la_symbol_ptr_dst:
      .byte 0x00,0x00,0x00,0x00

@_test:

  @push {r7,lr}
  @mov r7,sp
  @sub sp,sp,#0x200
  @blx _main
  @add sp,sp,#0x200
  @pop  {r7,pc}


