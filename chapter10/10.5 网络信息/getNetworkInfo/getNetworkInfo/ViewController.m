//
//  ViewController.m
//  getNetworkInfo
//
//  Created by exchen on 2018/4/30.
//  Copyright © 2018年 exchen. All rights reserved.
//

#import "ViewController.h"
#import "eXCollectorNeworkInfo.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    eXCollectorNeworkInfo *networkInfo = [[eXCollectorNeworkInfo alloc] init];
    NSDictionary *dic_en0 = [networkInfo getIPAddressInfo:@"en0"];
    NSLog(@"en0: %@",dic_en0);
    
    NSDictionary *dic_pdp_ip0 = [networkInfo getIPAddressInfo:@"pdp_ip0"];
    NSLog(@"cell: %@",dic_pdp_ip0);
    
    NSDictionary *dic_ppp0 = [networkInfo getIPAddressInfo:@"ppp0"];
    NSLog(@"vpn: %@",dic_ppp0);
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
