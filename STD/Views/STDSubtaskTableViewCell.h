//
//  STDSubtaskTableViewCell.h
//  STD
//
//  Created by Lasha Efremidze on 7/27/14.
//  Copyright (c) 2014 More Voltage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SZTextView.h"

@class STDSubtaskTableViewCell;

@protocol STDSubtaskTableViewCellDelegate <NSObject>

- (void)subtaskTableViewCell:(STDSubtaskTableViewCell *)cell didTouchOnNotesButton:(id)sender;
- (void)subtaskTableViewCell:(STDSubtaskTableViewCell *)cell didTouchOnMoveButton:(id)sender;

@end

@interface STDSubtaskTableViewCell : UITableViewCell

@property (weak, nonatomic) id<STDSubtaskTableViewCellDelegate> delegate;

@property (weak, nonatomic) STDSubtask *subtask;

@property (strong, nonatomic) SZTextView *textView;

@end
