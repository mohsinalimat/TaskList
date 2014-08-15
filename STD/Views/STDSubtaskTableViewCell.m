//
//  STDSubtaskTableViewCell.m
//  STD
//
//  Created by Lasha Efremidze on 7/27/14.
//  Copyright (c) 2014 More Voltage. All rights reserved.
//

#import "STDSubtaskTableViewCell.h"

@implementation STDSubtaskTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textView = [[SZTextView alloc] initWithFrame:(CGRect){14.0f, CGRectGetMinY(self.bounds), 292.0f, CGRectGetHeight(self.bounds)}];
        self.textView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        self.textView.scrollsToTop = NO;
        self.textView.scrollEnabled = NO;
        self.textView.showsVerticalScrollIndicator = NO;
        self.textView.showsHorizontalScrollIndicator = NO;
        [self.contentView addSubview:self.textView];
    }
    
    return self;
}

@end
