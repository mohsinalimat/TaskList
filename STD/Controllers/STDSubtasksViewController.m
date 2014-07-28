//
//  STDSubtasksViewController.m
//  STD
//
//  Created by Lasha Efremidze on 5/25/14.
//  Copyright (c) 2014 Appoop Inc. All rights reserved.
//

#import "STDSubtasksViewController.h"
#import "UIViewController+BHTKeyboardNotifications.h"
#import "NSObject+Extras.h"

#define kTextView 10

#define kNumberOfRowsInSection self.subtasks.count + 1
#define kTextViewFont [UIFont systemFontOfSize:17]

static char kTextViewKey;

@interface STDSubtasksViewController () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

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

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kNumberOfRowsInSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TableViewCellStyleDefault";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.contentView.tag = indexPath.row;
    
    UITextView *textView = (UITextView *)[cell.contentView viewWithTag:kTextView];
    if (!textView) {
        textView = [[UITextView alloc] initWithFrame:(CGRect){10, 3, 300, 30}];
        textView.tag = kTextView;
        textView.delegate = self;
        textView.font = kTextViewFont;
//        textView.placeholder = @"New Subtask";
        textView.scrollEnabled = NO;
        textView.scrollsToTop = NO;
        textView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
        [cell.contentView addSubview:textView];
    }
    
    NSLog(@"textView %@", textView);
    
    STDSubtask *subtask = [self subtaskForRowAtIndexPath:indexPath];
    textView.text = subtask.name;
    textView.userInteractionEnabled = !subtask;
    
    CGRect rect = textView.frame;
    rect.size.height = [self textViewHeightForString:textView.text];
    textView.frame = rect;

    if (!subtask)
        [textView becomeFirstResponder];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self textViewHeightForRowAtIndexPath:indexPath];
}

#pragma mark - HPGrowingTextViewDelegate

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
    
    [self.tableView reloadData];
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
//    CGRect rect = textView.frame;
//    rect.size.height = [self textViewHeightForString:textView.text];
//    if (!CGRectEqualToRect(textView.frame, rect)) {
//        textView.frame = rect;
//        
//        [self.tableView beginUpdates];
//        [self.tableView endUpdates];
//    }
}

#pragma mark - Helpers

- (CGRect)boundingRectForString:(NSString *)string
{
    if (!string.length)
        return CGRectZero;
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName: kTextViewFont}];
    return [attributedText boundingRectWithSize:(CGSize){300, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
}

- (CGFloat)textViewHeightForString:(NSString *)string
{
    CGRect rect = [self boundingRectForString:string];
    return MAX(44.0f, ceilf(rect.size.height) + 23.0f);
}

- (CGFloat)textViewHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self textViewHeightForString:[self stringForIndexPath:indexPath]];
}

- (NSString *)stringForIndexPath:(NSIndexPath *)indexPath
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
