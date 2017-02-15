//
//  STDTaskTableViewCell.m
//  STD
//
//  Created by Lasha Efremidze on 6/29/14.
//  Copyright (c) 2014 More Voltage. All rights reserved.
//

#import "STDTaskTableViewCell.h"

@interface STDTaskTableViewCell ()

@property (nonatomic, strong) UIView *expandableView;

@end

@implementation STDTaskTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.textField.rightView = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = (CGRect){0, 0, 44, 44};
        button.titleLabel.font = STDFontLight16;
        button.tintColor = [UIColor darkGrayColor];
        button;
    });
    self.textField.rightViewMode = UITextFieldViewModeUnlessEditing;
    
    [self.contentView addSubview:self.expandableView];
}

- (UIView *)expandableView
{
    if (!_expandableView) {
        _expandableView = ({
            UIView *view = [[UIView alloc] initWithFrame:CGRectOffset(self.bounds, 0, 44)];
            view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            
            [view addSubview:({
                UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
                button.frame = (CGRect){0, 0, CGRectGetMidX(view.bounds), CGRectGetHeight(view.bounds)};
                button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
                [button setTitle:@"Tasks" forState:UIControlStateNormal];
                button.titleLabel.font = STDFontLight16;
                button.tintColor = STDColorDefault;
                [button addTarget:self action:@selector(didTouchOnTasksButton:) forControlEvents:UIControlEventTouchUpInside];
                button;
            })];
            
            [view addSubview:({
                CGRect rect = (CGRect){CGRectGetMidX(view.bounds), 0, 0.5f, CGRectGetHeight(view.bounds)};
                UIView *dividerView = [[UIView alloc] initWithFrame:CGRectInset(rect, 0, 10)];
                dividerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
                dividerView.backgroundColor = [UIColor colorWithWhite:0.5f alpha:0.1f];
                dividerView;
            })];
            
            [view addSubview:({
                UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
                button.frame = (CGRect){CGRectGetMidX(view.bounds), 0, CGRectGetMidX(view.bounds), CGRectGetHeight(view.bounds)};
                button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
                [button setTitle:@"Notes" forState:UIControlStateNormal];
                button.titleLabel.font = STDFontLight16;
                button.tintColor = STDColorDefault;
                [button addTarget:self action:@selector(didTouchOnNotesButton:) forControlEvents:UIControlEventTouchUpInside];
                button;
            })];
            
            view;
        });
    }
    return _expandableView;
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
