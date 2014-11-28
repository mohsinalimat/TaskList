//
//  UITextField+Strikethrough.h
//  STD
//
//  Created by Lasha Efremidze on 11/27/14.
//  Copyright (c) 2014 More Voltage. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol StrikethroughTextFieldDelegate <UITextFieldDelegate>

@optional

- (BOOL)textFieldStrikethroughGestureShouldBegin:(UITextField *)textField;
- (void)textFieldStrikethroughGestureDidEnd:(UITextField *)textField;

@end

@interface UITextField (Strikethrough)

@property (weak, nonatomic) id<StrikethroughTextFieldDelegate> delegate;

@end
