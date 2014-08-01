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
    self.textView.scrollEnabled = NO;
    self.textView.scrollsToTop = NO;
    self.textView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
}

@end
