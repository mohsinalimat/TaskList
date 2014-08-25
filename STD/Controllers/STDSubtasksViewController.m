//
//  STDSubtasksViewController.m
//  STD
//
//  Created by Lasha Efremidze on 5/25/14.
//  Copyright (c) 2014 Appoop Inc. All rights reserved.
//

#import "STDSubtasksViewController.h"
#import "STDSubtaskTableViewCell.h"
#import "UIViewController+BHTKeyboardNotifications.h"
#import "NSObject+Extras.h"

#define kNumberOfRowsInSection self.subtasks.count + 1
#define kTextViewFont [UIFont systemFontOfSize:17]

static char kTextViewKey;
static char kDummyTextViewKey;

@interface STDSubtasksViewController () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *subtasks;

@end

@implementation STDSubtasksViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerForKeyboardNotifications];
    
    [self styleTableView];
    
    [self.tableView reloadData];
}

#pragma mark - Styling

- (void)styleTableView
{
    self.tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - Load

- (NSArray *)subtasks
{
    if (_subtasks.count != self.task.subtasks.count) {
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(index)) ascending:YES];
        _subtasks = [self.task.subtasks sortedArrayUsingDescriptors:@[sortDescriptor]];
    }
    return _subtasks;
}

- (STDSubtask *)subtaskForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STDSubtask *subtask;
    if (self.subtasks.count > indexPath.row)
        subtask = self.subtasks[indexPath.row];
    return subtask;
}

- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITextView *textView = [self associatedObjectForKey:&kTextViewKey];
    if (textView) {
        NSInteger row = textView.superview.tag;
        if (indexPath.row == row)
            return textView.text;
    }
    
    STDSubtask *subtask = [self subtaskForRowAtIndexPath:indexPath];
    return subtask.name;
}

- (CGFloat)heightForTextView:(UITextView *)textView
{
    CGSize size = [textView sizeThatFits:(CGSize){292.0f, FLT_MAX}];
    return MAX(38.0f, size.height + 0.5f);
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kNumberOfRowsInSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STDSubtaskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([STDSubtaskTableViewCell class])];
    if (!cell) {
        cell = [[STDSubtaskTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([STDSubtaskTableViewCell class])];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.textView.delegate = self;
        cell.textView.font = kTextViewFont;
        cell.textView.placeholder = @"New Subtask";
    }
    
    cell.contentView.tag = indexPath.row;
    
    STDSubtask *subtask = [self subtaskForRowAtIndexPath:indexPath];
    cell.textView.text = subtask.name;
    cell.textView.userInteractionEnabled = !subtask;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITextView *textView = [self associatedObjectForKey:&kDummyTextViewKey];
    if (!textView) {
        textView = [UITextView new];
        textView.font = kTextViewFont;
        [self setAssociatedObject:textView forKey:&kDummyTextViewKey];
    }
    textView.text = [self textForRowAtIndexPath:indexPath];
    return [self heightForTextView:textView];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self setAssociatedObject:textView forKey:&kTextViewKey];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    NSInteger row = textView.superview.tag;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    STDSubtask *subtask = [self subtaskForRowAtIndexPath:indexPath];
    if (subtask)
        return textView.text.length;
    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self setAssociatedObject:nil forKey:&kTextViewKey];

    if (!textView.text.length)
        return;
    
    NSInteger row = textView.superview.tag;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    STDSubtask *subtask = [self subtaskForRowAtIndexPath:indexPath];
    if (!subtask) {
        subtask = [STDSubtask createEntity];
        [self.task addSubtasksObject:subtask];
    }
    
    subtask.name = textView.text;
    
    [[NSManagedObjectContext contextForCurrentThread] saveOnlySelfAndWait];
    
    [self.tableView beginUpdates];
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];

    if (indexPath.row == ([self.tableView numberOfRowsInSection:indexPath.section] - 1))
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
    
    [self.tableView endUpdates];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    CGFloat oldHeight = textView.frame.size.height;
    CGFloat newHeight = [self heightForTextView:textView] - 0.5f;
    if (oldHeight != newHeight) {
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        
        [self scrollToTextView:textView animated:YES];
    }
}

- (void)scrollToTextView:(UITextView *)textView animated:(BOOL)animated
{
    NSInteger row = textView.superview.tag;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:animated];
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
    
    UIEdgeInsets edgeInsets = self.tableView.contentInset;
    edgeInsets.bottom = MAX(0.0f, contentOffsetForBottom(newFrame));
    self.tableView.contentInset = edgeInsets;
}

@end
