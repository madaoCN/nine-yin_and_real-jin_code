//
//  asm.s
//  XcodeASM
//
//  Created by exchen on 2018/5/20.
//  Copyright © 2018年 exchen. All rights reserved.
//

.text
.align 4
.globl _funcAdd_arm

_funcAdd_arm:
add w0,w0,w1
add w0,w0,w2
add w0,w0,w3
add w0,w0,w4
add w0,w0,w5
ret
