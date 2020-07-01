//
//  ViewController.m
//  testSandbox
//
//  Created by exchen on 2018/4/8.
//  Copyright © 2018年 exchen. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end


@implementation ViewController

-(void)getPath{
    //获取沙盒根目录路径
    NSString*homeDir = NSHomeDirectory();
    NSLog(@"homedir: %@",homeDir);
    
    // 获取Documents目录路径
    NSString*docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) firstObject];
    NSLog(@"docDir: %@",docDir);
    
    //获取Library的目录路径
    NSString*libDir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask,YES) lastObject];
    NSLog(@"libDir: %@",libDir);
    
    // 获取cache目录路径
    NSString*cachesDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES) firstObject];
    NSLog(@"cachesDir: %@",cachesDir);
    
    // 获取tmp目录路径
    NSString*tmpDir =NSTemporaryDirectory();
    NSLog(@"tmpDir: %@",tmpDir);
    
    //获取应用的自身 xx.app 目录
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *strAppPath = [bundle bundlePath];
    NSLog(@"appDir: %@",strAppPath);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self getPath];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
