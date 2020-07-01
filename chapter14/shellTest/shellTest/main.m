//
//  main.m
//  shellTest
//
//  Created by boot on 2018/5/22.
//  Copyright © 2018年 exchen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <mach-o/fat.h>
#import <mach-o/loader.h>

#import <sys/_endian.h>

#include <copyfile.h>

#import "mach-section.h"
#import "shellcode.h"

struct shellcode_info shellcode_armv7 = {
    
    //opcode1
    {0x80, 0x40, 0x2D, 0xE9,    //0xe92d4080   push   {r7, lr}
     0x0D, 0x70, 0xA0, 0xE1,    //0xe1a0700d   mov    r7, sp
     0x01, 0xDC, 0x4D, 0xE2,    //0xe24ddc01   sub    sp, sp, #256
     0x1f, 0x50, 0x2D, 0xE9,    //0xe92d401f   push   {r0, r1, r2, r3, r4, r12, lr}
     0x00, 0x00, 0x20, 0xE0},   //0xe0200000   eor    r0, r0, r0
    
    {0x0C, 0xE0, 0x8F, 0xE2,    //0xe28fe00c   add    lr, pc, #12
     0x04, 0xC0, 0x9F, 0xE5,    //0xe59fc004   ldr    r12, [pc, #0x4]
     0x0C, 0xC0, 0x8F, 0xE0,    //0xe08fc00c   add    r12, pc, r12
     0x0C, 0xF0, 0xA0, 0xE1,},  //0xe1a0f00c   mov    pc, r12
    
    {0x00, 0x00, 0xA0, 0xE1},   //relative_stub_offset
    
    //opcode2
    {0x00, 0x40, 0xA0, 0xE1,    //0xe1a04000   mov    r4, r0
     0x80, 0x00, 0x9F, 0xE5,    //0xe59f0080   ldr    r0, [pc, #0x80]
     0x80, 0x10, 0x9F, 0xE5,    //0xe59f1080   ldr    r1, [pc, #0x80]
     0x04, 0x00, 0x80, 0xE0,    //0xe0800004   add    r0, r0, r4
     0x04, 0x10, 0x81, 0xE0,    //0xe0811004   add    r1, r1, r4
     0x08, 0x20, 0xA0, 0xE3},   //0xe3a02008   mov    r2, #8
    
    //bl_copy_word_address  bl_opcode_copy_word
    {0x03, 0x00, 0x00}, {0xEB},  //0xeb000003   bl     0x2a884
    
    //pop
    {0x1f, 0x50, 0xBD, 0xE8},    //0xe8bd401f   pop    {r0, r1, r2, r3, r4, r12, lr}
    
    //main
    {0x2B, 0x00, 0x00}, {0xFA},  //0xfa000732   blx    0x2c548
    
    //opcode3
    {0x01, 0xDC, 0x8D, 0xE2,    //0xe28ddc01   add    sp, sp, #256
     0x80, 0x80, 0xBD, 0xE8},   //0xe8bd8080   pop    {r7, pc}
    
    //opcode4
    {0x80, 0x40, 0x2D, 0xE9,    //0xe92d4080   push   {r7, lr}
     0x04, 0x30, 0x90, 0xE4,    //0xe4903004   ldr    r3, [r0], #4
     0x04, 0x30, 0x81, 0xE4,    //0xe4813004   str    r3, [r1], #4
     0x01, 0x20, 0x52, 0xE2,    //0xe2522001   subs   r2, r2, #1
     0xFB, 0xFF, 0xFF, 0x1A,    //0x1afffffb   bne    0x2a888
     0x4C, 0x00, 0x9F, 0xE5,    //0xe59f004c   ldr    r0, [pc, #0x4c]
     0x4C, 0x10, 0x9F, 0xE5,    //0xe59f104c   ldr    r1, [pc, #0x4c]
     0x04, 0x00, 0x80, 0xE0,    //0xe0800004   add    r0, r0, r4
     0x04, 0x10, 0x81, 0xE0,    //0xe0811004   add    r1, r1, r4
     0x00, 0x30, 0x90, 0xE5,    //0xe5903000   ldr    r3, [r0]
     0x04, 0x30, 0x83, 0xE0,    //0xe0833004   add    r3, r3, r4
     0x00, 0x30, 0x81, 0xE5,    //0xe5813000   str    r3, [r1]
    
     0x80, 0x80, 0xBD, 0xE8},   //0xe8bd8080   pop    {r7, pc}
    
    // lazy_bind_data1
    {0x72, 0x08, 0x13, 0x40, 0x5F, 0x5F, 0x64, 0x79, 0x6C, 0x64, 0x5F, 0x67, 0x65, 0x74, 0x5F, 0x69,
     0x6D, 0x61, 0x67, 0x65, 0x5F, 0x68, 0x65, 0x61, 0x64, 0x65, 0x72, 0x00, 0x90, 0x00, 0x00, 0x00},
    
    {0x00, 0x00, 0x00, 0x00},   //lazy_bind_data2
    {0x00, 0x00, 0x6C, 0x60},   //la_symbol_ptr_data
    {0x00, 0x00, 0x00, 0x00},   //la_symbol_ptr_data2
    {0x88, 0x7e, 0x00, 0x00},   //src_lazy_bind_address
    {0x48, 0xc0, 0x00, 0x00},   //dst_lazy_bind_address
    {0xA0, 0xBF, 0x00, 0x00},   //src_la_symbol_ptr_address
    {0xA4, 0xBF, 0x00, 0x00},   //dst_la_symbol_ptr_address
    {0x00, 0x46}                //end
};


struct shellcode64_info shellcode_arm64 = {
    //opcode1
    {0xFD, 0x7B, 0xBF, 0xA9,    //0xa9bf7bfd   stp    x29, x30, [sp, #-0x10]!
     0xE0, 0x07, 0xBF, 0xA9,    //0xa9bf07e0   stp    x0, x1, [sp, #-0x10]!
     0xE2, 0x0F, 0xBF, 0xA9,    //0xa9bf0fe2   stp    x2, x3, [sp, #-0x10]!
     0xE4, 0x43, 0xBF, 0xA9,    //0xa9bf17e4   stp    x4, x16, [sp, #-0x10]!
     0xFD, 0x03, 0x00, 0x91,    //0x910003fd   mov    x29, sp
     0xFF, 0x83, 0x00, 0xD1,    //0xd10083ff   sub    sp, sp, #0x20
     0x00, 0x00, 0x80, 0xD2},   //0xd2800000   mov    x0, #0x0
    
    //bl_get_image_address  bl_opcode_get_image
    {0x20, 0x00 ,0x00}, {0x94},
    
    //opcode2
    {0xE4, 0x03, 0x00, 0xAA,    //0xaa0003e4   mov    x4, x0
     0x20, 0x04, 0x00, 0x10,    //0x10000360   adr    x0, #0x6c
     0x01, 0x05, 0x00, 0x58,    //0x58000441   ldr    x1, #0x88
     0x21, 0x00, 0x04, 0x8B,    //0x8b040021   add    x1, x1, x4
     0x82, 0x00, 0x80, 0xD2,    //0xd2800082   mov    x2, #0x4
     0x08, 0x00, 0x00, 0x94,    //0x94000008   bl     0x1000c5f58
     0xFF, 0x83, 0x00, 0x91,    //0x910083ff   add    sp, sp, #0x20
     0xBF, 0x03, 0x00, 0x91,    //0x910003bf   mov    sp, x29
     0xE4, 0x43, 0xC1, 0xA8,    //0xa8c117e4   ldp    x4, x16, [sp], #0x10
     0xE2, 0x0F, 0xC1, 0xA8,    //0xa8c10fe2   ldp    x2, x3, [sp], #0x10
     0xE0, 0x07, 0xC1, 0xA8,    //0xa8c107e0   ldp    x0, x1, [sp], #0x10
     0xFD, 0x7B, 0xC1, 0xA8},   //0xa8c17bfd   ldp    x29, x30, [sp], #0x10
    
    //blx_main_address  blx_opcode_main
    {0x09, 0x00, 0x00}, {0x14},
    
    //opcode3
    {0xFD, 0x7B, 0xBF, 0xA9,    //0xa9bf7bfd   stp    x29, x30, [sp, #-0x10]!
     0x03, 0x00, 0x40, 0xF9,    //0xf9400003   ldr    x3, [x0]
     0x00, 0x20, 0x00, 0x91,    //0x91002000   add    x0, x0, #0x8
     0x23, 0x00, 0x00, 0xf9,    //0xf9000023   str    x3, [x1]
     0x21, 0x20, 0x00, 0x91,    //0x91002021   add    x1, x1, #0x8
     0x42, 0x04, 0x00, 0xF1,    //0xf1000442   subs   x2, x2, #0x1
     0x61, 0xFF, 0xFF, 0x54,    //0x54ffff61   b.ne   0x1000c5f5c
     0x00, 0x03, 0x00, 0x10,    //0x10000240   adr    x0, #0x48
     0x21, 0x03, 0x00, 0x58,    //0x58000261   ldr    x1, #0x4c
     0x21, 0x00, 0x04, 0x8B,    //0x8b040021   add    x1, x1, x4
     0x03, 0x00, 0x40, 0xF9,    //0xf9400003   ldr    x3, [x0]
     0x63, 0x00, 0x04, 0x8B,    //0x8b040063   add    x3, x3, x4
     0x23, 0x00, 0x00, 0xF9,    //0xf9000023   str    x3, [x1]
    
     //
     0xFD, 0x7B, 0xC1, 0xA8,    //0xa8c17bfd   ldp    x29, x30, [sp], #0x10
     0xC0, 0x03, 0x5F, 0xD6},   //0xd65f03c0   ret
    
    {0x72, 0x08, 0x13, 0x40, 0x5F, 0x5F, 0x64, 0x79, 0x6C, 0x64, 0x5F, 0x67, 0x65, 0x74, 0x5F, 0x69,
     0x6D, 0x61, 0x67, 0x65, 0x5F, 0x68, 0x65, 0x61, 0x64, 0x65, 0x72, 0x00, 0x90, 0x00, 0x00, 0x00},   //lazy_bind_data
    
    {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00},  //dst_lazy_bind_address
    
    {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00},  //src_la_symbol_ptr_data
    
    {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00}  //dst_la_symbol_ptr_address
};

void encode_uleb128(unsigned int value, unsigned char *leb128_buffer)
{
    int pos = 0;
    while (value != 0) {
        leb128_buffer[pos++] = value & 0x7F | 0x80; //每个字节标识信息都设为1
        value >>= 7;
    }
    if (pos > 0)
        leb128_buffer[pos-1] &= 0x7F;  //将最后一个字节的标识信息设为0
}

void insert_code(FILE *fp,int type, long farch_offset){
    
    struct mach_header mh = {0};
    struct mach_header_64 mh64 = {0};
    int ncmds = 0;
    
    //偏移到 farch_offset
    fseek(fp, farch_offset, SEEK_SET);
    
    if (type == CPU_TYPE_ARM) {
        
        //读取 mach_head
        fread(&mh, sizeof(mh), 1, fp);
        ncmds = mh.ncmds;
    }
    else if(type == CPU_TYPE_ARM64)
    {
        //读取 mach_head_64
        fread(&mh64, sizeof(mh64), 1, fp);
        ncmds = mh64.ncmds;
    }
    
    //文件偏移信息
    uint32_t text_file_offset = 0;   // 代码在文件的偏移
    uint32_t new_text_file_offset = 0;  //新的代码在文件的偏移
    long text_section_header_file_offset = 0;  // 代码节头在文件里的偏移位置
    long epc_file_offset = 0;   // LC_MAIN 在文件里的偏移位置
    long dic_file_offset = 0;  // LC_DYLD_INFO_ONLY 在文件里的偏移位置
    long sc_linkedit_file_offset = 0;        //linkedit 段头信息的偏移
    
    //新的头结构信息
    struct entry_point_command new_epc = {0};  //新的 LC_MAIN 信息
    struct section new_text_section = {0};    //新的代码节信息
    struct section_64 new_text_section64 = {0};    //新的代码节信息
    struct segment_command new_sc_linkedit = {0};   //新的 linkedit 段头信息
    struct segment_command_64 new_sc64_linkedit = {0}; //新的 linkedit 64 位段头信息
    
    //数据偏移信息
    uint32_t lazy_bind_info_offset = 0; //lazy_bind_info 的偏移
    uint32_t stub_offset = 0;           //stubsymbol 的篇移
    uint32_t la_symbol_ptr_offset = 0;  //la_symbol_ptr 的偏移
    
    uint64_t data_segment_offset = 0;   // data_segment 的偏移
    uint64_t old_entry_point = 0;       //原始的代码入口点
    
    bool already_find_libSystem = 0;   //libSystem 的位置是否找到了
    int libSystem_in_which  = 0;           //libSystem 在哪个位置
    
    int16_t lazy_bind_info_in_data_offset = 0;  //lazy_bind_info 第一个函数信息在数据据的偏移
    int lazy_bind_lib_in_which = 0;         //第一个函数在第几个 dylib 里
    
    //读取 load_command
    for (int j = 1; j <= ncmds; j++) {
        
        struct load_command lc = {0};
        
        long cur_offset = ftell(fp);
        
        fread(&lc, sizeof(lc), 1, fp);
        
        // 读取 LC_SEGMENT
        if(lc.cmd == LC_SEGMENT | lc.cmd == LC_SEGMENT_64){
            
            fseek(fp, cur_offset, SEEK_SET);
            
            if(type == CPU_TYPE_ARM){
                
                struct segment_command sc = {0};
                
                fread(&sc,sizeof(sc), 1, fp);
                
                if (strcmp(sc.segname, "__LINKEDIT") == 0) {
                    
                    sc_linkedit_file_offset = ftell(fp) - sizeof(sc);  // 获取 section 偏移
                    memcpy(&new_sc_linkedit, &sc, sizeof(sc));
                }
                else if(strcmp(sc.segname, "__DATA") == 0){
                    
                    data_segment_offset = sc.fileoff;
                }
                
                struct section st_section = get_section_name_info(fp,sc,"__text");   // 获取 text 节的信息
                if (st_section.offset != 0) {
                    
                    text_section_header_file_offset = ftell(fp);  // 获取 section 偏移
                    
                    text_file_offset = st_section.offset;
                    memcpy(&new_text_section, &st_section, sizeof(st_section));
                }
                
                st_section = get_section_flags_info(fp, sc, S_SYMBOL_STUBS | S_ATTR_PURE_INSTRUCTIONS | S_ATTR_SOME_INSTRUCTIONS);
                if (st_section.offset != 0) {
                    
                    stub_offset = st_section.offset;
                }
                
                st_section = get_section_flags_info(fp, sc, S_LAZY_SYMBOL_POINTERS);
                if (st_section.offset != 0) {
                    
                    la_symbol_ptr_offset = st_section.offset;
                }
            }
            else if(type == CPU_TYPE_ARM64){
                
                struct segment_command_64 sc64 = {0};
                
                fread(&sc64,sizeof(sc64), 1, fp);
                
                if (strcmp(sc64.segname, "__LINKEDIT") == 0) {
                    
                    sc_linkedit_file_offset = ftell(fp) - sizeof(sc64);  // 获取 linkedit 段在文件的偏移
                    memcpy(&new_sc64_linkedit, &sc64, sizeof(sc64));
                }
                else if(strcmp(sc64.segname, "__DATA") == 0){
                    
                    data_segment_offset = sc64.fileoff;
                }
                
                
                struct section_64 st_section64 = get_section64_name_info(fp,sc64,"__text");   // 获取 text 节的信息
                if (st_section64.offset != 0) {
                    
                    text_section_header_file_offset = ftell(fp);  // 获取 text section header 偏移
                    
                    text_file_offset = st_section64.offset;
                    memcpy(&new_text_section64, &st_section64, sizeof(st_section64));
                }
                
                st_section64 = get_section64_flags_info(fp, sc64, S_SYMBOL_STUBS | S_ATTR_PURE_INSTRUCTIONS | S_ATTR_SOME_INSTRUCTIONS);
                if (st_section64.offset != 0) {
                    
                    stub_offset = st_section64.offset;
                }
                
                st_section64 = get_section64_flags_info(fp, sc64, S_LAZY_SYMBOL_POINTERS);
                if (st_section64.offset != 0) {
                    
                    la_symbol_ptr_offset = st_section64.offset;
                }
            }
            
        }
        else if (lc.cmd == LC_MAIN) {
            
            struct entry_point_command epc = {0};
            
            fseek(fp, cur_offset, SEEK_SET);
            
            epc_file_offset = ftell(fp);
            
            fread(&epc, sizeof(epc), 1, fp);
            
            if (epc.entryoff != 0) {
                
                new_epc.cmd = LC_MAIN;
                new_epc.cmdsize = epc.cmdsize;
                new_epc.entryoff = epc.entryoff;
                new_epc.stacksize = epc.stacksize;
                
                old_entry_point = epc.entryoff;
            }
        }
        else if (lc.cmd == LC_DYLD_INFO_ONLY){
            
            struct dyld_info_command dic = {0};
            
            fseek(fp, cur_offset, SEEK_SET);
            
            dic_file_offset = ftell(fp);
            
            fread(&dic, sizeof(dic), 1, fp);
            
            lazy_bind_info_offset = dic.lazy_bind_off;
        }
        else if(lc.cmd == LC_LOAD_DYLIB | lc.cmd ==  LC_ID_DYLIB | lc.cmd == LC_LOAD_WEAK_DYLIB | lc.cmd == LC_REEXPORT_DYLIB){
            
            //找 libSystem 在第一个位置
            if (already_find_libSystem == false) {
                
                struct dylib_command dyc = {0};
                
                fseek(fp, cur_offset, SEEK_SET);
                fread(&dyc, sizeof(dyc), 1, fp);
                
                int dylib_name_len = lc.cmdsize - dyc.dylib.name.offset;
                char *str_dylib_name = (char*)malloc(dylib_name_len);
                fread(str_dylib_name, dylib_name_len, 1, fp);
                
                libSystem_in_which ++;
                
                if (strcmp(str_dylib_name, "/usr/lib/libSystem.B.dylib") == 0) {
                    
                    already_find_libSystem = true;
                }
                
                free(str_dylib_name);
            }
            
        }
        
        long next_lc_offset = cur_offset + lc.cmdsize;
        fseek(fp, next_lc_offset, SEEK_SET);
    }
    
    // 读取 lazy_bind_info
    fseek(fp, lazy_bind_info_offset+farch_offset, SEEK_SET);
    char lazy_bind_buffer[32] = {0};
    fread(&lazy_bind_buffer, sizeof(lazy_bind_buffer), 1, fp);
    
    //修改 lazy_info 结构
    char *lazy_bind_info_in_data_offset_leb128 = (char*)malloc(1);
    char *lazy_bind_lib_in_which_leb128 = (char*)malloc(1);
    char *new_lazy_bind_info = (char*)malloc(32);
    int info_offset_len = 0;
    
    lazy_bind_info_in_data_offset = la_symbol_ptr_offset - data_segment_offset;
    
    if(lazy_bind_info_in_data_offset < 128){
        info_offset_len = 1;
    }
    else if(lazy_bind_info_in_data_offset < (128*128)) {
        
        lazy_bind_info_in_data_offset_leb128 = realloc(lazy_bind_info_in_data_offset_leb128, 1);
        info_offset_len = 2;
    }
    else {
        
        lazy_bind_info_in_data_offset_leb128 = realloc(lazy_bind_info_in_data_offset_leb128, 2);
        info_offset_len = 3;
    }
    
    encode_uleb128(lazy_bind_info_in_data_offset, lazy_bind_info_in_data_offset_leb128);
    
    int fun_name_len = strlen("__dyld_get_image_header\0");
    
    char bind_opcode_set_segment_and_offset_uleb = BIND_OPCODE_SET_SEGMENT_AND_OFFSET_ULEB + 2; // 数据段一般都是在第二个段
    char bind_opcode_set_dylib_ordinal_uleb = BIND_OPCODE_SET_DYLIB_ORDINAL_ULEB;
    char bind_opcode_set_symbol_trailing_flags_imm = BIND_OPCODE_SET_SYMBOL_TRAILING_FLAGS_IMM;
    char bind_opcode_do_bind = BIND_OPCODE_DO_BIND;
    char bind_opcode_done = BIND_OPCODE_DONE;
    
    memset(new_lazy_bind_info, 0, 32);
    memcpy(new_lazy_bind_info, &bind_opcode_set_segment_and_offset_uleb ,1);  //segment
    memcpy(new_lazy_bind_info + 1,lazy_bind_info_in_data_offset_leb128,info_offset_len);  //offset
    
    int libSystem_in_which_len = 0;
    if (libSystem_in_which < 16) {
        
        libSystem_in_which_len = 1;
        lazy_bind_lib_in_which = libSystem_in_which + BIND_OPCODE_SET_DYLIB_ORDINAL_IMM;
        memcpy(new_lazy_bind_info + 1 + info_offset_len, &lazy_bind_lib_in_which, 1);
    }
    else {
        
        libSystem_in_which_len = 2;
        memcpy(new_lazy_bind_info + 1 + info_offset_len, &bind_opcode_set_dylib_ordinal_uleb, 1);
        memcpy(new_lazy_bind_info + 1 + info_offset_len+1, &libSystem_in_which, 1);
    }
    
    memcpy(new_lazy_bind_info + 1 + info_offset_len + libSystem_in_which_len, &bind_opcode_set_symbol_trailing_flags_imm,1);
    memcpy(new_lazy_bind_info + 2 + info_offset_len+ libSystem_in_which_len, "__dyld_get_image_header\0",fun_name_len);
    memcpy(new_lazy_bind_info + 3 + info_offset_len+ libSystem_in_which_len + fun_name_len, &bind_opcode_do_bind, 1);
    memcpy(new_lazy_bind_info + 4 + info_offset_len+ libSystem_in_which_len + fun_name_len, &bind_opcode_done, 1);
    
    //写入新的 lazy_bind_info
    fseek(fp, lazy_bind_info_offset+farch_offset,SEEK_SET);
    fwrite(new_lazy_bind_info, 32, 1, fp);
    
    free(lazy_bind_info_in_data_offset_leb128);
    free(lazy_bind_lib_in_which_leb128);
    free(new_lazy_bind_info);
    
    if (type == CPU_TYPE_ARM64) {
        
        // 修改 shellcode
        new_text_file_offset = text_file_offset - sizeof(shellcode_arm64);
        
        //计算跳转到 get_image_address 函数的地址
        int shell_bl_get_image_address = new_text_file_offset + 28;
        int32_t shell_get_image_address = (stub_offset - shell_bl_get_image_address) / 4;
        
        memcpy(shellcode_arm64.bl_get_image_address,&shell_get_image_address,sizeof(shellcode_arm64.bl_get_image_address));
        memcpy(shellcode_arm64.dst_lazy_bind_address,&lazy_bind_info_offset,sizeof(lazy_bind_info_offset));
        memcpy(shellcode_arm64.lazy_bind_data,&lazy_bind_buffer,sizeof(lazy_bind_buffer));   //保存好原来的 lazy_bind_data
        
        //计算跳转到 main 函数的地址
        int shell_bl_address = new_text_file_offset + 80;
        int32_t shell_main_address = (int32_t)(old_entry_point - shell_bl_address) / 4;
        
        memcpy(shellcode_arm64.blx_main_address,&shell_main_address,sizeof(shellcode_arm64.blx_main_address));
        
        // 读取 la_symbol_ptr
        fseek(fp, la_symbol_ptr_offset + farch_offset, SEEK_SET);
        long la_symbol_ptr_buffer;
        fread(&la_symbol_ptr_buffer, sizeof(la_symbol_ptr_buffer), 1, fp);
        
        //写入 la_symbol_ptr_data
        long dst_la_symbol_ptr_data = la_symbol_ptr_buffer - 0x100000000;
        memcpy(shellcode_arm64.src_la_symbol_ptr_data, &dst_la_symbol_ptr_data, sizeof(la_symbol_ptr_buffer));
        
        // 写入 la_symbol_ptr_address
        long dst_la_symbol_ptr_offset = la_symbol_ptr_offset;
        memcpy(shellcode_arm64.dst_la_symbol_ptr_address, &dst_la_symbol_ptr_offset, sizeof(dst_la_symbol_ptr_offset));
        
        //写入 shellcode
        fseek(fp, new_text_file_offset+farch_offset,SEEK_SET);
        fwrite(&shellcode_arm64, sizeof(shellcode_arm64), 1, fp);
        
        // 写入新的代码节信息
        new_text_section64.offset = new_text_file_offset;
        new_text_section64.size = new_text_section64.size + sizeof(shellcode_arm64);
        new_text_section64.addr = new_text_section64.addr - sizeof(shellcode_arm64);
        fseek(fp, text_section_header_file_offset,SEEK_SET);
        fwrite(&new_text_section64, sizeof(new_text_section64), 1, fp);
        
        //修改 LINKEDIT 段的内存属性
        new_sc64_linkedit.maxprot = 0x03;  //VM_PORT_READ + VM_PORT_WRITE
        new_sc64_linkedit.initprot = 0x03; //VM_PORT_READ + VM_PORT_WRITE
        fseek(fp, sc_linkedit_file_offset, SEEK_SET);
        fwrite(&new_sc64_linkedit, sizeof(new_sc64_linkedit), 1, fp);
    }
    else {
        
        //修改 shellcode
        new_text_file_offset = text_file_offset - sizeof(shellcode_armv7);
        
        //处理 4 字节对齐
        int fourbyte = new_text_file_offset % 4;
        if (fourbyte != 0) {
            new_text_file_offset = new_text_file_offset - fourbyte;
        }
        
        //计算跳转到 main 函数的地址
        int shell_bl_address = new_text_file_offset + 56 + 16;
        int32_t shell_main_address = (int32_t)(old_entry_point - shell_bl_address - 8) / 4;
        
        memcpy(shellcode_armv7.blx_main_address,&shell_main_address,sizeof(shellcode_armv7.blx_main_address));
        
        //计算跳转到 get_image_address 函数的地址
        int shell_bl_get_image_address = new_text_file_offset + 20 + 16;
        int32_t shell_get_image_address = stub_offset - shell_bl_get_image_address;
        
        //int32_t shell_get_image_address = (int32_t)(stub_offset - shell_bl_get_image_address - 8) / 4;
        
        //memcpy(shellcode_armv7.bl_get_image_address,&shell_get_image_address,sizeof(shellcode_armv7.bl_get_image_address));
        
        memcpy(shellcode_armv7.relative_stub_offset, &shell_get_image_address, sizeof(shellcode_armv7.relative_stub_offset));
        
        // 处理 lazy bind 的源地址和目标地址
        long shellcode_lazy_bind_info_offset = new_text_file_offset + 120 + 16;
        memcpy(shellcode_armv7.src_lazy_bind_address,&shellcode_lazy_bind_info_offset,sizeof(shellcode_lazy_bind_info_offset));
        memcpy(shellcode_armv7.dst_lazy_bind_address,&lazy_bind_info_offset,sizeof(lazy_bind_info_offset));
        memcpy(shellcode_armv7.lazy_bind_data,&lazy_bind_buffer,sizeof(lazy_bind_buffer));   //保存好原来的 lazy_bind_data
        
        // 读取 la_symbol_ptr
        fseek(fp, la_symbol_ptr_offset + farch_offset, SEEK_SET);
        int la_symbol_ptr_buffer;
        fread(&la_symbol_ptr_buffer, sizeof(la_symbol_ptr_buffer), 1, fp);
        
        //写入 la_symbol_ptr_data
        int dst_la_symbol_ptr_data = la_symbol_ptr_buffer - 0x4000;
        memcpy(shellcode_armv7.la_symbol_ptr_data, &dst_la_symbol_ptr_data, sizeof(la_symbol_ptr_buffer));
        
        int shellcode_la_symbol_ptr_offset = new_text_file_offset +  156  + 16;
        memcpy(shellcode_armv7.src_la_symbol_ptr_address, &shellcode_la_symbol_ptr_offset, sizeof(shellcode_la_symbol_ptr_offset));
        
        int dst_la_symbol_ptr_offset = la_symbol_ptr_offset;
        memcpy(shellcode_armv7.dst_la_symbol_ptr_address, &dst_la_symbol_ptr_offset, sizeof(dst_la_symbol_ptr_offset));
        
        //写入 shellcode
        fseek(fp, new_text_file_offset+farch_offset,SEEK_SET);
        fwrite(&shellcode_armv7, sizeof(shellcode_armv7), 1, fp);
        
        //写入新的代码节信息
        new_text_section.offset = new_text_file_offset;
        new_text_section.size = new_text_section.size + sizeof(shellcode_armv7) + fourbyte;
        new_text_section.addr = new_text_section.addr - sizeof(shellcode_armv7) - fourbyte;
        fseek(fp, text_section_header_file_offset,SEEK_SET);
        fwrite(&new_text_section, sizeof(new_text_section), 1, fp);
        
        //修改 LINKEDIT 段的内存属性
        new_sc_linkedit.maxprot = 0x03;  //VM_PORT_READ + VM_PORT_WRITE
        new_sc_linkedit.initprot = 0x03; //VM_PORT_READ + VM_PORT_WRITE
        fseek(fp, sc_linkedit_file_offset, SEEK_SET);
        fwrite(&new_sc_linkedit, sizeof(new_sc_linkedit), 1, fp);
    }
    
    //最后修改程序入口点
    new_epc.entryoff = new_text_file_offset;
    fseek(fp, epc_file_offset,SEEK_SET);
    fwrite(&new_epc, sizeof(new_epc), 1, fp);
}

int eXprotector(char *str_src_file, char *str_dst_file){
    
    struct fat_header fh = {0};
    struct fat_arch farch = {0};
    
    char binary_path[256];
    char new_binary_path[256];
    
    strcpy(binary_path, str_src_file);
    strcpy(new_binary_path, str_dst_file);
    
    // 将源文件复制一份到目标文件
    if(copyfile(binary_path, new_binary_path, NULL, COPYFILE_DATA | COPYFILE_UNLINK)) {
        printf("Failed to create %s\n", new_binary_path);
        exit(1);
    }

    FILE *fp = fopen(new_binary_path, "rb+");
    if (!fp) {
        return 0;
    }
    
    fread(&fh, sizeof(fh), 1, fp);
    
    //0xcafebabe || 0xbebafeca Fat 格式
    if (fh.magic == FAT_MAGIC || fh.magic == FAT_CIGAM) {
        
        //读取支持平台
        for (int i = 0; i < ntohl(fh.nfat_arch); i++) {
            
            fread(&farch, sizeof(farch), 1, fp);
            
            long next_farch_offset = ftell(fp);  //保存现在的 offset
            
            if (ntohl(farch.cputype) == CPU_TYPE_ARM){
                
                printf("arm\n");
                insert_code(fp, CPU_TYPE_ARM, ntohl(farch.offset));  //插入代码

            }
            else if(ntohl(farch.cputype) == CPU_TYPE_ARM64){
                
                printf("arm64\n");
                insert_code(fp, CPU_TYPE_ARM64, ntohl(farch.offset));  //插入代码
            }
            
            fseek(fp, next_farch_offset, SEEK_SET);
        }
        
    }
    //0xfeedface ARMV7
    else if(fh.magic == MH_MAGIC){
        
        printf("MH_MAGIC\n");
        insert_code(fp,CPU_TYPE_ARM,0);   //插入代码

    }
    //0xfeedfacf ARM64
    else if(fh.magic == MH_MAGIC_64){
        
        printf("MH_MAGIC_64\n");
        insert_code(fp,CPU_TYPE_ARM64,0);   //插入代码
    }
    
    fclose(fp);
    
    return 0;
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        eXprotector("/Users/boot/Desktop/testshell/tmp/ProtectMe", "/Users/boot/Desktop/testshell/tmp/ProtectMe_safe");
    }
    return 0;
}
