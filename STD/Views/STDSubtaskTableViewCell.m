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

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {        
        // text view
        self.textView = [SZTextView newAutoLayoutView];
        self.textView.scrollsToTop = NO;
        [self.contentView addSubview:self.textView];
        
        [self.textView autoPinEdgesToSuperviewEdgesWithInsets:(UIEdgeInsets){0, 14, 0, 14}];
    }
    return self;
}

#pragma mark - IBActions

- (IBAction)didTouchOnNotesButton:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(subtaskTableViewCell:didTouchOnNotesButton:)]) {
        [self.delegate subtaskTableViewCell:self didTouchOnNotesButton:sender];
    }
}

- (IBAction)didTouchOnMoveButton:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(subtaskTableViewCell:didTouchOnMoveButton:)]) {
        [self.delegate subtaskTableViewCell:self didTouchOnMoveButton:sender];
    }
}

@end
