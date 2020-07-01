//
//  ViewController.m
//  vm_write
//
//  Created by exchen on 2018/4/8.
//  Copyright © 2018年 exchen. All rights reserved.
//

#import "ViewController.h"

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <mach/mach.h>
#include <mach-o/dyld.h>
#include <mach/mach.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    unsigned int data = 0x12345678;
    
    struct mach_header* image_addr = _dyld_get_image_header(0);
    vm_address_t offset = image_addr + (int)0x8000;
    
    kern_return_t err;
    mach_port_t port = mach_task_self();
    err = vm_protect(port, (vm_address_t) offset, sizeof(data), NO,
                     VM_PROT_READ | VM_PROT_WRITE | VM_PROT_EXECUTE);
    if (err != KERN_SUCCESS) {
        NSLog(@"prot error: %s \n", mach_error_string(err));
        return;
    }
    
    vm_write(port, (vm_address_t) offset, (vm_address_t) & data, sizeof(data));
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
