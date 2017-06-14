//
//  SNPayConfig1.m
//  SNPayDemo
//
//  Created by sam on 16/9/6.
//  Copyright © 2016年 sam. All rights reserved.
//

#import "SNPayConfig.h"


//支付成功返回的通知
NSString *const kSNPayResultNotification = @"kSNPayResultNotification";

AliPayConfig *kSNPayAliPayConfig = nil;
WeChatPayConfig *kSNPayWeChatPayConfig = nil;

@implementation SNPayConfig
+ (void)setAliPayConfig:(AliPayConfig *)config {
    kSNPayAliPayConfig = config;
}

+ (void)setWeChatPayConfig:(WeChatPayConfig *)config {
    kSNPayWeChatPayConfig = config;
}
@end

@implementation WeChatPayConfig
@end
@implementation AliPayConfig
@end
