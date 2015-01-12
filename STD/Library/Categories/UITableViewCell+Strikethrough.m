//
//  UITableViewCell+Strikethrough.m
//  STD
//
//  Created by Lasha Efremidze on 11/27/14.
//  Copyright (c) 2014 More Voltage. All rights reserved.
//

#import "UITableViewCell+Strikethrough.h"
#import "NSObject+Extras.h"

static char kStrikethroughDelegateAssociatedKey;

static char kPanGestureRecognizerAssociatedKey;

@interface UITableViewCell () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

@end

@implementation UITableViewCell (Strikethrough)

@dynamic strikethroughDelegate;

- (void)setStrikethroughDelegate:(id<STDTableViewCellStrikethroughDelegate>)strikethroughDelegate
{
    [self setAssociatedObject:strikethroughDelegate forKey:&kStrikethroughDelegateAssociatedKey];
    
    [self panGestureRecognizer];
}

- (id<STDTableViewCellStrikethroughDelegate>)strikethroughDelegate
{
    return [self associatedObjectForKey:&kStrikethroughDelegateAssociatedKey];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    if ([self.strikethroughDelegate respondsToSelector:@selector(setAttributedText:forTableViewCell:)])
        [self.strikethroughDelegate setAttributedText:attributedText forTableViewCell:self];
}

- (NSAttributedString *)attributedText
{
    if ([self.strikethroughDelegate respondsToSelector:@selector(attributedTextForTableViewCell:)])
        return [self.strikethroughDelegate attributedTextForTableViewCell:self];
    return nil;
}

#pragma mark - IBActions

- (void)strikethroughDidChange:(NSUInteger)length
{
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
        [self addGestureRecognizer:recognizer];
        
        [self setAssociatedObject:recognizer forKey:&kPanGestureRecognizerAssociatedKey];
    }
    return recognizer;
}

#pragma mark - UIGestureRecognizerDelegate

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

#pragma mark - UIPanGestureRecognizer

- (void)panGestureRecognized:(UIPanGestureRecognizer *)recognizer
{
    if ([self.strikethroughDelegate respondsToSelector:@selector(tableViewCellShouldStrikethrough:)]) {
        if (![self.strikethroughDelegate tableViewCellShouldStrikethrough:self]) {
            return;
        }
    }
    
    CGPoint point = [recognizer locationInView:self];
    CGFloat x = point.x / 8.0f;
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        [self strikethroughDidChange:MIN(x, self.attributedText.length)];
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [recognizer velocityInView:self];
        x += velocity.x / 8.0f;

        if (x > (self.attributedText.length / 2.0f)) {
            [self strikethroughDidChange:self.attributedText.length];
            
            if ([self.strikethroughDelegate respondsToSelector:@selector(strikethroughGestureDidEnd:)]) {
                [self.strikethroughDelegate performSelector:@selector(strikethroughGestureDidEnd:) withObject:self];
            }
        } else {
            [self strikethroughDidChange:0];
        }
    }
}

@end
