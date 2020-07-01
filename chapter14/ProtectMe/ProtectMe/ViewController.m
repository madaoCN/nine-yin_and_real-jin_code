//
//  ViewController.m
//  ProtectMe
//
//  Created by exchen on 2018/5/23.
//  Copyright © 2018年 exchen. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSLog(@"Protect Me!");
    printf("Protect Me!");
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"Protect Me" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil, nil];
    [alert show];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
