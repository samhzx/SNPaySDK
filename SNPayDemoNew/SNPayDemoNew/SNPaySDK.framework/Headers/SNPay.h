//
//  SNPay.h
//  PayDemo
//
//  Created by sam on 16/8/16.
//  Copyright © 2016年 sam. All rights reserved.
//
#import "SNPayConfig.h"

@interface SNPay : NSObject

/**
 处理支付完成之后的回调
 */
+ (void)handleOpenUrl:(NSURL *)url;

/**
 调用支付

 @param type 支付类型
 @param money 支付金额（分）
 @param orderId 订单号
 @param title 商品名称
 @param desc 商品详情
 @param url 通知地址
 */
+ (void)doPayWithType:(PayWay)type money:(NSString *)money orderId:(NSString *)orderId title:(NSString *)title desc:(NSString *)desc notiUrl:(NSString *)url;
@end
