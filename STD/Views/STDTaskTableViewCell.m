//
//  STDTaskTableViewCell.m
//  STD
//
//  Created by Lasha Efremidze on 6/29/14.
//  Copyright (c) 2014 More Voltage. All rights reserved.
//

#import "STDTaskTableViewCell.h"

@implementation STDTaskTableViewCell

- (void)awakeFromNib
{
    for (UIButton *button in self.buttons) {
        button.tintColor = [UIColor blackColor];
    }
    
    self.textField.rightView = [self rightView];
    self.textField.rightViewMode = UITextFieldViewModeUnlessEditing;
}

- (UIButton *)rightView
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = (CGRect){0, 0, 44, 44};
    button.titleLabel.font = STDFont16;
    button.tintColor = [UIColor darkGrayColor];
    return button;
}

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
