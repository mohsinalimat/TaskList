//
//  STDNotesViewController.m
//  STD
//
//  Created by Lasha Efremidze on 5/25/14.
//  Copyright (c) 2014 Appoop Inc. All rights reserved.
//

#import "STDNotesViewController.h"
#import "UIViewController+BHTKeyboardNotifications.h"

@interface STDNotesViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;

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
    
    [self registerForKeyboardNotifications];
    
    [self.textView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.task.note.body = self.textView.text;
    
    [super viewWillDisappear:animated];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    [self showTextViewCaretPosition:textView];
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    [self showTextViewCaretPosition:textView];
}

- (void)showTextViewCaretPosition:(UITextView *)textView
{
    CGRect caretRect = [textView caretRectForPosition:textView.selectedTextRange.end];
    [textView scrollRectToVisible:caretRect animated:YES];
}

#pragma mark - Keyboard

- (void)registerForKeyboardNotifications
{
    __weak typeof(self) weakSelf = self;
    
    [self setKeyboardWillShowAnimationBlock:^(CGRect keyboardFrame) {
        typeof(self) self = weakSelf;
        
        [self keyboardFrameChanged:keyboardFrame];
    }];
    
    [self setKeyboardWillHideAnimationBlock:^(CGRect keyboardFrame) {
        typeof(self) self = weakSelf;
        
        [self keyboardFrameChanged:keyboardFrame];
    }];
}

static CGFloat contentOffsetForBottom(CGRect keyboardFrame) {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIView *view = window.rootViewController.view;
    CGRect convertedRect = [view convertRect:keyboardFrame fromView:nil];
    CGFloat offset = CGRectGetHeight(view.frame) - CGRectGetMinY(convertedRect);
    return CGRectIsNull(convertedRect) ? 0 : offset;
}

- (void)keyboardFrameChanged:(CGRect)newFrame
{
    if (CGRectIsNull(newFrame))
        return;
    
    UIEdgeInsets edgeInsets = self.textView.contentInset;
    edgeInsets.bottom = MAX(0.0f, contentOffsetForBottom(newFrame));
    self.textView.contentInset = edgeInsets;
}

@end
