//
//  shellcode.h
//  insert_code
//
//  Created by boot on 2018/1/5.
//  Copyright © 2018年 exchen. All rights reserved.
//


#include <stdio.h>

struct lazy_bind_image_header_info{
    int8_t segment;
    char offset[1];
    int8_t dylib;
    int8_t flags;
    char name[24];
    int8_t do_bind;
    int8_t done;
};

struct lazy_bind_image_header_info2{
    int8_t segment;
    char offset[2];
    int8_t dylib;
    int8_t flags;
    char name[24];
    int8_t do_bind;
    int8_t done;
};

struct shellcode_info{
    char opcode1[20];
    
    int8_t ldr_pc_opcode[16];
    int8_t relative_stub_offset[4];
    
    int8_t opcode2[24];
    
    int8_t bl_copy_word_address[3];
    int8_t bl_opcode_copy_word[1];
    
    int8_t pop[4];
    
    int8_t blx_main_address[3];
    int8_t blx_opcode_main[1];
    
    int8_t opcode3[8];
    int8_t opcode4[52];
    
    int8_t lazy_bind_data[32];
    int8_t lazy_bind_data2[4];
    
    int8_t la_symbol_ptr_data[4];
    int8_t la_symbol_ptr_data2[4];
    
    int8_t src_lazy_bind_address[4];
    int8_t dst_lazy_bind_address[4];
    
    int8_t src_la_symbol_ptr_address[4];
    int8_t dst_la_symbol_ptr_address[4];
    
    int8_t end[2];
};

struct shellcode64_info{
    char opcode1[28];
    
    int8_t bl_get_image_address[3];
    int8_t bl_opcode_get_image[1];
    
    int8_t opcode2[48];
    
    int8_t blx_main_address[3];
    int8_t blx_opcode_main[1];
    
    int8_t opcode3[84];
    
    int8_t lazy_bind_data[32];
    int8_t dst_lazy_bind_address[8];
    
    int8_t src_la_symbol_ptr_data[8];
    int8_t dst_la_symbol_ptr_address[8];
};
