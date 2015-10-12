//
//  STDNotesViewController.m
//  STD
//
//  Created by Lasha Efremidze on 5/25/14.
//  Copyright (c) 2014 More Voltage Inc. All rights reserved.
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
        self.task.note = [STDNote MR_createEntity];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = self.task.name;
    
    self.textView.text = self.task.note.body;
    self.textView.font = STDFontLight16;
    
    [self registerForKeyboardNotifications];
    
    [self.textView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.task.note.body = self.textView.text;
    
    [super viewWillDisappear:animated];
}

#pragma mark - IBActions

- (IBAction)didTouchOnDoneButton:(id)sender
{
    [self.textView resignFirstResponder];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView;
{
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(didTouchOnDoneButton:)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
}

- (void)textViewDidEndEditing:(UITextView *)textView;
{
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self showTextViewCaretPosition:textView animated:YES];
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    [self showTextViewCaretPosition:textView animated:YES];
}

- (void)showTextViewCaretPosition:(UITextView *)textView animated:(BOOL)animated
{
    CGRect caretRect = [textView caretRectForPosition:textView.selectedTextRange.end];
    [textView scrollRectToVisible:caretRect animated:animated];
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
        
        keyboardFrame.origin.y = CGRectGetHeight(self.view.frame);
        [self keyboardFrameChanged:keyboardFrame];
    }];
}

- (CGFloat)contentOffsetForKeyboardFrame:(CGRect)keyboardFrame
{
    CGRect convertedRect = [self.view convertRect:keyboardFrame fromView:nil];
    CGFloat offset = CGRectGetHeight(self.view.frame) - CGRectGetMinY(convertedRect);
    return CGRectIsNull(convertedRect) ? 0 : offset;
}

- (void)keyboardFrameChanged:(CGRect)newFrame
{
    if (CGRectIsNull(newFrame))
        return;
    
    UIEdgeInsets edgeInsets = self.textView.contentInset;
    edgeInsets.bottom = MAX(0, [self contentOffsetForKeyboardFrame:newFrame]);
    self.textView.contentInset = edgeInsets;
}

@end
