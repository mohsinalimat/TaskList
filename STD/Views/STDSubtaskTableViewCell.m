//
//  STDSubtaskTableViewCell.m
//  STD
//
//  Created by Lasha Efremidze on 7/27/14.
//  Copyright (c) 2014 More Voltage. All rights reserved.
//

#import "STDSubtaskTableViewCell.h"

@implementation STDSubtaskTableViewCell

- (void)awakeFromNib
{
    for (UIButton *button in self.buttons) {
        button.tintColor = [UIColor blackColor];
    }
}

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
