//
//  UIAlertView+Blocks.m
//  STD
//
//  Created by Lasha Efremidze on 9/23/14.
//  Copyright (c) 2014 More Voltage Inc. All rights reserved.
//

#import "UIAlertView+Blocks.h"
#import "NSObject+Extras.h"

static char kHandlerAssociatedKey;

@interface UIAlertView () <UIAlertViewDelegate>

@end

@implementation UIAlertView (Blocks)

+ (UIAlertView *)showAlertViewWithMessage:(NSString *)message;
{
    return [self showAlertViewWithMessage:message title:nil];
}

+ (UIAlertView *)showAlertViewWithMessage:(NSString *)message title:(NSString *)title;
{
    return [self showAlertViewWithMessage:message title:title cancelButtonTitle:@"OK" otherButtonTitles:nil handler:nil];
}

+ (UIAlertView *)showAlertViewWithMessage:(NSString *)message title:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles handler:(UIAlertViewHandler)handler;
{
    UIAlertView *alertView = [self alertViewWithMessage:message title:title cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles];
    [alertView showWithHandler:handler];
    return alertView;
}

+ (UIAlertView *)alertViewWithMessage:(NSString *)message title:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles;
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    for (NSString *buttonTitle in otherButtonTitles)
        [alertView addButtonWithTitle:buttonTitle];
    return alertView;
}

#pragma mark - Helpers

- (void)showWithHandler:(UIAlertViewHandler)handler;
{
    [self setAssociatedObject:[handler copy] forKey:&kHandlerAssociatedKey];
    
    self.delegate = self;
    [self show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIAlertViewHandler completionHandler = [self associatedObjectForKey:&kHandlerAssociatedKey];
    if (completionHandler)
        completionHandler(alertView, buttonIndex);
}

@end
