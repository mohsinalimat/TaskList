//
//  UITableViewCell+Strikethrough.m
//  STD
//
//  Created by Lasha Efremidze on 11/9/14.
//  Copyright (c) 2014 More Voltage. All rights reserved.
//

#import "UITableViewCell+Strikethrough.h"
#import "NSObject+Extras.h"

static char kPanGestureRecognizerAssociatedKey;
static char kDelegateAssociatedKey;

@interface UITableViewCell () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

@end

@implementation UITableViewCell (Strikethrough)

@dynamic strikethroughDelegate;

- (void)setStrikethroughEnabled:(BOOL)strikethroughEnabled
{
    BOOL isEnabled = [self isStrikethroughEnabled];
    if (isEnabled != strikethroughEnabled) {
        if (strikethroughEnabled) {
            [self addGestureRecognizer:self.panGestureRecognizer];
        } else {
            [self removeGestureRecognizer:self.panGestureRecognizer];
        }
    }
}

- (BOOL)isStrikethroughEnabled
{
    return [self.gestureRecognizers containsObject:self.panGestureRecognizer];
}

- (void)setStrikethroughDelegate:(id<StrikethroughTableViewCellDelegate>)strikethroughDelegate
{
    [self setAssociatedObject:strikethroughDelegate forKey:&kDelegateAssociatedKey];
}

- (id<StrikethroughTableViewCellDelegate>)strikethroughDelegate
{
    return [self associatedObjectForKey:&kDelegateAssociatedKey];
}

#pragma mark - UIPanGestureRecognizer

- (UIPanGestureRecognizer *)panGestureRecognizer
{
    UIPanGestureRecognizer *recognizer = [self associatedObjectForKey:&kPanGestureRecognizerAssociatedKey];
    if (!recognizer) {
        recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
        recognizer.delegate = self;
        [self setAssociatedObject:recognizer forKey:&kPanGestureRecognizerAssociatedKey];
    }
    return recognizer;
}

#pragma mark - IBActions

- (void)strikethroughDidChange:(NSUInteger)length
{
    if ([self.strikethroughDelegate respondsToSelector:@selector(tableViewCell:strikethroughDidChange:)]) {
        [self.strikethroughDelegate tableViewCell:self strikethroughDidChange:length];
    }
}

- (void)strikethroughDidEndPanning:(NSUInteger)length
{
    if ([self.strikethroughDelegate respondsToSelector:@selector(tableViewCell:strikethroughDidEndPanning:)]) {
        [self.strikethroughDelegate tableViewCell:self strikethroughDidEndPanning:length];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint translation = [gestureRecognizer translationInView:[self superview]];
        return fabsf(translation.x) > fabsf(translation.y);
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
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
        [self strikethroughDidEndPanning:x];
    }
}

@end
