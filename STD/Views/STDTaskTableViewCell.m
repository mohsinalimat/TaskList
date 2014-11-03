//
//  STDTaskTableViewCell.m
//  STD
//
//  Created by Lasha Efremidze on 6/29/14.
//  Copyright (c) 2014 More Voltage. All rights reserved.
//

#import "STDTaskTableViewCell.h"

@implementation STDTaskTableViewCell

- (void)awakeFromNib
{
    for (UIButton *button in self.buttons) {
        button.tintColor = [UIColor blackColor];
    }
    
    // add a pan recognizer
    UIGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
    recognizer.delegate = self;
    [self addGestureRecognizer:recognizer];
}

- (IBAction)didTouchOnTasksButton:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(taskTableViewCell:didTouchOnTasksButton:)]) {
        [self.delegate taskTableViewCell:self didTouchOnTasksButton:sender];
    }
}

- (IBAction)didTouchOnNotesButton:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(taskTableViewCell:didTouchOnNotesButton:)]) {
        [self.delegate taskTableViewCell:self didTouchOnNotesButton:sender];
    }
}

- (void)didSwipeRight
{
    if ([self.delegate respondsToSelector:@selector(didSwipeRight:)]) {
        [self.delegate didSwipeRight:self];
    }
}

#pragma mark - UIPanGestureRecognizer

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint translation = [gestureRecognizer translationInView:[self superview]];
        return fabsf(translation.x) > fabsf(translation.y);
    }
    return NO;
}

- (void)panGestureRecognized:(UIPanGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:self];
    CGFloat x = point.x / 8.0f;
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        [self animateStrikethrough:x];
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [recognizer velocityInView:self];
        x += velocity.x / 8.0f;
        [self animateStrikethrough:x];

        if (x > (self.textField.attributedText.length / 2.0f)) {
            [self animateStrikethrough:self.textField.attributedText.length];
            
            [self didSwipeRight];
        } else {
            [self animateStrikethrough:0];
        }
    }
}

- (void)animateStrikethrough:(NSUInteger)length
{
    if (length > self.textField.attributedText.length)
        length = self.textField.attributedText.length;
    
    [UIView animateWithDuration:0.2f animations:^{
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.textField.attributedText];
        [attributedString addAttributes:@{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle)} range:NSMakeRange(0, length)];
        [attributedString addAttributes:@{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleNone)} range:NSMakeRange(length, self.textField.attributedText.length - length)];
        self.textField.attributedText = attributedString;
    }];
}

@end
