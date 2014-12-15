//
//  UIScrollView+Blocks.h
//  STD
//
//  Created by Lasha Efremidze on 11/9/14.
//  Copyright (c) 2014 More Voltage Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^UIScrollViewDidEndScrollingAnimationBlock)(UIScrollView *scrollView);

@interface UIScrollView (Blocks)

- (void)scrollViewDidEndScrollingAnimationBlock:(UIScrollViewDidEndScrollingAnimationBlock)block;

@end
