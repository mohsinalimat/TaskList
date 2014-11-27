//
//  STDTaskTableViewCell.h
//  STD
//
//  Created by Lasha Efremidze on 6/29/14.
//  Copyright (c) 2014 More Voltage. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STDTaskTableViewCell;

@protocol STDTaskTableViewCellDelegate <NSObject>

- (void)taskTableViewCell:(STDTaskTableViewCell *)cell didTouchOnTasksButton:(id)sender;
- (void)taskTableViewCell:(STDTaskTableViewCell *)cell didTouchOnNotesButton:(id)sender;
- (void)taskTableViewCell:(STDTaskTableViewCell *)cell strikethroughDidEndPanning:(NSUInteger)length;

@end

@interface STDTaskTableViewCell : UITableViewCell

@property (weak, nonatomic) id<STDTaskTableViewCellDelegate> delegate;

@property (weak, nonatomic) STDTask *task;

@property (strong, nonatomic) IBOutlet UITextField *textField;

@end
