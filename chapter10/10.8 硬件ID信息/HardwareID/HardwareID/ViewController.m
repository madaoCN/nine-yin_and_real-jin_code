//
//  ViewController.m
//  HardwareID
//
//  Created by exchen on 2018/5/14.
//  Copyright © 2018年 exchen. All rights reserved.
//

#import "ViewController.h"

extern CFTypeRef MGCopyAnswer(CFStringRef);

@interface ViewController ()

@end

@implementation ViewController

- (NSDictionary*)getDeviceInfo{
    
    NSString *strUDID = [self getUDID];
    NSString *strSN = [self getSerialNumber];
    
    NSString *strWifiAddress = [self getWifiAddress];
    NSString *strBlueAddress = [self getBluetoothAddress];
    
    if (strUDID == nil) {
        strUDID = @" ";
    }
    
    if (strSN == nil) {
        strSN = @" ";
    }
    
    if (strWifiAddress == nil) {
        strWifiAddress = @" ";
    }
    
    if (strBlueAddress == nil) {
        strBlueAddress = @" ";
    }
    
    NSMutableDictionary *dictDeviceInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           strUDID,@"UDID",
                                           strSN,@"SerialNumber",
                                           strWifiAddress,@"WifiAddress",
                                           strBlueAddress,@"BlueAddress",
                                           nil];
    return dictDeviceInfo;
}

-(NSString*)getUDID{
    
    NSString *str = @"UniqueDeviceID";
    CFStringRef result = MGCopyAnswer((__bridge CFStringRef)str);
    
    return (__bridge NSString *)(result);
}

-(NSString*)getSerialNumber{
    
    NSString *str = @"SerialNumber";
    CFStringRef result = MGCopyAnswer((__bridge CFStringRef)str);
    
    return (__bridge NSString *)(result);
}

-(NSString*) getIMEI{
    
    NSString *str = @"InternationalMobileEquipmentIdentity";
    CFStringRef result = MGCopyAnswer((__bridge CFStringRef)str);
    
    
    return (__bridge NSString *)(result);
}

-(NSString*) getWifiAddress{
    
    NSString *str = @"WifiAddress";
    CFStringRef result = MGCopyAnswer((__bridge CFStringRef)str);
    
    
    return (__bridge NSString *)(result);
}

-(NSString*) getBluetoothAddress{
    
    NSString *str = @"BluetoothAddress";
    CFStringRef result = MGCopyAnswer((__bridge CFStringRef)str);
    
    return (__bridge NSString *)(result);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSDictionary *dic = [self getDeviceInfo];
    NSLog(@"HardwareID %@",dic);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info" message:dic.description delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
