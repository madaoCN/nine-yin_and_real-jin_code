//
//  antiPiracy.m
//  antiPiracy
//
//  Created by boot on 2018/4/23.
//  Copyright © 2018年 exchen. All rights reserved.
//

#import "antiPiracy.h"
#import <mach-o/fat.h>
#import <mach-o/loader.h>
#include <mach/mach.h>
#include <mach-o/dyld.h>
#import <CommonCrypto/CommonCrypto.h>

#define text_armv7_hash "1278b138fc6119bd3d58dd7a006b0071"
#define text_arm64_hash "8ab46dd81a5001eb1ce76e7fd5a07bfe"

struct ex_section_info {
    uint32_t    addr;        /* memory address of this section */
    uint32_t    size;        /* size in bytes of this section */
};

struct ex_section_info_64 {
    uint64_t    addr;        /* memory address of this section */
    uint64_t    size;        /* size in bytes of this section */
};

struct ex_section_info_64 get_text_section_info_64(struct mach_header_64 *mh, char *str_segname, char *str_section_name);
struct ex_section_info get_text_section_info(struct mach_header *mh, char *str_segname, char *str_section_name);

// 判断 LC_ENCRYPTION_INFO 是否为加密
static bool get_lc_encryption_info(FILE *fp){
    
    struct encryption_info_command eic = {0};
    
    long cur_offset = ftell(fp);  //保存当前 offset
    
    fseek(fp, -sizeof(struct load_command), SEEK_CUR);
    
    fread(&eic, sizeof(eic), 1, fp);
    
    if (eic.cryptid == 0) {
        
        return false;
    }
    
    fseek(fp, cur_offset, SEEK_SET);  //恢复 offset
    
    return true;
}

//获取所有的 loadcommand
static bool get_loadcommand(FILE *fp,int type, long farch_offset){
    
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
    
    //读取 load_command
    for (int j = 1; j <= ncmds; j++) {
        
        struct load_command lc = {0};
        
        long cur_offset = ftell(fp);
        
        fread(&lc, sizeof(lc), 1, fp);
        
        if (lc.cmd == LC_ENCRYPTION_INFO || lc.cmd == LC_ENCRYPTION_INFO_64) {
            
            //判断是否加密
            bool b_encrypt = get_lc_encryption_info(fp);
            if (!b_encrypt) {
                return false;
            }
            else{
                return true;
            }
        }
        
        //偏移到下一个 load_command
        long next_lc_offset = cur_offset + lc.cmdsize;
        fseek(fp, next_lc_offset, SEEK_SET);
    }
    
    return false;
}

//获取代码节地址和大小
struct ex_section_info_64 get_text_section_info_64(struct mach_header_64 *mh, char *str_segname, char *str_section_name){
    
    struct ex_section_info_64 st_ex_section_info_64 = {0};
    
    struct load_command *lc;
    lc = (struct load_command *)((unsigned char *)mh + sizeof(struct mach_header_64));
    
    uint64_t image_base_address_64 = (uint64_t)mh;
    
    for (int i=0; i<mh->ncmds; i++) {
        
        if(lc->cmd == LC_SEGMENT_64){
            
            struct segment_command_64 *sc_64;
            sc_64 = (struct segment_command_64 *)((unsigned char *)lc);
            
            struct section_64 *st_section_64 = (struct section_64*)((unsigned char *)sc_64 + sizeof(struct segment_command_64));
            NSLog(@"segname: %s", sc_64->segname);
            if(strcmp(sc_64->segname, str_segname) == 0) {
                
                for (int i = 0; i < sc_64->nsects; i++){
                    
                    NSLog(@"sectname: %s", st_section_64->sectname);
                    
                    if(strcmp(st_section_64->sectname, str_section_name) == 0){
                        
                        st_ex_section_info_64.addr = st_section_64->addr;
                        st_ex_section_info_64.size = st_section_64->size;
                        break;
                    }
                    
                    st_section_64 = (struct section_64*)((unsigned char *)st_section_64 + sizeof(struct section_64));
                }
            }
        }
        
        lc = (struct load_command *)((unsigned char *)lc+lc->cmdsize);
    }
    
    return st_ex_section_info_64;
}

//获取代码节地址和大小
struct ex_section_info get_text_section_info(struct mach_header *mh, char *str_segname, char *str_section_name){
    
    struct ex_section_info st_ex_section_info = {0};
    
    struct load_command *lc;
    lc = (struct load_command *)((unsigned char *)mh + sizeof(struct mach_header));
    
    uint32_t image_base_address = (uint32_t)mh;
    
    for (int i=0; i<mh->ncmds; i++) {
        
        if (lc->cmd == LC_SEGMENT) {
            
            struct segment_command *sc;
            sc = (struct segment_command *)((unsigned char *)lc);
            
            struct section *st_section = (struct section*)((unsigned char *)sc + sizeof(struct segment_command));
            
            if(strcmp(sc->segname, str_segname) == 0) {
                
                for (int i = 0; i < sc->nsects; i++){
                    
                    if(strcmp(st_section->sectname, str_section_name) == 0){
                        
                        st_ex_section_info.addr = image_base_address + st_section->addr;
                        st_ex_section_info.size = st_section->size;
                    }
                    
                    st_section = (struct section*)((unsigned char *)st_section + sizeof(struct section));
                }
            }
        }
        
        lc = (struct load_command *)((unsigned char *)lc+lc->cmdsize);
    }
    
    return st_ex_section_info;
}

//代码节数据 MD5 校验
void check_code(const struct mach_header *mh) {
    
    unsigned char hash[CC_MD5_DIGEST_LENGTH] = {0};
    
    if (mh->magic == MH_MAGIC_64){
        
        uint64_t slide = _dyld_get_image_vmaddr_slide(0);
        
        struct ex_section_info_64 st_ex_section_info_64 = get_text_section_info_64(mh, "__TEXT", "__text");
        CC_MD5((const void *)st_ex_section_info_64.addr+slide, (CC_LONG)st_ex_section_info_64.size, hash);
        
        NSString *strHash = [NSString stringWithFormat:
                             @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                             hash[0], hash[1], hash[2], hash[3],
                             hash[4], hash[5], hash[6], hash[7],
                             hash[8], hash[9], hash[10], hash[11], hash[12],
                             hash[13], hash[14], hash[15]];
        
        NSLog(@"hash %@",strHash);
        
        if (strcmp([strHash UTF8String], text_arm64_hash)) {
            
            NSLog(@"code error!");
            exit(0);
        }
    }
    else if (mh->magic == MH_MAGIC){
        
        uint32_t slide = _dyld_get_image_vmaddr_slide(0);
        
        struct ex_section_info st_ex_section_info =  get_text_section_info(mh, "__TEXT", "__text");
        CC_MD5((const void *)st_ex_section_info.addr+slide, (CC_LONG)st_ex_section_info.size, hash);
        
        NSString *strHash = [NSString stringWithFormat:
                             @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                             hash[0], hash[1], hash[2], hash[3],
                             hash[4], hash[5], hash[6], hash[7],
                             hash[8], hash[9], hash[10], hash[11], hash[12],
                             hash[13], hash[14], hash[15]];
        
        NSLog(@"hash %@",strHash);
        
        if (strcmp([strHash UTF8String], text_armv7_hash)) {
            
            NSLog(@"code error!");
            exit(0);
        }
    }

    return;
}

@implementation antiPiracy

+(void)checkCode{
    
    const struct mach_header *mh = _dyld_get_image_header(0);
    check_code(mh);
}

+(bool)isResign{
    
    //获取配置文件的内容
    NSString *provisionPath = [[NSBundle mainBundle] pathForResource:@"embedded" ofType:@"mobileprovision"];
    NSError *error;
    NSString *provisionString = [NSString stringWithContentsOfFile:provisionPath encoding:NSISOLatin1StringEncoding error:&error];
    
    if (provisionString) {
        
        NSScanner *scanner = [NSScanner scannerWithString:provisionString];
        //从配置文件内容中定位到 plist 起始位置
        NSString *container;
        BOOL result = [scanner scanUpToString:@"<plist" intoString:&container];
        if (result) {
            //定位到 plist 的结束位置
            result = [scanner scanUpToString:@"</plist>" intoString:&container];
            if (result) {
                //格式化字符串，打印 plist
                NSString *strPlist = [NSString stringWithFormat:@"%@</plist>", container];
                NSLog(@"plist %@",strPlist);
                
                //plist 转 dic
                NSData *data = [strPlist dataUsingEncoding:NSUTF8StringEncoding];
                NSError *error;
                NSDictionary *dic = [NSPropertyListSerialization propertyListWithData:data options:0 format:0 error:&error];
                
                if (error) {
                    NSLog(@"error parsing extracted plist — %@", error);
                }
                else{
                    
                    //获取和输出 UUID 和 IdentifierPrefix
                    NSString *strUUID = [dic objectForKey:@"UUID"];
                    NSArray *arrayIdentifierPrefix = [dic objectForKey:@"ApplicationIdentifierPrefix"];
                    NSLog(@"UUID %@ ApplicationIdentifierPrefix %@", strUUID, arrayIdentifierPrefix);
                    
                    //判断配置文件的 UUID
                    if (![strUUID isEqualToString:@"eef5476a-c7a9-44b0-bfe2-39e5e6b4615d"]) {
                        return true;
                    }
                    
                    //判断 IdentifierPrefix
                    NSString *strIdentifierPrefix = [arrayIdentifierPrefix objectAtIndex:0];
                    if (![strIdentifierPrefix isEqualToString:@"QQ4RE63T4U"]) {
                        return true;
                    }
                }
            }
            else {
                
                NSLog(@"unable to find end of plist");
                return true;
            }
        }
        else {
            
            NSLog(@"unable to find beginning of plist");
            return true;
        }
    }
    else{
        
        NSLog(@"your app is not CODE_SIGNED.");
    }
    return false;
}

//检查应用是否从 appstore 下载的，通过读取 LC_ENCRYPTION_INFO 信息判断。
+ (bool) isAppstoreChannel{
    
    //获取当前路径
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *strAppPath = [bundle bundlePath];
    
    //可执行文件名称
    NSString *strExeFile = [bundle objectForInfoDictionaryKey:(NSString*)kCFBundleExecutableKey];
    
    //可执行文件名称全路径
    NSString *strFileName = [NSString stringWithFormat:@"%@/%@",strAppPath,strExeFile];
    
    bool bRet = false;  //返回值
    struct fat_header fh = {0};
    struct fat_arch farch = {0};
    
    FILE *fp = fopen([strFileName UTF8String], "rb");
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
                
                NSLog(@"arm\n");
                
                bRet = get_loadcommand(fp,CPU_TYPE_ARM,ntohl(farch.offset));
                
            }
            else if(ntohl(farch.cputype) == CPU_TYPE_ARM64){
                
                NSLog(@"arm64\n");
                
                bRet = get_loadcommand(fp, CPU_TYPE_ARM64, ntohl(farch.offset));
                
            }
            
            fseek(fp, next_farch_offset, SEEK_SET); //恢复 offset
        }
        
    }
    //0xfeedface 32位
    else if(fh.magic == MH_MAGIC){
        
        NSLog(@"MH_MAGIC");
        
        bRet = get_loadcommand(fp, CPU_TYPE_ARM, 0);
    }
    //0xfeedfacf 64位
    else if(fh.magic == MH_MAGIC_64){
        
        NSLog(@"MH_MAGIC_64");
        
        bRet = get_loadcommand(fp, CPU_TYPE_ARM64, 0);
    }
    
    fclose(fp);
    
    return bRet;
}
@end
