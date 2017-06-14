//
//  ViewController.m
//  SNPayDemoNew
//
//  Created by sam on 16/9/6.
//  Copyright © 2016年 sam. All rights reserved.
//

#import "ViewController.h"
#import <SNPaySDK/SNPay.h>


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserverForName:kSNPayResultNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        NSLog(@"%@",note.userInfo);
    }];
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (IBAction)wechatPay:(id)sender {
    [SNPay doPayWithType:0 money:@"1" orderId:@"1233143237" title:@"测试" desc:@"测试" notiUrl:@"http://www.baidu.com"];
    
}
- (IBAction)AliPay:(id)sender {
    [SNPay doPayWithType:1 money:@"1" orderId:@"123786359009" title:@"测试" desc:@"测试" notiUrl:@"http://www.baidu.com"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
