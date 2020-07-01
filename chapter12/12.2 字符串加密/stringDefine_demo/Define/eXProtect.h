//
//  eXProtect.h
//  du
//
//  Created by exchen on 17/7/11.
//  Copyright © 2017年 sm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>

#import "Base64.h"

@interface eXProtect : NSObject

-(NSString *)AESEncryptAndBase64:(NSString *)text :(NSString *)key;
-(NSString *)AESDecrypt:(NSString *)text :(NSString *)key;

-(NSData *)AESEncryptHex:(NSData *)text :(NSString *)key;
-(NSData *)AESDecryptHex:(NSData *)text :(NSString *)key;

-(NSString *)AESEncryptBase64:(NSString *)text :(NSString *)key;  //加密
-(NSString *)AESDecryptBase64:(NSString *)text :(NSString *)key;

+ (NSString *)AESDecrypt:(NSString *)text;
@end
