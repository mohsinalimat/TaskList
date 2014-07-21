//
//  STDTaskDetailsTableViewCell.h
//  STD
//
//  Created by Lasha Efremidze on 6/29/14.
//  Copyright (c) 2014 More Voltage. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STDTaskDetailsTableViewCell;

@protocol STDTaskDetailsTableViewCellDelegate <NSObject>

- (void)taskDetailsTableViewCell:(STDTaskDetailsTableViewCell *)cell didTouchOnTasksButton:(id)sender;
- (void)taskDetailsTableViewCell:(STDTaskDetailsTableViewCell *)cell didTouchOnNotesButton:(id)sender;

@end

@interface STDTaskDetailsTableViewCell : UITableViewCell

@property (weak, nonatomic) id<STDTaskDetailsTableViewCellDelegate> delegate;

@property (weak, nonatomic) STDTask *task;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;

@property (weak, nonatomic) IBOutlet UITextField *textField;

@end
