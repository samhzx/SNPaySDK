//
//  ViewController.h
//  SNPayDemoNew
//
//  Created by sam on 16/9/6.
//  Copyright © 2016年 sam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (nonatomic, copy)  void(^testBlock)(NSUInteger index);

@end

