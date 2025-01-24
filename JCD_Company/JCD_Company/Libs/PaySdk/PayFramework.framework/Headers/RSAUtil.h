//
//  RSAUtil.h
//  Encryption
//
//  Created by 雷传营 on 16/1/10.
//  Copyright © 2016年 leichuanying. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSAUtil : NSObject

// return base64 encoded string
#pragma mark - 使用公钥字符串加密
//使用公钥字符串加密
+ (NSString *)encryptString:(NSString *)str publicKey:(NSString *)pubKey;
// return raw datax

+ (NSData *)encryptData:(NSData *)data publicKey:(NSString *)pubKey;
// return base64 encoded string
// enc with private key NOT working YET!
//+ (NSString *)encryptString:(NSString *)str privateKey:(NSString *)privKey;
// return raw data
//+ (NSData *)encryptData:(NSData *)data privateKey:(NSString *)privKey;

// decrypt base64 encoded string, convert result to string(not base64 encoded)

+ (NSString *)decryptString:(NSString *)str publicKey:(NSString *)pubKey;
+ (NSData *)decryptData:(NSData *)data publicKey:(NSString *)pubKey;

#pragma mark - 使用私钥字符串解密
//使用私钥字符串解密
+ (NSString *)decryptString:(NSString *)str privateKey:(NSString *)privKey;

+ (NSData *)decryptData:(NSData *)data privateKey:(NSString *)privKey;

/**
 *  加密方法
 *
 *  @param str   需要加密的字符串
 *  @param path  '.der'格式的公钥文件路径
 */
+ (NSString *)encryptString:(NSString *)str publicKeyWithContentsOfFile:(NSString *)path;
/**
 *  解密方法
 *
 *  @param str       需要解密的字符串
 *  @param path      '.p12'格式的私钥文件路径
 *  @param password  私钥文件密码
 */
+ (NSString *)decryptString:(NSString *)str privateKeyWithContentsOfFile:(NSString *)path password:(NSString *)password;

//md5加密
+ (NSString *) md5:(NSString *) input;
@end
