//
//  STDTaskTableViewCell.m
//  STD
//
//  Created by Lasha Efremidze on 6/29/14.
//  Copyright (c) 2014 More Voltage. All rights reserved.
//

#import "STDTaskTableViewCell.h"
#import "PureLayout.h"

@implementation STDTaskTableViewCell

- (UITextField *)textField
{
    if (!_textField) {
        _textField = [UITextField newAutoLayoutView];
        _textField.borderStyle = UITextBorderStyleNone;
        [self.contentView addSubview:_textField];
        
        [_textField autoPinEdgesToSuperviewEdgesWithInsets:(UIEdgeInsets){0, 14, 0, 14} excludingEdge:ALEdgeBottom];
        [_textField autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.contentView];
    }
    return _textField;
}

#pragma mark - IBActions

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

@end
