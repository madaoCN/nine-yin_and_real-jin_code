//
//  ViewController.m
//  stringDefine_demo
//
//  Created by exchen on 2018/4/30.
//  Copyright © 2018年 exchen. All rights reserved.
//

#import "ViewController.h"

#import "stringDefine.h"
#import "eXProtect.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *strUsername = eXString_exchen;
    
    LoginCheck *login = [[LoginCheck alloc] init];
    [login httpPostUserInfo:strUsername :@"123"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
