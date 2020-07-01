//
//  UIDevice-Swizzing.m
//  Method Swizzing
//
//  Created by exchen on 2018/4/7.
//  Copyright © 2018年 exchen. All rights reserved.
//

#import "UIDevice-Swizzing.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@implementation UIDevice (swizzling)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(systemVersion);
        SEL swizzledSelector = @selector(NewsystemVersion);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}

-(NSString*) NewsystemVersion {
    
    NSLog(@"systemVersion method swizzing");
    //NSString *strVer = @"8.4.1";
    NSString *strVer = [self NewsystemVersion];
    return strVer;
}

@end
