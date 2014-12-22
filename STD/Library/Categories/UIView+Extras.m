//
//  UIView+Extras.m
//  STD
//
//  Created by Lasha Efremidze on 12/14/14.
//  Copyright (c) 2014 More Voltage. All rights reserved.
//

#import "UIView+Extras.h"

@implementation UIView (Extras)

- (UIView *)superviewWithKindOfClass:(Class)aClass;
{
    if ([self.superview isKindOfClass:aClass])
        return self.superview;
    return [self.superview superviewWithKindOfClass:aClass];
}

@end
