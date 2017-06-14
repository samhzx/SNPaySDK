//
//  SNWeChatPay.m
//  PayDemo
//
//  Created by sam on 16/8/17.
//  Copyright © 2016年 sam. All rights reserved.
//
#import "SNWeChatPay.h"
#import <CommonCrypto/CommonDigest.h>
#import "SNPayConfig.h"

FOUNDATION_EXTERN WeChatPayConfig *kSNPayWeChatPayConfig;

static NSString *const WeChatPayHttpRequestUrl = @"https://api.mch.weixin.qq.com/pay/unifiedorder";


FOUNDATION_STATIC_INLINE NSString *md5(NSString *str){
    const char *cStr = [str UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (unsigned int)strlen(cStr), digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02X", digest[i]];
    
    return output;
}

FOUNDATION_STATIC_INLINE NSString *timestamp(){
    return [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
}

@interface SNWeChatPay () <NSXMLParserDelegate>
{
	NSString *xmlContentString;
	NSXMLParser *xmlParser;
	NSMutableDictionary *xmlDic;
}

@end

@implementation SNWeChatPay
+ (void)handleOpenUrl:(NSURL *)url {
    if ([url.scheme isEqualToString:kSNPayWeChatPayConfig.WeChat_AppId] && [url.host isEqualToString:@"pay"]) {
        NSString *parString = url.query;
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        for (NSString *string in[parString componentsSeparatedByString:@"&"]) {
            NSString *key = [string componentsSeparatedByString:@"="].firstObject;
            NSString *value = [string componentsSeparatedByString:@"="].lastObject;
            dic[key] = value;
        }
        if ([dic[@"ret"] integerValue] != 0) {
            NSString *errMsg = [NSString stringWithFormat:@"支付失败(%@)", dic[@"ret"]];
            [SNWeChatPay sendNotiWithCode:dic[@"ret"] msg:errMsg];
        }
        else {
            [SNWeChatPay sendNotiWithCode:@"200" msg:@"支付成功"];
        }
    }
}

+ (void)doPayWithMoney:(NSString *)money orderId:(NSString *)orderId title:(NSString *)title desc:(NSString *)desc notiUrl:(NSString *)url {
    if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"支付失败" message:@"请先安装微信客户端" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    if (!kSNPayWeChatPayConfig) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"支付失败" message:@"请先配置微信参数" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    NSMutableDictionary *signDic = [SNWeChatPay buildSignDictionaryWithAppId:kSNPayWeChatPayConfig.WeChat_AppId mchId:kSNPayWeChatPayConfig.WeChat_MchId desc:desc price:money notiUrl:url orderId:orderId];
    NSString *xml = [SNWeChatPay buildRequestXMLWithDic:signDic];

	[[self new] requestPayInfoWithXml:xml];
}

//请求统一支付
- (void)requestPayInfoWithXml:(NSString *)xml {
	NSData *httpRequestBody = [xml dataUsingEncoding:NSUTF8StringEncoding];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:WeChatPayHttpRequestUrl]];
	request.HTTPBody = httpRequestBody;
	request.HTTPMethod = @"POST";
	[request setValue:@"UTF-8" forHTTPHeaderField:@"charset"];
	[request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
	[[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler: ^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
	    [self XMLDataCoverToDic:data];
	    NSLog(@"统一下单返回的结果：%@", xmlDic);
	    //判断返回的许可
	    if ([[xmlDic objectForKey:@"result_code"] isEqualToString:@"SUCCESS"] && [[xmlDic objectForKey:@"return_code"] isEqualToString:@"SUCCESS"]) {
            NSString *nonceStr = [xmlDic objectForKey:@"nonce_str"];
            UInt32 timeStamp = timestamp().intValue;
            NSString *prepayId = [xmlDic objectForKey:@"prepay_id"];
            NSString *partnerId = [xmlDic objectForKey:@"mch_id"];
            NSString *openId = [xmlDic objectForKey:@"appid"];
            NSString *sign = [SNWeChatPay createMD5SignWithPrepayId:prepayId packageId:@"Sign=WXPay" randStr:nonceStr timestamp:timeStamp];
            NSString *PayString = [NSString stringWithFormat:@"weixin://app/%@/pay/?nonceStr=%@&package=Sign%%3DWXPay&partnerId=%@&prepayId=%@&timeStamp=%@&sign=%@&signType=SHA1", openId, nonceStr, partnerId, prepayId, [NSString stringWithFormat:@"%d", timeStamp], sign];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:PayString]];
		}
	    else {
            //支付出错
            [SNWeChatPay sendNotiWithCode:xmlDic[@"err_code"] msg:xmlDic[@"err_code_des"]];
		}
	}] resume];
}

//xml转换成字典
- (void)XMLDataCoverToDic:(NSData *)data {
	xmlDic = [NSMutableDictionary dictionary];
	xmlParser = [[NSXMLParser alloc] initWithData:data];
	[xmlParser setDelegate:self];
	[xmlParser parse];
}

//支付字典转换成xml
+ (NSString *)buildRequestXMLWithDic:(NSMutableDictionary *)dic {
	NSMutableString *reqPars = [NSMutableString string];
	//生成签名
	NSString *sign = [SNWeChatPay createMd5Sign:dic];
	//生成xml的package
	NSArray *keys = [dic allKeys];
	[reqPars appendString:@"<xml>\n"];
	for (NSString *key in keys) {
		[reqPars appendFormat:@"<%@>%@</%@>\n", key, [dic objectForKey:key], key];
	}
	[reqPars appendFormat:@"<sign>%@</sign>\n</xml>", sign];

	return [NSString stringWithString:reqPars];
}

//构建需要支付的字段
+ (NSMutableDictionary *)buildSignDictionaryWithAppId:(NSString *)appId mchId:(NSString *)mchId desc:(NSString *)desc price:(NSString *)price notiUrl:(NSString *)notiUrl orderId:(NSString *)orderId {
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	dic[@"appid"] = appId;
	dic[@"mch_id"] = mchId;
	dic[@"nonce_str"] = timestamp();
	dic[@"body"] = desc;
	dic[@"out_trade_no"] = orderId;
	dic[@"total_fee"] = price;
	dic[@"spbill_create_ip"] = @"8.8.8.8";
	dic[@"notify_url"] = notiUrl;
	dic[@"trade_type"] = @"APP";
	return dic;
}

//读统一前面返回的数据进行md5签名
+ (NSString *)createMD5SignWithPrepayId:(NSString *)prepayId packageId:(NSString *)packageId randStr:(NSString *)randStr timestamp:(UInt32)timestamp {
	NSMutableDictionary *signParams = [NSMutableDictionary dictionary];
	[signParams setObject:kSNPayWeChatPayConfig.WeChat_AppId forKey:@"appid"];
	[signParams setObject:randStr forKey:@"noncestr"];
	[signParams setObject:packageId forKey:@"package"];
	[signParams setObject:kSNPayWeChatPayConfig.WeChat_MchId forKey:@"partnerid"];
	[signParams setObject:prepayId forKey:@"prepayid"];
	[signParams setObject:[NSString stringWithFormat:@"%d", timestamp] forKey:@"timestamp"];
	return [SNWeChatPay createMd5Sign:signParams];
}

//读数据进行排序和MD5签名
+ (NSString *)createMd5Sign:(NSMutableDictionary *)dict {
	NSMutableString *contentString  = [NSMutableString string];
	NSArray *keys = [dict allKeys];
	//按字母顺序排序
	NSArray *sortedArray = [keys sortedArrayUsingComparator: ^NSComparisonResult (id obj1, id obj2) {
	    return [obj1 compare:obj2 options:NSNumericSearch];
	}];
	//拼接字符串
	for (NSString *categoryId in sortedArray) {
		if (![[dict objectForKey:categoryId] isEqualToString:@""]
		    && ![categoryId isEqualToString:@"sign"]
		    && ![categoryId isEqualToString:@"key"]
		    ) {
			[contentString appendFormat:@"%@=%@&", categoryId, [dict objectForKey:categoryId]];
		}
	}
	//添加key字段
	[contentString appendFormat:@"key=%@", kSNPayWeChatPayConfig.WeChat_PatterId];
	//得到MD5 sign签名
	return md5(contentString);
}

#pragma mark - xmlDelegate
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	xmlContentString = string;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if (![xmlContentString isEqualToString:@"\n"] && ![elementName isEqualToString:@"root"]) {
		xmlDic[elementName] = xmlContentString.copy;
	}
}

#pragma mark ---noti
+ (void)sendNotiWithCode:(NSString *)code msg:(NSString *)msg{
    NSDictionary *dic = @{@"code":code,@"type":@"wechat",@"msg":msg?:@""};
    [[NSNotificationCenter defaultCenter] postNotificationName:kSNPayResultNotification object:nil userInfo:dic];
}
@end
