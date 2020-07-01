//
//  LoginCheck.h
//  stringDefine_demo
//
//  Created by exchen on 2018/4/30.
//  Copyright © 2018年 exchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "classDefine.h"
#import "stringDefine.h"
#import "eXProtect.h"

@interface LoginCheck : NSObject

-(NSString*)httpPostUserInfo: (NSString*)username :(NSString*)password;

@end
