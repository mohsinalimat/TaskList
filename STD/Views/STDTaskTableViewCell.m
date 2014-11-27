//
//  STDTaskTableViewCell.m
//  STD
//
//  Created by Lasha Efremidze on 6/29/14.
//  Copyright (c) 2014 More Voltage. All rights reserved.
//

#import "STDTaskTableViewCell.h"
#import "UITableViewCell+Strikethrough.h"
#import "PureLayout.h"

@interface STDTaskTableViewCell () <StrikethroughTableViewCellDelegate>

@end

@implementation STDTaskTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textField = [UITextField newAutoLayoutView];
        self.textField.borderStyle = UITextBorderStyleNone;
        [self.contentView addSubview:self.textField];
        
        [self.textField autoPinEdgesToSuperviewEdgesWithInsets:(UIEdgeInsets){7, 14, 7, 14}];
        
        self.strikethroughDelegate = self;
        self.strikethroughEnabled = YES;
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

- (void)strikethroughDidEndPanning:(NSUInteger)length
{
    if ([self.delegate respondsToSelector:@selector(taskTableViewCell:strikethroughDidEndPanning:)]) {
        [self.delegate taskTableViewCell:self strikethroughDidEndPanning:length];
    }
}

#pragma mark - StrikethroughTableViewCellDelegate

- (void)tableViewCell:(UITableViewCell *)tableViewCell strikethroughDidChange:(NSUInteger)length
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

- (void)tableViewCell:(UITableViewCell *)tableViewCell strikethroughDidEndPanning:(NSUInteger)length
{
    if (length > (self.textField.attributedText.length / 2.0f)) {
        [self tableViewCell:self strikethroughDidChange:self.textField.attributedText.length];
        
        [self strikethroughDidEndPanning:self.textField.attributedText.length];
    } else {
        [self tableViewCell:self strikethroughDidChange:0];
    }
}

@end
