//
//  UITextView+Strikethrough.h
//  STD
//
//  Created by Lasha Efremidze on 11/27/14.
//  Copyright (c) 2014 More Voltage. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol StrikethroughTextViewDelegate <UITextViewDelegate>

@optional

- (void)textViewStrikethroughGestureDidEnd:(UITextView *)textView;

@end

@interface UITextView (Strikethrough)

@property (weak, nonatomic) id<StrikethroughTextViewDelegate> delegate;

@end
