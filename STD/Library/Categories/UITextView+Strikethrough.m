//
//  UITextView+Strikethrough.m
//  STD
//
//  Created by Lasha Efremidze on 11/27/14.
//  Copyright (c) 2014 More Voltage. All rights reserved.
//

#import "UITextView+Strikethrough.h"
#import "NSObject+Extras.h"

static char kPanGestureRecognizerAssociatedKey;

@interface UITextView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

@end

@implementation UITextView (Strikethrough)

#pragma mark - IBActions

- (void)strikethroughDidChange:(NSUInteger)length
{
    if (length > self.attributedText.length)
        length = self.attributedText.length;
    
    [UIView animateWithDuration:0.2f animations:^{
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
        [attributedString addAttributes:@{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle)} range:NSMakeRange(0, length)];
        [attributedString addAttributes:@{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleNone)} range:NSMakeRange(length, self.attributedText.length - length)];
        self.attributedText = attributedString;
    }];
}

#pragma mark - UIPanGestureRecognizer

- (UIPanGestureRecognizer *)panGestureRecognizer
{
    UIPanGestureRecognizer *recognizer = [self associatedObjectForKey:&kPanGestureRecognizerAssociatedKey];
    if (!recognizer) {
        recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
        recognizer.delegate = self;
        [self addGestureRecognizer:self.panGestureRecognizer];
        
        [self setAssociatedObject:recognizer forKey:&kPanGestureRecognizerAssociatedKey];
    }
    return recognizer;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    if ([self.delegate respondsToSelector:@selector(textViewStrikethroughGestureShouldBegin:)]) {
        return [self.delegate performSelector:@selector(textViewStrikethroughGestureShouldBegin:) withObject:self];
    }
    
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint translation = [gestureRecognizer translationInView:[self superview]];
        return fabsf(translation.x) > fabsf(translation.y);
    }
    return NO;
}

#pragma mark - UIPanGestureRecognizer

- (void)panGestureRecognized:(UIPanGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:self];
    CGFloat x = point.x / 8.0f;
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        [self strikethroughDidChange:x];
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [recognizer velocityInView:self];
        x += velocity.x / 8.0f;
        [self strikethroughDidChange:x];

        if (x > (self.attributedText.length / 2.0f)) {
            if ([self.delegate respondsToSelector:@selector(textViewStrikethroughGestureDidEnd:)]) {
                [self.delegate performSelector:@selector(textViewStrikethroughGestureDidEnd:) withObject:self];
            }
        }
    }
}

@end
