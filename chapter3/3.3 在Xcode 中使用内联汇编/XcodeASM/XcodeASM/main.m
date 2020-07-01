//
//  main.m
//  XcodeASM
//
//  Created by exchen on 2018/5/20.
//  Copyright © 2018年 exchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

extern int funcAdd_arm(int a, int b, int c, int d, int e,int f);

int funcAdd(a,b,c,d,e,f)
{
    int g=a+b+c+d+e+f;
    return g;
}

int main(int argc, char * argv[]) {
    
    //int num1 = funcAdd_arm(1,2,3,4,5,6);
    //NSLog(@"%d\n",num1);
    
    int num = funcAdd(1, 2, 3, 4, 5, 6);
    
    int num2 = funcAdd_arm(1,2,3,4,5,6);
    
    NSLog(@"%d\n",num);
    
    int f_address = (int)&funcAdd_arm;
    
    NSLog(@"%x\n",f_address);
    
    num = 0;
    num2 = 0;
    
    asm(
        "mov x0,1\t\n"
        "mov x1,2\t\n"
        "mov x2,3\t\n"
        "mov x3,4\t\n"
        "mov x4,5\t\n"
        "mov x5,6\t\n"
        "bl _funcAdd_arm\t\n"
        "mov %0,x0\t\n"
        "mov %1,#2\t\n"
        :"=r"(num),"=r"(num2)
        :
        :
        );
    
lable1:
    NSLog(@"lable1");
    
    @autoreleasepool {
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
