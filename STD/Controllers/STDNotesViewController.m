//
//  STDNotesViewController.m
//  STD
//
//  Created by Lasha Efremidze on 5/25/14.
//  Copyright (c) 2014 Appoop Inc. All rights reserved.
//

#import "STDNotesViewController.h"

@interface STDNotesViewController ()

@property (strong, nonatomic) UITextView *textView;

@end

@implementation STDNotesViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.task.note)
        self.task.note = [STDNote createEntity];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.textView.text = self.task.note.body;
    
    [self.textView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.task.note.body = self.textView.text;
    
    [super viewWillDisappear:animated];
}

#pragma mark - UITextView

- (UITextView *)textView
{
    if (!_textView) {
        _textView = [[UITextView alloc] initWithFrame:self.view.bounds];
        _textView.textContainerInset = (UIEdgeInsets){[UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.bounds.size.height, 0, 0, 0};
        _textView.showsVerticalScrollIndicator = NO;
        [self.view addSubview:_textView];
    }
    return _textView;
}

@end
