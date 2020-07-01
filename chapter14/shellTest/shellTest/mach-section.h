//
//  mach-section.h
//  insert_code
//
//  Created by boot on 2018/1/4.
//  Copyright © 2018年 exchen. All rights reserved.
//

#ifndef mach_section_h
#define mach_section_h

#include <stdio.h>

#import <mach-o/fat.h>
#import <mach-o/loader.h>

struct section get_section_name_info(FILE *fp, struct segment_command sc,char *section_name);
struct section_64 get_section64_name_info(FILE *fp, struct segment_command_64 sc,char *section_name);

struct section get_section_flags_info(FILE *fp, struct segment_command sc,int flags);
struct section_64 get_section64_flags_info(FILE *fp, struct segment_command_64 sc,int flags);

#endif /* mach_section_h */
