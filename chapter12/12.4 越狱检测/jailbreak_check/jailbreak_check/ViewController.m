//
//  ViewController.m
//  jailbreak_check
//
//  Created by boot on 2018/4/10.
//  Copyright © 2018年 exchen. All rights reserved.
//

#import "ViewController.h"
#import <sys/stat.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>

@interface ViewController ()

@end

bool isJailByCydiaAppExist(){
    
    NSLog(@"isJailByCydiaAppExist");
    NSFileManager *fm = [NSFileManager defaultManager];
    
    bool bRet = [fm fileExistsAtPath: @"/Applications/Cydia.app"];
    if (!bRet) {
        return false;
    }
    return true;
}

bool isJailByAptExist(){
    
    NSLog(@"isJailByAptExist");
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL bRet = [fm fileExistsAtPath: @"/private/var/lib/apt"];
    if (!bRet) {
        return false;
    }
    return true;
}

void isJailByCydiaAppExist_stat()
{
    NSLog(@"isJailByCydiaAppExist_stat");
    struct stat stat_info;
    if (0 == stat("/Applications/Cydia.app", &stat_info)) {
        NSLog(@"jailbreak (isJailByCydiaAppExist_stat)");
    }
}

void isJailByCheckDylibs(void)
{
    NSLog(@"isJailByCheckDylibs");
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0 ; i < count; ++i) {
        
        const char *name = _dyld_get_image_name(i);
        if (strstr(name, "MobileSubstrate.dylib")) {
           NSLog(@"jailbreak (isJailByCheckDylibs)");
        }
    }
}

void isJailByEnv(void)
{
    NSLog(@"isJailByEnv");
    char *env = getenv("DYLD_INSERT_LIBRARIES");
    if (env) {
        NSLog(@"jailbreak (isJailByEnv)");
    }
}

void isJailByInject(void)
{
    NSLog(@"isJailByInject");
    int ret ;
    Dl_info dylib_info;
    int (*func_stat)(const char *, struct stat *) = stat;
    if ((ret = dladdr(func_stat, &dylib_info))) {
        
        const char *name = dylib_info.dli_fname;
        
        //如果 stat 函数不是出自 libsystem_kernel.dylib，肯定是被劫持了，说明是越狱的
        if (!strstr(name, "libsystem_kernel.dylib")) {
            NSLog(@"jailbreak (isJailByInject)");
        }
    }
}

void isJailByReadFile(){
    
    NSLog(@"isJailByReadFile");
    NSString *strPath = @"/Applications/Cydia.app/Cydia";
    NSData *data = [[NSData alloc] initWithContentsOfFile:strPath];
    
    if (data != nil) {
        NSLog(@"jailbreak (isJailByReadFile)");
    }
}

void checkJailbreak(void){
    
    NSLog(@"checkJailbreak");
    if(isJailByCydiaAppExist() == true){
        NSLog(@"jailbreak (isJailByCydiaAppExist)");
    }
    
    if (isJailByAptExist() == true) {
         NSLog(@"jailbreak (isJailByAptExist)");
    }
    
    isJailByReadFile();
    isJailByCydiaAppExist_stat();
    isJailByCheckDylibs();
    isJailByEnv();
    isJailByInject();
}

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    checkJailbreak();
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
