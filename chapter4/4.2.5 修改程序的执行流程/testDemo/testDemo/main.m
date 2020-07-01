//
//  main.m
//  testDemo
//
//  Created by exchen on 2018/3/20.
//  Copyright © 2018年 exchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    
    NSLog(@"testDemo");
    
    int i = 2018;
    NSString *str = [NSString stringWithFormat:@"exchen %d", i];
    NSLog(@"%@",str);
    
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
