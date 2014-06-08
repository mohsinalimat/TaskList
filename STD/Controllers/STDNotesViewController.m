//
//  STDNotesViewController.m
//  STD
//
//  Created by Lasha Efremidze on 5/25/14.
//  Copyright (c) 2014 Appoop Inc. All rights reserved.
//

#import "STDNotesViewController.h"

@interface STDNotesViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

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

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView;
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];

    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView;
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

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
    CGRect caretRect = [textView caretRectForPosition:self.textView.selectedTextRange.end];
    [textView scrollRectToVisible:caretRect animated:NO];
}

#pragma mark - Keyboard

static CGFloat contentOffsetForBottom(CGRect keyboardFrame) {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIView *view = window.rootViewController.view;
    CGRect convertedRect = [view convertRect:keyboardFrame fromView:nil];
    return CGRectIsNull(convertedRect) ? 0 : CGRectGetHeight(convertedRect);
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    [self handleKeyboardNotification:notification];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self handleKeyboardNotification:notification];
}

- (void)handleKeyboardNotification:(NSNotification *)notification
{
    CGRect frameEnd;
    [[[notification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&frameEnd];
    
    double animationDuration;
    [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    UIViewAnimationCurve animationCurve;
    [[[notification userInfo] valueForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    
    self.bottomConstraint.constant = contentOffsetForBottom(frameEnd);
    
    [UIView animateWithDuration:animationDuration delay:0.0f options:((animationCurve << 16) | UIViewAnimationOptionBeginFromCurrentState) animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
}

@end
