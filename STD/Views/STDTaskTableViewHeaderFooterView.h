//
//  STDTaskTableViewHeaderFooterView.h
//  STD
//
//  Created by Lasha Efremidze on 11/9/14.
//  Copyright (c) 2014 More Voltage. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STDTaskTableViewHeaderFooterView;

@protocol STDTaskTableViewHeaderFooterViewDelegate <NSObject>

- (void)taskTableViewHeaderFooterView:(STDTaskTableViewHeaderFooterView *)view didTouchOnButton:(id)sender;
- (void)taskTableViewHeaderFooterView:(STDTaskTableViewHeaderFooterView *)view singleTapGestureRecognized:(UITapGestureRecognizer *)recognizer;
- (void)taskTableViewHeaderFooterView:(STDTaskTableViewHeaderFooterView *)view doubleTapGestureRecognized:(UITapGestureRecognizer *)recognizer;

@end

@interface STDTaskTableViewHeaderFooterView : UITableViewHeaderFooterView

@property (weak, nonatomic) id<STDTaskTableViewHeaderFooterViewDelegate> delegate;

@property (weak, nonatomic) STDCategory *category;

@property (strong, nonatomic) UITextField *textField;

@property (strong, nonatomic) UIButton *button;

@end
