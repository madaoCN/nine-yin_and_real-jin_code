//
//  ViewController.m
//  antidebugging
//
//  Created by boot on 2018/4/21.
//  Copyright © 2018年 exchen. All rights reserved.
//

#import "ViewController.h"

// For debugger_ptrace
#import <dlfcn.h>
#import <sys/types.h>

// For debugger_sysctl
#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/sysctl.h>
#include <stdlib.h>

// For ioctl
#include <termios.h>
#include <sys/ioctl.h>

// For task_get_exception_ports
#include <mach/task.h>
#include <mach/mach_init.h>

typedef int (*ptrace_ptr_t)(int _request, pid_t _pid, caddr_t _addr, int _data);

#if !defined(PT_DENY_ATTACH)
#define PT_DENY_ATTACH 31
#endif  // !defined(PT_DENY_ATTACH)

void antidebugging_ptrace()
{
    void* handle = dlopen(0, RTLD_GLOBAL | RTLD_NOW);
    ptrace_ptr_t ptrace_ptr = dlsym(handle, "ptrace");
    ptrace_ptr(PT_DENY_ATTACH, 0, 0, 0);
    dlclose(handle);
}

void antidebugging_syscall(){
    
    syscall(26, 31, 0, 0);
}

bool antidebugging_sysctl(void)
{
    int mib[4];
    struct kinfo_proc info;
    size_t info_size = sizeof(info);
    
    info.kp_proc.p_flag = 0;
    
    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC;
    mib[2] = KERN_PROC_PID;
    mib[3] = getpid();
    
    if (sysctl(mib, 4, &info, &info_size, NULL, 0) == -1)
    {
        perror("perror sysctl");
        exit(-1);
    }
    
    bool bRet = ((info.kp_proc.p_flag & P_TRACED) != 0);
    if (bRet) {
        NSLog(@"antidebugging_sysctl");
        exit(0);
    }
    return bRet;
}

void antidebugging_get_exception_ports()
{
    struct ios_execp_info
    {
        exception_mask_t masks[EXC_TYPES_COUNT];
        mach_port_t ports[EXC_TYPES_COUNT];
        exception_behavior_t behaviors[EXC_TYPES_COUNT];
        thread_state_flavor_t flavors[EXC_TYPES_COUNT];
        mach_msg_type_number_t count;
    };
    struct ios_execp_info *info = malloc(sizeof(struct ios_execp_info));
    kern_return_t kr = task_get_exception_ports(mach_task_self(), EXC_MASK_ALL, info->masks, &info->count, info->ports, info->behaviors, info->flavors);
    
    for (int i = 0; i < info->count; i++)
    {
        if (info->ports[i] !=0 || info->flavors[i] == THREAD_STATE_NONE)
        {
            NSLog(@"antidebugging_get_exception_ports");
            exit(0);
        } else {
        }
    }
}

void antidebugging_isatty(){
    
    if (isatty(1)) {
        NSLog(@"antidebugging_isatty");
        exit(0);
    }
}

void antidebugging_ioctl(){
    
    if (!ioctl(1, TIOCGWINSZ)) {
        NSLog(@"antidebugging_ioctl");
        exit(0);
    }
}


void antidebugging_svc(){
    
#ifdef __arm__
    asm volatile (
                  "mov r0, #31\n"
                  "mov r1, #0\n"
                  "mov r2, #0\n"
                  "mov r3, #0\n"
                  "mov r12, #26\n"
                  "svc #0x80\n"
                  );
#endif
#ifdef __arm64__
    asm volatile (
                  "mov x0, #26\n"
                  "mov x1, #31\n"
                  "mov x2, #0\n"
                  "mov x3, #0\n"
                  "mov x16, #0\n"
                  "svc #128\n"
                  );
#endif
}


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    antidebugging_ptrace();
    NSLog(@"Bypass antidebugging_ptrace");
    
    antidebugging_syscall();
    NSLog(@"Bypass antidebugging_syscall");
    
    antidebugging_sysctl();
    NSLog(@"Bypass antidebugging_sysctl");
    
    antidebugging_get_exception_ports();
    NSLog(@"bypass antidebugging_get_exception_ports");
    
    antidebugging_isatty();
    NSLog(@"Bypass antidebugging_isatty");
    
    antidebugging_ioctl();
    NSLog(@"Bypass antidebugging_ioctl");
    
    antidebugging_svc();
    NSLog(@"Bypass antidebugging_svc");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
