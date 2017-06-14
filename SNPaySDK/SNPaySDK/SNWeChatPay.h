//
//  SNWeChatPay.h
//  PayDemo
//
//  Created by sam on 16/8/17.
//  Copyright © 2016年 sam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNWeChatPay : NSObject
+ (void)handleOpenUrl:(NSURL *)url;
+ (void)doPayWithMoney:(NSString *)money orderId:(NSString *)orderId title:(NSString *)title desc:(NSString *)desc notiUrl:(NSString *)url;
@end
