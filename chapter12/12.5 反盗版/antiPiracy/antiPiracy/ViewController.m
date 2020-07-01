//
//  ViewController.m
//  antiPiracy
//
//  Created by boot on 2018/4/23.
//  Copyright © 2018年 exchen. All rights reserved.
//

#import "ViewController.h"
#import "antiPiracy.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
     [antiPiracy checkCode];
    
    //如果被重签名则退出
    bool bRet = [antiPiracy isResign];
    if (bRet) {
        exit(0);
    }
    
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *strIdentifier = infoDic[@"CFBundleIdentifier"];
    //NSString *strAppName = infoDic[@"CFBundleDisplayName"];
    
    //BundleIdentifier 如果被修就退出
    if (![strIdentifier isEqualToString:@"net.exchen.antiPiracy"]) {
        exit(0);
    }
    
    //如果不是从 App Store 下载则退出
    bRet = [antiPiracy isAppstoreChannel];
    if (!bRet) {
        exit(0);
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
