//
//  STDSubtaskTableViewCell.h
//  STD
//
//  Created by Lasha Efremidze on 7/27/14.
//  Copyright (c) 2014 More Voltage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SZTextView.h"

@interface STDSubtaskTableViewCell : UITableViewCell

@property (weak, nonatomic) STDTask *subtask;

@property (strong, nonatomic) SZTextView *textView;

@end
