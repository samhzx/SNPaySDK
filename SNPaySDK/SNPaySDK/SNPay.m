//
//  SNPay.m
//  PayDemo
//
//  Created by sam on 16/8/16.
//  Copyright © 2016年 sam. All rights reserved.
//

#import "SNPay.h"
#import "SNWeChatPay.h"
#import "SNAliPay.h"

@implementation SNPay
+ (void)handleOpenUrl:(NSURL *)url {
	[SNAliPay handleOpenUrl:url];
	[SNWeChatPay handleOpenUrl:url];
}

+ (void)doPayWithType:(PayWay)type money:(NSString *)money orderId:(NSString *)orderId title:(NSString *)title desc:(NSString *)desc notiUrl:(NSString *)url{
	if (type == AliPay) {
		[SNAliPay doPayWithMoney:money orderId:orderId title:title desc:desc notiUrl:url];
    }else if (type == WeChatPay) {
		[SNWeChatPay doPayWithMoney:money orderId:orderId title:title desc:desc notiUrl:url];
	}
}
@end
