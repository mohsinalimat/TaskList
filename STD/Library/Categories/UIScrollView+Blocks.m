//
//  UIScrollView+Blocks.m
//  STD
//
//  Created by Lasha Efremidze on 11/9/14.
//  Copyright (c) 2014 Appoop Inc. All rights reserved.
//

#import "UIScrollView+Blocks.h"
#import "NSObject+Extras.h"

static char kDidEndScrollingAnimationBlockAssociatedKey;

@interface UIScrollView () <UIScrollViewDelegate>

@end

@implementation UIScrollView (Blocks)

- (void)scrollViewDidEndScrollingAnimationBlock:(UIScrollViewDidEndScrollingAnimationBlock)block
{
    [self setAssociatedObject:[block copy] forKey:&kDidEndScrollingAnimationBlockAssociatedKey];
    
    self.delegate = self;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    UIScrollViewDidEndScrollingAnimationBlock completionHandler = [self associatedObjectForKey:&kDidEndScrollingAnimationBlockAssociatedKey];
    if (completionHandler)
        completionHandler(scrollView);
}

@end
