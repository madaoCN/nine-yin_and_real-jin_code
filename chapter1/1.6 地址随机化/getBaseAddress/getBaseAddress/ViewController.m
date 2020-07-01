//
//  ViewController.m
//  getBaseAddress
//
//  Created by exchen on 2018/4/8.
//  Copyright © 2018年 exchen. All rights reserved.
//

#import "ViewController.h"
#include <mach-o/dyld.h>
#include <mach/mach.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //获取第一个模块的基址
    intptr_t slide_addr = _dyld_get_image_vmaddr_slide(0);
    struct mach_header *mh_addr = _dyld_get_image_header(0);
    
    printf("slide_addr: 0x%x\n", slide_addr);
    printf("mh_addr: 0x%x\n",mh_addr);
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
