//
//  STDTaskDetailsTableViewCell.m
//  STD
//
//  Created by Lasha Efremidze on 6/29/14.
//  Copyright (c) 2014 More Voltage. All rights reserved.
//

#import "STDTaskDetailsTableViewCell.h"

@implementation STDTaskDetailsTableViewCell

- (void)awakeFromNib
{
    for (UIButton *button in self.buttons) {
        button.tintColor = [UIColor blackColor];
    }
}

- (IBAction)didTouchOnTasksButton:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(taskDetailsTableViewCell:didTouchOnTasksButton:)]) {
        [self.delegate taskDetailsTableViewCell:self didTouchOnTasksButton:sender];
    }
}

- (IBAction)didTouchOnNotesButton:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(taskDetailsTableViewCell:didTouchOnNotesButton:)]) {
        [self.delegate taskDetailsTableViewCell:self didTouchOnNotesButton:sender];
    }
}

@end
