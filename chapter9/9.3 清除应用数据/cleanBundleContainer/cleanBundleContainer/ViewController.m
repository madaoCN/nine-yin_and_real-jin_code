//
//  ViewController.m
//  cleanBundleContainer
//
//  Created by exchen on 2018/5/8.
//  Copyright © 2018年 exchen. All rights reserved.
//

#import "ViewController.h"

#include <spawn.h>
extern char **environ;

#import <stdlib.h>

@interface ViewController ()

@end

@implementation ViewController

-(void)cleanBundleContainer:(NSString*)strBundleDataPath{
    
    //判断目录，只有这两个目录才敢清除，如果是其他的目录，比如 /var/mobile/Documents/ 千万别清，要不然可能得重新激活或者产生其他的问题。
    if ([strBundleDataPath hasPrefix:@"/private/var/mobile/Containers/Data/Application/"] || [strBundleDataPath hasPrefix:@"/var/mobile/Containers/Data/Application"]) {
        
        NSFileManager *fm = [NSFileManager defaultManager];
        
        [fm removeItemAtPath:strBundleDataPath error:nil];
        
        NSString *strDocumentsPath = [strBundleDataPath stringByAppendingPathComponent:@"Documents"];
        NSString *strLibraryPath = [strBundleDataPath stringByAppendingPathComponent:@"Library"];
        
        NSString *strCachesPath = [strLibraryPath stringByAppendingPathComponent:@"Caches"];
        NSString *strPreferencesPath = [strLibraryPath stringByAppendingPathComponent:@"Preferences"];
        
        NSString *strTmpPath = [strBundleDataPath stringByAppendingPathComponent:@"tmp"];
        
        //删除沙盒目录之后，要以 mobile 身份创建相应的目录，不然可能会因为权限问题，再次安装应用不能写入应用沙盒目录
        NSDictionary *strAttrib = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"mobile",NSFileGroupOwnerAccountName,
                                   @"mobile",NSFileOwnerAccountName,
                                   nil];

        [fm createDirectoryAtPath:strBundleDataPath withIntermediateDirectories:NO attributes:strAttrib error:nil];
        [fm createDirectoryAtPath:strDocumentsPath withIntermediateDirectories:NO attributes:strAttrib error:nil];
        [fm createDirectoryAtPath:strLibraryPath withIntermediateDirectories:NO attributes:strAttrib error:nil];
        [fm createDirectoryAtPath:strCachesPath withIntermediateDirectories:NO attributes:strAttrib error:nil];
        [fm createDirectoryAtPath:strPreferencesPath withIntermediateDirectories:NO attributes:strAttrib error:nil];
        [fm createDirectoryAtPath:strTmpPath withIntermediateDirectories:NO attributes:strAttrib error:nil];
    }
}

-(NSString*) getWeChatSandboxPath{
    
    NSMutableArray *arrayAppInfo = [[NSMutableArray alloc] init];
    
    //获取应用程序列表
    Class cls = NSClassFromString(@"LSApplicationWorkspace");
    id s = [(id)cls performSelector:NSSelectorFromString(@"defaultWorkspace")];
    NSArray *array = [s performSelector:NSSelectorFromString(@"allApplications")];
    
    Class LSApplicationProxy_class = NSClassFromString(@"LSApplicationProxy");
    
    for (LSApplicationProxy_class in array){
        
        NSString *strBundleID = [LSApplicationProxy_class performSelector:@selector(bundleIdentifier)];
        
        //获取应用的相关信息
        NSString *strVersion =  [LSApplicationProxy_class performSelector:@selector(bundleVersion)];
        NSString *strShortVersion =  [LSApplicationProxy_class performSelector:@selector(shortVersionString)];
        
        NSURL *strContainerURL = [LSApplicationProxy_class performSelector:@selector(containerURL)];
        NSString *strContainerDataPath = [strContainerURL path];
        
        NSURL *strResourcesDirectoryURL = [LSApplicationProxy_class performSelector:@selector(resourcesDirectoryURL)];
        NSString *strContainerBundlePath = [strResourcesDirectoryURL path];
        
        NSString *strLocalizedName = [LSApplicationProxy_class performSelector:@selector(localizedName)];
        NSString *strBundleExecutable = [LSApplicationProxy_class performSelector:@selector(bundleExecutable)];
        
        //NSLog(@"bundleID：%@ localizedName: %@", strBundleID, strLocalizedName);
        
        if ([strBundleID isEqualToString:@"com.tencent.xin"]) {
            
            return strContainerDataPath;
        }
    }
    
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //获取微信的沙盒目录
    NSString *strContainerDataPath = [self getWeChatSandboxPath];
    if (strContainerDataPath) {
        
        //清除微信的沙盒目录
        [self cleanBundleContainer:strContainerDataPath];
    }
    else{
        NSLog(@"can't find WeChat sandbox path");
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
