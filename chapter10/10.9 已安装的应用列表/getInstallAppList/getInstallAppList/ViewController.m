//
//  ViewController.m
//  getInstallAppList
//
//  Created by exchen on 2018/4/30.
//  Copyright © 2018年 exchen. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController


-(NSMutableArray*) getInstallAppInfo{
    
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
        
        NSDictionary *dicAppInfo = [NSDictionary dictionaryWithObjectsAndKeys:strBundleID,@"bundleIdentifier",
                                    strLocalizedName,@"localizedName",
                                    strBundleExecutable,@"bundleExecutable",
                                    strContainerDataPath,@"containerData",
                                    strContainerBundlePath,@"containerBundle",
                                    strVersion,@"version",
                                    strShortVersion,@"shortVersion",
                                    nil];
        
        [arrayAppInfo addObject:dicAppInfo];
    }
    
    return arrayAppInfo;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSMutableArray *appList = [self getInstallAppInfo];
    NSLog(@"appList: %@",appList);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
