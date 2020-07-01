//
//  ViewController.m
//  systemInfo
//
//  Created by exchen on 2018/5/14.
//  Copyright © 2018年 exchen. All rights reserved.
//

#import "ViewController.h"
#import <sys/utsname.h>
#import <AdSupport/AdSupport.h>

@interface ViewController ()

@end

@implementation ViewController

//获取系统信息
-(NSDictionary* )getSystemInfo{
    
    [NSBundle mainBundle];
    
    NSString *strName = [[UIDevice currentDevice] name]; //获取机器名称
    NSString *strOsver = [[UIDevice currentDevice] systemVersion];  //获取系统版本号
    NSString *strDeviceType = [self getDeviceType];  //获取设备的机型
    NSString *strIDFA = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]; //IDFA
    
    NSNumber *numberBootTime = [self bootTime];  //系统启动时间
    NSNumber *numberCurrenTime = [self getCurrentTimeMillis]; //系统当前时间
    NSNumber *numberScreen = [self getScreenBrightness];      //屏幕亮度
    NSNumber *numberBattery = [self getBatteryInfo];          //电池信息
    
    NSArray *languagesInfo = [self getLanguageInfo];          //系统语言
    
    //将收集到的信息放入 NSDictionary 字典
    NSDictionary *dicSystemInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          strOsver,@"osver",
                                          strName,@"name",
                                          strDeviceType,@"modelTypt",
                                          strIDFA,@"IDFA",
                                          numberBootTime,@"bootTime",
                                          numberCurrenTime,@"curTime",
                                          numberScreen,@"brightness",
                                          numberBattery,@"battery",
                                          languagesInfo,@"languages",
                                          nil];
    return  dicSystemInfo;
}

//获取设备的机型
- (NSString *)getDeviceType {
    
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    
    //对机型进行格式化处理
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    if ([platform isEqualToString:@"iPhone8,4"]) return @"iPhone SE";
    if ([platform isEqualToString:@"iPhone9,1"]) return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,2"]) return @"iPhone 7 Plus";
    if ([platform isEqualToString:@"iPhone10,1"]) return @"iPhone 8";
    if ([platform isEqualToString:@"iPhone10,4"]) return @"iPhone 8";
    if ([platform isEqualToString:@"iPhone10,2"]) return @"iPhone 8 Plus";
    if ([platform isEqualToString:@"iPhone10,5"]) return @"iPhone 8 Plus";
    if ([platform isEqualToString:@"iPhone10,3"]) return @"iPhone X";
    if ([platform isEqualToString:@"iPhone10,6"]) return @"iPhone X";
    if ([platform isEqualToString:@"iPod1,1"]) return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"]) return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"]) return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"]) return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"]) return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPad1,1"]) return @"iPad 1G";
    if ([platform isEqualToString:@"iPad2,1"]) return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,2"]) return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,3"]) return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,4"]) return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,5"]) return @"iPad Mini 1G";
    if ([platform isEqualToString:@"iPad2,6"]) return @"iPad Mini 1G";
    if ([platform isEqualToString:@"iPad2,7"]) return @"iPad Mini 1G";
    if ([platform isEqualToString:@"iPad3,1"]) return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,2"])  return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,3"])  return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,4"])  return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,5"])  return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,6"])  return @"iPad 4";
    if ([platform isEqualToString:@"iPad4,1"])  return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,2"])  return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,3"]) return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,4"]) return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,5"]) return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,6"]) return @"iPad Mini 2G";
    if ([platform isEqualToString:@"i386"]) return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"]) return @"iPhone Simulator";
    return platform;
}

//获取启动时间
-(NSNumber*)bootTime{
    
    NSProcessInfo *pi = [NSProcessInfo processInfo];
    unsigned long ul_time = pi.systemUptime;
    unsigned long ul_bootTime = [[self getCurrentTimeMillis] longValue] - ul_time;
    NSNumber *numberTime = [NSNumber numberWithLong:ul_bootTime];
    return numberTime;
}

//获取系统使用的语言
-(NSArray*)getLanguageInfo{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *languageInfo = [userDefaults objectForKey:@"AppleLanguages"];
    return languageInfo;
}

//获取当前时间
-(NSNumber*)getCurrentTimeMillis{
    
    NSDate *date = [NSDate date];
    NSTimeInterval time_interval = [date timeIntervalSince1970];
    NSNumber *numberTime = [NSNumber numberWithLong:time_interval];
    return numberTime;
}

//获取屏幕亮度
-(NSNumber*)getScreenBrightness{
    
    UIScreen *screen = [UIScreen mainScreen];
    CGFloat floatScreen = [screen brightness];
    NSNumber *numberScreen = [NSNumber numberWithDouble:floatScreen];
    return numberScreen;
}

//获取电池信息
-(NSNumber*)getBatteryInfo{
    
    UIDevice *device = [UIDevice currentDevice];
    [device setBatteryMonitoringEnabled:true];
    float floatBattery = [device batteryLevel];
    NSNumber *numberBattery = [NSNumber numberWithDouble:floatBattery];
    return numberBattery;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSDictionary *dicSystemInfo = [self getSystemInfo];
    NSLog(@"%@",dicSystemInfo);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
