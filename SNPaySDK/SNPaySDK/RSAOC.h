//
//  RSA.h
//  SNPayDemoNew
//
//  Created by sam on 16/9/6.
//  Copyright © 2016年 sam. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kChosenCipherBlockSize kCCBlockSizeAES128
#define kChosenCipherKeySize kCCKeySizeAES128
#define kChosenDigestLength CC_SHA1_DIGEST_LENGTH


// Global constants for padding schemes.
#define kPKCS111


#define kTypeOfSigPadding kSecPaddingPKCS1SHA1


@interface RSAOC : NSObject


// return base64 encoded string
+ (NSString *)encryptString:(NSString *)str publicKey:(NSString *)pubKey;
// return raw data
+ (NSData *)encryptData:(NSData *)data publicKey:(NSString *)pubKey;
// return base64 encoded string
// enc with private key NOT working YET!
//+ (NSString *)encryptString:(NSString *)str privateKey:(NSString *)privKey;
// return raw data
//+ (NSData *)encryptData:(NSData *)data privateKey:(NSString *)privKey;


// decrypt base64 encoded string, convert result to string(not base64 encoded)
+ (NSString *)decryptString:(NSString *)str publicKey:(NSString *)pubKey;
+ (NSData *)decryptData:(NSData *)data publicKey:(NSString *)pubKey;
+ (NSString *)decryptString:(NSString *)str privateKey:(NSString *)privKey;
+ (NSData *)decryptData:(NSData *)data privateKey:(NSString *)privKey;
+ (NSString *)signString:(NSString *)string withPrivatekey:(NSString *)privKey;
+ (NSString *)signString:(NSString *)string byP12File:(NSString *)fileName password:(NSString *)pwd_string;
@end
