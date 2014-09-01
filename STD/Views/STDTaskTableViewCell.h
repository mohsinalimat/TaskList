//
//  STDTaskTableViewCell.h
//  STD
//
//  Created by Lasha Efremidze on 6/29/14.
//  Copyright (c) 2014 More Voltage. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <SWTableViewCell.h>

@class STDTaskTableViewCell;

@protocol STDTaskTableViewCellDelegate <SWTableViewCellDelegate>

- (void)taskDetailsTableViewCell:(STDTaskTableViewCell *)cell didTouchOnTasksButton:(id)sender;
- (void)taskDetailsTableViewCell:(STDTaskTableViewCell *)cell didTouchOnNotesButton:(id)sender;

@end

@interface STDTaskTableViewCell : SWTableViewCell

@property (weak, nonatomic) id<STDTaskTableViewCellDelegate> delegate;

@property (weak, nonatomic) STDTask *task;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;

@property (weak, nonatomic) IBOutlet UITextField *textField;

@end
