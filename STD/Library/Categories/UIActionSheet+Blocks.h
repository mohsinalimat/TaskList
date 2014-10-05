//
//  UIActionSheet+Blocks.h
//  STD
//
//  Created by Lasha Efremidze on 9/23/14.
//  Copyright (c) 2014 Appoop Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^UIActionSheetHandler)(UIActionSheet *actionSheet, NSInteger buttonIndex);

@interface UIActionSheet (Extras)

+ (UIActionSheet *)showActionSheetWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles handler:(UIActionSheetHandler)handler;

+ (UIActionSheet *)actionSheetWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles;

- (void)showWithHandler:(UIActionSheetHandler)handler;

@end
