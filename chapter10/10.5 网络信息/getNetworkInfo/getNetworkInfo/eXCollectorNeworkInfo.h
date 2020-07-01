//
//  eXCollectorNeworkInfo.h
//  getNetworkInfo
//
//  Created by exchen on 2018/4/30.
//  Copyright © 2018年 exchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface eXCollectorNeworkInfo : NSObject

-(NSDictionary*)getNetworkStatus;
-(NSDictionary*)getWifiInfo;
-(NSDictionary*)getDNSInfo;
-(NSDictionary*) getProxyInfo;
-(NSDictionary *)getIPAddressInfo:(NSString*)strInterface;

@end
