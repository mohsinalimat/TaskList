//
//  STDSubtaskTableViewCell.m
//  STD
//
//  Created by Lasha Efremidze on 7/27/14.
//  Copyright (c) 2014 More Voltage. All rights reserved.
//

#import "STDSubtaskTableViewCell.h"
#import "PureLayout.h"

@implementation STDSubtaskTableViewCell

- (SZTextView *)textView
{
    if (!_textView) {
        _textView = [SZTextView newAutoLayoutView];
        _textView.scrollsToTop = NO;
        [self.contentView addSubview:_textView];
        
        [_textView autoPinEdgesToSuperviewEdgesWithInsets:(UIEdgeInsets){0, 14, 0, 14} excludingEdge:ALEdgeBottom];
        [_textView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.contentView];
    }
    return _textView;
}

@end
