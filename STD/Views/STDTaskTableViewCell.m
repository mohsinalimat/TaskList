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

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // text field
        self.textField = [UITextField newAutoLayoutView];
        self.textField.borderStyle = UITextBorderStyleNone;
        [self.contentView addSubview:self.textField];
        
        [self.textField autoPinEdgesToSuperviewEdgesWithInsets:(UIEdgeInsets){7, 14, 7, 14}];
    }
    return self;
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
