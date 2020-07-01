//
//  Base64.h
//  sensorTest
//
//  Created by exchen on 17/7/11.
//  Copyright © 2017年 exchen. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Base64 : NSObject

+(NSString *)encode:(NSData *)data;
+(NSData *)decode:(NSString *)dataString;

@end
