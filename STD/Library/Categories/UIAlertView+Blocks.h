//
//  UIAlertView+Blocks.h
//  STD
//
//  Created by Lasha Efremidze on 9/23/14.
//  Copyright (c) 2014 More Voltage Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^UIAlertViewHandler)(UIAlertView *alertView, NSInteger buttonIndex);

@interface UIAlertView (Extras)

+ (UIAlertView *)showAlertViewWithMessage:(NSString *)message;

+ (UIAlertView *)showAlertViewWithMessage:(NSString *)message title:(NSString *)title;

+ (UIAlertView *)showAlertViewWithMessage:(NSString *)message title:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles handler:(UIAlertViewHandler)handler;

+ (UIAlertView *)alertViewWithMessage:(NSString *)message title:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles;

- (void)showWithHandler:(UIAlertViewHandler)handler;

@end
