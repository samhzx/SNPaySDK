//
//  SNPayConfig1.h
//  SNPayDemo
//
//  Created by sam on 16/9/6.
//  Copyright © 2016年 sam. All rights reserved.
//

/**
 *  使用注意：
 *  
 *  1、需要在项目中的info.plist白名单加入alipay、weixin、wechat
 *  2、需要在项目中的info.plist的URL types加入微信的APP_ID和支付宝的AlipayScheme
 *
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//支付成功返回的通知
FOUNDATION_EXTERN NSNotificationName const kSNPayResultNotification;

//支付类型
typedef NS_ENUM (NSUInteger, PayWay) {
	WeChatPay,
	AliPay
};

@class WeChatPayConfig,AliPayConfig;

@interface SNPayConfig : NSObject

//设置支付配置文件
+ (void)setWeChatPayConfig:(WeChatPayConfig *)config;
+ (void)setAliPayConfig:(AliPayConfig *)config;

@end

/**
 *  支付宝配置类
 */
@interface AliPayConfig : NSObject
//scheme
@property (nonatomic, copy)  NSString *AliPay_Scheme;
//appid
@property (nonatomic, copy)  NSString *AliPay_AppId;
//私钥
@property (nonatomic, copy)  NSString *AliPay_PrivateKey;
@end


/**
 *  微信支付配置类
 */
@interface WeChatPayConfig : NSObject
//APPID
@property (nonatomic, copy)  NSString *WeChat_AppId;
//商户号
@property (nonatomic, copy)  NSString *WeChat_MchId;
//商户API密钥
@property (nonatomic, copy)  NSString *WeChat_PatterId;
@end
