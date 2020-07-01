//
//  ViewController.m
//  testDemo
//
//  Created by exchen on 2018/3/20.
//  Copyright © 2018年 exchen. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSLog(@"viewDidLoad");
    
    int num1 = 100;
    int num2 = 200;
    int num3 = num1 + num2;
    
    if (num3 == 300) {
        NSLog(@"300");
    }
    else {
        NSLog(@"流程被修改了吧！哈哈");
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
