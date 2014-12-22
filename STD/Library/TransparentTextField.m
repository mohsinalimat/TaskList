//
//  TransparentTextField.m
//  STD
//
//  Created by Lasha Efremidze on 12/21/14.
//  Copyright (c) 2014 More Voltage. All rights reserved.
//

#import "TransparentTextField.h"

@implementation TransparentTextField

- (id)init
{
    if (self = [super init]) {
        self.editable = YES;
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    if (self.isEditable) {
        return hitView;
    } else if (hitView != self) {
        return hitView;
    }
    return nil;
}

@end
