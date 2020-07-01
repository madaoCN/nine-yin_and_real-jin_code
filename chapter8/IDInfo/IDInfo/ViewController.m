//
//  ViewController.m
//  IDInfo
//
//  Created by exchen on 2018/4/13.
//  Copyright © 2018年 exchen. All rights reserved.
//

#import "ViewController.h"
#import "OpenUDID.h"
#import "SimulateIDFA.h"
#import "KeychainItemWrapper.h"
#import<CommonCrypto/CommonDigest.h>

#import <AdSupport/AdSupport.h>
#import <SystemConfiguration/SCNetworkReachability.h>

#import <arpa/inet.h>
#import <ifaddrs.h>

#include "if_arp.h"
#include "if_dl.h"

#if TARGET_IPHONE_SIMULATOR
#import <net/route.h>
#else
#include "route.h"
#endif

#include "if_ether.h"

#import <sys/_types/_in_addr_t.h>
#import <sys/sysctl.h>

#import <err.h>
#import <net/if.h>

#define ROUNDUP(a) ((a) > 0 ? (1 + (((a) - 1) | (sizeof(long) - 1))) : sizeof(long))

typedef enum {
    NetWorkType_None = 0,
    NetWorkType_WIFI,
    NetWorkType_2G,
    NetWorkType_3G,
    NetWorkType_UNKNOWN
} NetWorkType;

@interface ViewController ()

@end

@implementation ViewController

-(NSString*) getMacAddress:(NSString *)strIP
{
    
    NSString *macAddr = nil;
    
    const char *ip = [strIP UTF8String];
    
    if (ip == nil) {
        
        return nil;
    }
    if (strcmp(ip,"") == 0) {
        
        return nil;
    }
    
    in_addr_t addr = inet_addr(ip);
    
    int client = socket(PF_INET,SOCK_DGRAM,IPPROTO_UDP);
    
    struct sockaddr_in remote_addr;
    memset(&remote_addr,0,sizeof(remote_addr));
    remote_addr.sin_port = htons(8000);
    remote_addr.sin_addr.s_addr= addr;
    
    sendto(client, "", sizeof("") , 0 , (struct sockaddr*)&remote_addr, sizeof(struct sockaddr_in));
    
    
    int mib[6];
    size_t needed;  // 需要分区的缓冲区大小
    char *lim, *buf, *next;
    struct rt_msghdr *rtm;  //msghdr 消息头
    struct sockaddr_inarp *sin;  // arp socketaddr
    struct sockaddr_dl *sdl;  //Link-Level Sockaddr
    extern int h_errno;
    
    mib[0] = CTL_NET;
    mib[1] = PF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_INET;
    mib[4] = NET_RT_FLAGS;
    mib[5] = RTF_LLINFO;
    
    // 获取缓冲区的大小
    if (sysctl(mib, 6, NULL, &needed, NULL, 0) < 0)
        err(1, "route-sysctl-estimate");
    
    //分析内存
    if ((buf = malloc(needed)) == NULL)
        err(1, "malloc");
    
    // 查询 ARP 表
    if (sysctl(mib, 6, buf, &needed, NULL, 0) < 0)
        err(1, "actual retrieval of routing table");
    
    lim = buf + needed;
    
    for (next = buf; next < lim; next += rtm->rtm_msglen) {
        
        rtm = (struct rt_msghdr *)next;
        sin = (struct sockaddr_inarp *)(rtm + 1);
        sdl = (struct sockaddr_dl *)(sin + 1);
        
        if (sdl->sdl_alen) {
            
            if (addr == sin->sin_addr.s_addr) {
                
                u_char  *cp = (u_char*)LLADDR(sdl);
                macAddr = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", cp[0], cp[1], cp[2], cp[3], cp[4], cp[5]];
                
            }
            
        }
    }
    
    
    free(buf);
    return macAddr;
}

// 获取默认网关的 IP 地址
- (NSString*)getDefaultGatewayIp
{
    NSString* res = nil;
    
    size_t needed;
    char *buf, *next;
    
    struct rt_msghdr *rtm;
    struct sockaddr * sa;
    struct sockaddr * sa_tab[RTAX_MAX];
    int i = 0;
    
    int mib[] = {CTL_NET, PF_ROUTE, 0, AF_INET, NET_RT_FLAGS, RTF_GATEWAY};
    
    if (sysctl(mib, sizeof(mib) / sizeof(mib[0]), NULL, &needed, NULL, 0) < 0)
    {
        NSLog(@"error in route-sysctl-estimate");
        return nil;
    }
    
    if ((buf = (char*)malloc(needed)) == NULL)
    {
        NSLog(@"error in malloc");
        return nil;
    }
    
    if (sysctl(mib, sizeof(mib) / sizeof(mib[0]), buf, &needed, NULL, 0) < 0)
    {
        NSLog(@"retrieval of routing table");
        return nil;
    }
    
    for (next = buf; next < buf + needed; next += rtm->rtm_msglen)
    {
        rtm = (struct rt_msghdr *)next;
        sa = (struct sockaddr *)(rtm + 1);
        for(i = 0; i < RTAX_MAX; i++)
        {
            if(rtm->rtm_addrs & (1 << i))
            {
                sa_tab[i] = sa;
                sa = (struct sockaddr *)((char *)sa + ROUNDUP(sa->sa_len));
            }
            else
            {
                sa_tab[i] = NULL;
            }
        }
        
        if(((rtm->rtm_addrs & (RTA_DST|RTA_GATEWAY)) == (RTA_DST|RTA_GATEWAY))
           && sa_tab[RTAX_DST]->sa_family == AF_INET
           && sa_tab[RTAX_GATEWAY]->sa_family == AF_INET)
        {
            if(((struct sockaddr_in *)sa_tab[RTAX_DST])->sin_addr.s_addr == 0)
            {
                char ifName[128];
                if_indextoname(rtm->rtm_index,ifName);
                
                if(strcmp("en0",ifName) == 0)
                {
                    struct in_addr temp;
                    temp.s_addr = ((struct sockaddr_in *)(sa_tab[RTAX_GATEWAY]))->sin_addr.s_addr;
                    res = [NSString stringWithUTF8String:inet_ntoa(temp)];
                }
            }
        }
    }
    
    free(buf);
    
    return res;
}

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
        strType = @"WAN";
    }
    else if(retVal == NetWorkType_3G)
    {
        strType = @"WAN";
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

-(NSString *)getIPAddress
{
    NSString *address = @"";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

-(NSDictionary*)getMacInfo{
    
    NSString *strIP = nil;
    NSString *strMacAddress = nil;
    NSString *strDefaultGatewayIp = nil;
    NSString *strGatewayMac = nil;
    
    //判断如果是 iOS 8,9,10 系统并且是 WIFI 环境下就获取 mac 地址信息
    if ([[UIDevice currentDevice].systemVersion floatValue] < 11.0) {
        
        NSDictionary *dicNetworkType = [self getNetworkStatus];
        
        NSString *strNetworkType = dicNetworkType[@"networkType"];
        
        if ([strNetworkType isEqualToString:@"WIFI"]) {
            
            strIP = [self getIPAddress];
            strMacAddress = [self getMacAddress:strIP];
            strDefaultGatewayIp = [self getDefaultGatewayIp];
            strGatewayMac = [self getMacAddress:strDefaultGatewayIp];
        }
    }
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         strMacAddress,@"localMac",
                         strDefaultGatewayIp,@"gatewayIP",
                         strGatewayMac,@"gatewayMac",nil];
    
    return dic;
}

- (NSString *)bundleSeedID {
    NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                           (NSString *)CFBridgingRelease(kSecClassGenericPassword), kSecClass,
                           @"bundleSeedID", kSecAttrAccount,
                           @"", kSecAttrService,
                           (id)kCFBooleanTrue, kSecReturnAttributes,
                           nil];
    CFDictionaryRef result = nil;
    OSStatus status = SecItemCopyMatching((CFDictionaryRef)query, (CFTypeRef *)&result);
    if (status == errSecItemNotFound)
        status = SecItemAdd((CFDictionaryRef)query, (CFTypeRef *)&result);
    if (status != errSecSuccess)
        return nil;
    NSString *accessGroup = [(__bridge NSDictionary *)result objectForKey:(NSString *)CFBridgingRelease(kSecAttrAccessGroup)];
    NSArray *components = [accessGroup componentsSeparatedByString:@"."];
    NSString *bundleSeedID = [[components objectEnumerator] nextObject];
    CFRelease(result);
    return bundleSeedID;
}

- (NSString *) md5:(NSString *) input {
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

-(NSString*)getIDForKeychain{
    
    NSString *strBundleSeedID = [self bundleSeedID];
    
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *strAppname = infoDic[@"CFBundleIdentifier"];
    NSString *strGroup = [NSString stringWithFormat:@"%@.%@",strBundleSeedID,strAppname];
    
    NSLog(@"%@",strGroup);
    
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"super" accessGroup: strGroup];
    NSString *strValue = [keychainItem objectForKey:(NSString *)CFBridgingRelease(kSecValueData)];
    
    if ([strValue isEqualToString:@""] || strValue == nil) {
        
         //生成随机ID
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        strValue = (NSString *)CFBridgingRelease(CFUUIDCreateString(NULL, uuid));
        strValue = [self md5:strValue];  //md5
        
        [keychainItem setObject:strValue forKey:(NSString *)CFBridgingRelease(kSecValueData)];
    }
    
    return strValue;
}

-(NSString*)getIDForPasteboard{
    
    NSString *pasteboardName = @"exchen.net";
    NSString *pasteboardType = @"id";
    NSString *strID;
    
    UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:pasteboardName create:YES];
    pasteboard.persistent = YES;
    
    //从剪贴板里读取ID
    id item = [pasteboard dataForPasteboardType:pasteboardType];
    if (item) {
        
        //如果读出的内容不是空，就说明之前写入了ID
        item = [NSKeyedUnarchiver unarchiveObjectWithData:item];
        if (item != nil) {
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:item];
            strID = [dic objectForKey:pasteboardType];
        }
    }
    else{
        
        //生成随机ID
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        strID = (NSString *)CFBridgingRelease(CFUUIDCreateString(NULL, uuid));
        strID = [self md5:strID];  //md5
        
        //写入剪贴板
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:item];
        [dic setValue:strID forKey:pasteboardType];
        [pasteboard setData:[NSKeyedArchiver archivedDataWithRootObject:dic] forPasteboardType:pasteboardType];
    }
    
    return strID;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *strIDFA = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    NSLog(@"IDFA: %@",strIDFA);
    
    NSString *strIDFV = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSLog(@"IDFV: %@",strIDFV);
    
    NSString *strOpenUDID = [OpenUDID value];
    NSLog(@"openUDID: %@",strOpenUDID);
    
    NSString *simulateIDFA = [SimulateIDFA createSimulateIDFA];
    NSLog(@"simulateIDFA %@",simulateIDFA);
    
    NSDictionary *dicMacInfo = [self getMacInfo];
    
    NSString *localMac = dicMacInfo[@"localMac"];
    NSLog(@"localMac: %@",localMac);
    
    NSString *gatewayIP = dicMacInfo[@"gatewayIP"];
    NSLog(@"gatewayIP: %@",gatewayIP);
    
    NSString *gatewayMac = dicMacInfo[@"gatewayMac"];
    NSLog(@"gatewayMac: %@",gatewayMac);
    
    NSString *keychainID = [self getIDForKeychain];
    NSLog(@"keychainID %@",keychainID);
    
    NSString *pasteboardID = [self getIDForPasteboard];
    NSLog(@"pasteboardID %@",pasteboardID);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
