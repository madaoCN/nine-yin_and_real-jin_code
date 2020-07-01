//
//  antiPiracy.h
//  antiPiracy
//
//  Created by boot on 2018/4/23.
//  Copyright © 2018年 exchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface antiPiracy : NSObject

+ (bool) isAppstoreChannel;
+(bool)isResign;
+(void)checkCode;
@end
