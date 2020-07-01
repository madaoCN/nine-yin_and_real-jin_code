.extern _printf _fopen _fclose
.align 4
.data
  
  msg:  .asciz  "hello, world\n"  

.text  
.global _main


_main:

  stp x29, x30, [sp,#-0x10]!
  stp x0,x1,[sp,#-0x10]!
  stp x2,x3,[sp,#-0x10]!
  stp x4,x16,[sp,#-0x10]!

  mov x29, sp
  sub sp,sp,#0x20

  mov x0,0
  bl __dyld_get_image_header

  mov x4,x0

  adr x0, lazy_bind_info_src
  ldr x1, lazy_bind_info_dst_address

  ;add x0,x0,x4
  add x1,x1,x4

  mov x2,#0x4

  bl recovery_info

  add sp,sp,#0x20
  mov sp,x29

  ldp x4,x16,[sp],0x10
  ldp x2,x3,[sp],0x10
  ldp x0,x1,[sp],0x10
  ldp x29,x30,[sp],0x10

  b #0x24

recovery_info:

      stp x29, x30, [sp,#-0x10]!

      ;循环恢复 lazy_bind_info
      loop:
      ldr x3, [x0]
      add x0,x0,#0x8
      str x3, [x1]
      add x1,x1,#0x8

      subs x2, x2, #1
      bne loop

      adr x0, la_symbol_ptr_src
      ldr x1, la_symbol_ptr_dst_address

      ;add x0,x0,x4   ;x0 加上 image 地址
      add x1,x1,x4   ;x1 加上 image 地址

      ldr x3, [x0]
      add x3,x3,x4   ;la_symbol_ptr_dst 需要加上 image 地址
      str x3, [x1]

      ldp x29,x30,[sp],0x10

      ret

  lazy_bind_info_src:
      .byte 0x72,0x08,0x13,0x40,0x5F,0x5F,0x64,0x79,0x6C,0x64,0x5F,0x67,0x65,0x74,0x5F,0x69,0x6D,0x61,0x67,0x65,0x5F,0x68,0x65,0x61,0x64,0x65,0x72,0x00,0x90,0x00,0x00,0x00

  lazy_bind_info_dst_address:

    .byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00

  la_symbol_ptr_src:
    .byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00

  la_symbol_ptr_dst_address:
    .byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00


