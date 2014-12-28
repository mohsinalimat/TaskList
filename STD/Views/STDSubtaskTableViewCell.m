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
    self.textView.scrollsToTop = NO;
    self.textView.contentInset = (UIEdgeInsets){2, 0, 0, 0};
}

@end
