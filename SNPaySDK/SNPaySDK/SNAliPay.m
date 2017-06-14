//
//  SNAliPay.m
//  PayDemo
//
//  Created by sam on 16/8/17.
//  Copyright © 2016年 sam. All rights reserved.
//

#import "SNAliPay.h"
#import "SNPayConfig.h"
#import "RSAOC.h"

FOUNDATION_EXTERN AliPayConfig *kSNPayAliPayConfig;

@implementation SNAliPay

FOUNDATION_STATIC_INLINE NSString *Encode(NSString *value){
    NSString* encodedValue = value;
    if (value.length > 0) {
        encodedValue = (__bridge_transfer  NSString*)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)value, NULL, (__bridge CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8 );
    }
    return encodedValue;
}

FOUNDATION_STATIC_INLINE NSString *OrderItem(NSString *key,NSString *value,BOOL encode){
    if (key.length > 0 && value.length > 0) {
        if (encode) {
            value = Encode(value);
        }
        return [NSString stringWithFormat:@"%@=%@", key, value];
    }
    return nil;
}

FOUNDATION_STATIC_INLINE NSString *buildBizContent(NSString *title,NSString *orderId,NSString *body,NSString *money){
    NSMutableDictionary *BizContentDict = [NSMutableDictionary new];
    BizContentDict[@"subject"] = title;
    BizContentDict[@"out_trade_no"] = orderId;
    BizContentDict[@"total_amount"] = money;
    BizContentDict[@"seller_id"] = @"";
    BizContentDict[@"product_code"] = @"QUICK_MSECURITY_PAY";
    BizContentDict[@"body"] = body;
    BizContentDict[@"timeout_express"] = @"30m";
    
    NSData* tmpData = [NSJSONSerialization dataWithJSONObject:BizContentDict options:0 error:nil];
    NSString *string = [[NSString alloc] initWithData:tmpData encoding:NSUTF8StringEncoding].mutableCopy;
    return string;
}

FOUNDATION_STATIC_INLINE NSString *buildOrderContent(NSString *timestamp,NSString *bizContent,NSString *notiUrl,BOOL encode){
    NSMutableDictionary *OrderDic = [NSMutableDictionary new];
    OrderDic[@"app_id"] = kSNPayAliPayConfig.AliPay_AppId;
    OrderDic[@"method"] = @"alipay.trade.app.pay";
    OrderDic[@"charset"] = @"utf-8";
    OrderDic[@"timestamp"] = timestamp;
    OrderDic[@"version"] = @"1.0";
    OrderDic[@"biz_content"] = bizContent;
    OrderDic[@"sign_type"] = @"RSA";
    OrderDic[@"notify_url"] = notiUrl;
    
    // NOTE: 排序，得出最终请求字串
    NSArray* sortedKeyArray = [[OrderDic allKeys] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    
    NSMutableArray *tmpArray = [NSMutableArray new];
    for (NSString* key in sortedKeyArray) {
        NSString *orderItem = OrderItem(key,OrderDic[key],encode);
        if (orderItem.length > 0) {
            [tmpArray addObject:orderItem];
        }
    }
    NSString *string = [tmpArray componentsJoinedByString:@"&"].mutableCopy;
    return string;
}

+ (void)handleOpenUrl:(NSURL *)url {
    if ([url.scheme isEqualToString:kSNPayAliPayConfig.AliPay_Scheme] && [url.host isEqualToString:@"safepay"]) {
        NSString *parString = [url.query stringByRemovingPercentEncoding];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[parString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
        if ([dic[@"memo"][@"ResultStatus"] integerValue] != 9000) {
            NSString *errMsg = [NSString stringWithFormat:@"%@(%@)", dic[@"memo"][@"memo"], dic[@"memo"][@"ResultStatus"]];
            [SNAliPay sendNotiWithCode:dic[@"memo"][@"ResultStatus"] msg:errMsg];
        }
        else {
            [SNAliPay sendNotiWithCode:@"200" msg:@"支付成功"];
        }
    }
}

+ (void)doPayWithMoney:(NSString *)money orderId:(NSString *)orderId title:(NSString *)title desc:(NSString *)desc notiUrl:(NSString *)url{
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *timeString = [formatter stringFromDate:[NSDate date]];
    
    NSString *price = [NSString stringWithFormat:@"%.2f", [money doubleValue] / 100.f];
    
    NSString *bizContentString = buildBizContent(title, orderId, desc, price);
    
    NSString *orderInfo = buildOrderContent(timeString, bizContentString, url ,NO);
    NSString *orderInfoEncoded = buildOrderContent(timeString, bizContentString, url ,YES);
    
    NSString *signedString = [RSAOC signString:orderInfo.mutableCopy withPrivatekey:kSNPayAliPayConfig.AliPay_PrivateKey];
    
    NSString *orderString = [NSString stringWithFormat:@"%@&sign=%@",orderInfoEncoded, signedString];
    
    NSDictionary *PayDic = @{@"fromAppUrlScheme":kSNPayAliPayConfig.AliPay_Scheme,
                             @"requestType":@"SafePay",
                             @"dataString":orderString};
    NSData *PayJsonData = [NSJSONSerialization dataWithJSONObject:PayDic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *payJsonString = Encode([[NSString alloc] initWithData:PayJsonData encoding:NSUTF8StringEncoding]);
    
    NSString *PayString = [NSString stringWithFormat:@"alipay://alipayclient/?%@",payJsonString];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:PayString]];
}

#pragma mark ---noti
+ (void)sendNotiWithCode:(NSString *)code msg:(NSString *)msg{
    NSDictionary *dic = @{@"code":code,@"type":@"alipay",@"msg":msg?:@""};
    [[NSNotificationCenter defaultCenter] postNotificationName:kSNPayResultNotification object:nil userInfo:dic];
}
@end
