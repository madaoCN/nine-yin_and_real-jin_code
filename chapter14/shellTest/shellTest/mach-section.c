//
//  mach-section.c
//  insert_code
//
//  Created by boot on 2018/1/4.
//  Copyright © 2018年 exchen. All rights reserved.
//

#include "mach-section.h"

struct section get_section_name_info(FILE *fp, struct segment_command sc,char *section_name){
    
    long cur_offset = ftell(fp);  //保存当前 offset
    
    struct section st_section = {0};
    
    for (int i = 0; i < sc.nsects; i++) {
        
        fread(&st_section, sizeof(st_section), 1, fp);
        
        //printf("sectname: %s segname: %s\n",st_section.sectname,st_section.segname);
        
        int ret = strcmp(st_section.sectname, section_name);
        if (ret == 0)  {
            break;
        }else{
            memset(&st_section, 0, sizeof(st_section));
        }
    }
    
    fseek(fp, cur_offset, SEEK_SET);  //恢复 offset
    
    return st_section;
}

struct section_64 get_section64_name_info(FILE *fp, struct segment_command_64 sc,char *section_name){
    
    long cur_offset = ftell(fp);  //保存当前 offset
    
    struct section_64 st_section = {0};
    
    for (int i = 0; i < sc.nsects; i++) {
        
        fread(&st_section, sizeof(st_section), 1, fp);
        
        //printf("sectname: %s segname: %s\n",st_section.sectname,st_section.segname);
        
        int ret = strcmp(st_section.sectname, section_name);
        if (ret == 0) {
            break;
        }else{
            memset(&st_section, 0, sizeof(st_section));
        }
    }
    
    fseek(fp, cur_offset, SEEK_SET);  //恢复 offset
    
    return st_section;
}

struct section get_section_flags_info(FILE *fp, struct segment_command sc,int flags){
    
    long cur_offset = ftell(fp);  //保存当前 offset
    
    struct section st_section = {0};
    
    for (int i = 0; i < sc.nsects; i++) {
        
        fread(&st_section, sizeof(st_section), 1, fp);
        
        //printf("sectname: %s segname: %s\n",st_section.sectname,st_section.segname);
        
        if(st_section.flags == flags){
            break;
        }
        else{
            memset(&st_section, 0, sizeof(st_section));
        }
    }
    
    fseek(fp, cur_offset, SEEK_SET);  //恢复 offset
    
    return st_section;
}

struct section_64 get_section64_flags_info(FILE *fp, struct segment_command_64 sc,int flags){
    
    long cur_offset = ftell(fp);  //保存当前 offset
    
    struct section_64 st_section64 = {0};
    
    for (int i = 0; i < sc.nsects; i++) {
        
        fread(&st_section64, sizeof(st_section64), 1, fp);
        
        //printf("sectname: %s segname: %s\n",st_section64.sectname,st_section64.segname);
        
        if(st_section64.flags == flags){
            break;
        }else{
            memset(&st_section64, 0, sizeof(st_section64));
        }
    }
    
    fseek(fp, cur_offset, SEEK_SET);  //恢复 offset
    
    return st_section64;
}
