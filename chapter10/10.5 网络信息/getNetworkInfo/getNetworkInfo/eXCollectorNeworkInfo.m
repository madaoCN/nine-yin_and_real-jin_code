//
//  eXCollectorNeworkInfo.m
//  getNetworkInfo
//
//  Created by exchen on 2018/4/30.
//  Copyright © 2018年 exchen. All rights reserved.
//

#import "eXCollectorNeworkInfo.h"


//#import <SystemConfiguration/CaptiveNetwork.h>
//#import <NetworkExtension/NetworkExtension.h>

//#import <CoreTelephony/CTTelephonyNetworkInfo.h>
//#import <CoreTelephony/CTCarrier.h>


#include <arpa/inet.h>
#include <ifaddrs.h>
//#include <dns.h>
//#include <resolv.h>

#import <sys/socket.h>
//#import <SystemConfiguration/SystemConfiguration.h>

typedef enum {
    NetWorkType_None = 0,
    NetWorkType_WIFI,
    NetWorkType_2G,
    NetWorkType_3G,
    NetWorkType_UNKNOWN
} NetWorkType;

@implementation eXCollectorNeworkInfo

/*
-(NSDictionary*)getNetworkStatus{
    
    NetWorkType retVal = NetWorkType_None;
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress); //创建测试连接的引用：
    SCNetworkReachabilityFlags flags;
    SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
    {
        retVal = NetWorkType_None;
    }
    else if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
    {
        retVal = NetWorkType_WIFI;
    }
    else if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
              (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
    {
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
        {
            retVal = NetWorkType_WIFI;
        }
    }
    else if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
    {
        if((flags & kSCNetworkReachabilityFlagsReachable) == kSCNetworkReachabilityFlagsReachable) {
            if ((flags & kSCNetworkReachabilityFlagsTransientConnection) == kSCNetworkReachabilityFlagsTransientConnection) {
                retVal = NetWorkType_3G;
                if((flags & kSCNetworkReachabilityFlagsConnectionRequired) == kSCNetworkReachabilityFlagsConnectionRequired) {
                    retVal = NetWorkType_2G;
                }
            }
        }
    }
    
    NSString *strType;
    if (retVal == NetWorkType_None) {
        strType = @"None";
    }
    else if(retVal == NetWorkType_WIFI){
        strType = @"WIFI";
    }
    else if(retVal == NetWorkType_2G)
    {
        strType = @"Carrier";  //运营商
    }
    else if(retVal == NetWorkType_3G)
    {
        strType = @"Carrier";
    }
    else
    {
        strType = @"UNKNOWN";
    }
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         strType,@"networkType", nil];
    
    CFRelease(defaultRouteReachability);
    return dic;
}
*/
/*
-(NSDictionary*)getWifiInfo{
    
    NSArray *ifs = CFBridgingRelease(CNCopySupportedInterfaces());
    
    id info = nil;
    for(NSString *ifname in ifs){
        
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifname);
        if(info && [info count]){
            break;
        }
        
    }
    
    NSString *strSsid =  info[@"SSID"];
    NSString *strBssid = info[@"BSSID"];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         strSsid,@"ssid",
                         strBssid,@"bssid",nil];
    
    NSMutableDictionary *dicWifi = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    dic,@"wifiInfo"
                                    ,nil];
    return dicWifi;
}

-(NSDictionary*)getDNSInfo{
    
    // dont forget to link libresolv.lib
    NSMutableArray *dnsList = [[NSMutableArray alloc] init];
    
    res_state res = malloc(sizeof(struct __res_state));
    
    int result = res_ninit(res);
    
    if ( result == 0 )
    {
        for ( int i = 0; i < res->nscount; i++ )
        {
            NSString *s = [NSString stringWithUTF8String :  inet_ntoa(res->nsaddr_list[i].sin_addr)];
            [dnsList addObject:s];
        }
        
    }
    else
    {
        NSLog(@" res_init result != 0");
        
    }
    
    res_nclose(res);
    res_ndestroy(res);
    free(res);
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         dnsList,@"dns", nil];
    return dic;
}

/*
//获取运营商信息
-(NSDictionary*)getCarrierInfo{
    
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
    
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
    
    //[netInfo release];
    
    NSString *strCarrier;
    if (carrier == nil) {
        strCarrier = @"WiFi";
    }
    else {
        strCarrier = [carrier carrierName];
    }
    
    NSString *strCountryIso = [carrier isoCountryCode];
    NSString *strMobileCountryCode = [carrier mobileCountryCode];
    NSString *strMobileNetworkCode = [carrier mobileNetworkCode];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         strCarrier, @"carrier",
                         strCountryIso,@"countryIso",
                         strMobileCountryCode,@"mcc",
                         strMobileNetworkCode,@"mnc",nil];
    
    NSDictionary *dicCarrier = [NSDictionary dictionaryWithObjectsAndKeys:
                                dic, @"carrier",nil];
    return dicCarrier;
}

//获取代理信息
-(NSDictionary*) getProxyInfo
{
    NSDictionary *proxySettings = (__bridge NSDictionary *)(CFNetworkCopySystemProxySettings());
    NSArray *proxies = (__bridge NSArray *)(CFNetworkCopyProxiesForURL((__bridge CFURLRef _Nonnull)([NSURL URLWithString:@"http://www_baidu_com"]), (__bridge CFDictionaryRef _Nonnull)(proxySettings)));
    //NSLog(@"\n%@",proxies);
    
    NSDictionary *settings = [proxies objectAtIndex:0];
    
    NSDictionary *dicProxyInfo = [NSDictionary dictionaryWithObjectsAndKeys:settings,@"proxyInfo", nil];
    
    CFRelease((__bridge CFTypeRef)(proxies));
    
    return dicProxyInfo;
}
*/
//
- (NSDictionary *)getIPAddressInfo:(NSString*)strInterface
{
    NSMutableDictionary *dicIPInfo = [[NSMutableDictionary alloc] init];
    NSDictionary *dicConnectList;
    
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0){
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL){
            if(temp_addr->ifa_addr->sa_family == AF_INET){
                // Check if interface is en0 which is the wifi connection on the iPhone
                
                char *interface_name = temp_addr->ifa_name;
                if([[NSString stringWithUTF8String:interface_name] isEqualToString:strInterface]){
                    //接口名称
                    NSString *strInterfaceName = [NSString stringWithUTF8String:interface_name];
                    
                    //ip地址
                    char *ip = inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr);
                    NSString *strIP = [NSString stringWithUTF8String:ip];
                    
                    //子网掩码
                    char *submask = inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr);
                    NSString *strSubmask = [NSString stringWithUTF8String:submask];
                    
                    //广播地址
                    char *dstaddr = inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_dstaddr)->sin_addr);
                    NSString *strDstaddr = [NSString stringWithUTF8String:dstaddr];
                    
                    dicIPInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 strIP,@"ip",
                                 strSubmask,@"submask",
                                 strDstaddr,@"broadcast",nil];
                    
                    dicConnectList = [NSDictionary dictionaryWithObjectsAndKeys:
                                      dicIPInfo,strInterfaceName,nil];
                    
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return dicConnectList;
}


@end
