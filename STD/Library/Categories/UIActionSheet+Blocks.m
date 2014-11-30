//
//  UIActionSheet+Blocks.m
//  STD
//
//  Created by Lasha Efremidze on 9/23/14.
//  Copyright (c) 2014 More Voltage Inc. All rights reserved.
//

#import "UIActionSheet+Blocks.h"
#import "NSObject+Extras.h"

static char kHandlerAssociatedKey;

@interface UIActionSheet () <UIActionSheetDelegate>

@end

@implementation UIActionSheet (Blocks)

+ (UIActionSheet *)showActionSheetWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles handler:(UIActionSheetHandler)handler;
{
    UIActionSheet *actionSheet = [self actionSheetWithTitle:title cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:otherButtonTitles];
    [actionSheet showWithHandler:handler];
    return actionSheet;
}

+ (UIActionSheet *)actionSheetWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles;
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    for (NSString *buttonTitle in otherButtonTitles)
        [actionSheet addButtonWithTitle:buttonTitle];
    if (destructiveButtonTitle.length) {
        [actionSheet setDestructiveButtonIndex:[actionSheet numberOfButtons]];
        [actionSheet addButtonWithTitle:destructiveButtonTitle];
    }
    if (cancelButtonTitle.length) {
        [actionSheet setCancelButtonIndex:[actionSheet numberOfButtons]];
        [actionSheet addButtonWithTitle:cancelButtonTitle];
    }
    return actionSheet;
}

#pragma mark - Helpers

- (void)showWithHandler:(UIActionSheetHandler)handler;
{
    [self setAssociatedObject:[handler copy] forKey:&kHandlerAssociatedKey];
    
    self.delegate = self;
    [self showInView:[[UIApplication sharedApplication] keyWindow]];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIActionSheetHandler completionHandler = [self associatedObjectForKey:&kHandlerAssociatedKey];
    if (completionHandler)
        completionHandler(actionSheet, buttonIndex);
}

@end
