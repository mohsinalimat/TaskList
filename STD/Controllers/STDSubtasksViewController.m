//
//  STDSubtasksViewController.m
//  STD
//
//  Created by Lasha Efremidze on 5/25/14.
//  Copyright (c) 2014 Appoop Inc. All rights reserved.
//

#import "STDSubtasksViewController.h"
#import "HPGrowingTextView.h"
#import "UIViewController+BHTKeyboardNotifications.h"

#define kTextView 10

#define kNumberOfRowsInSection self.subtasks.count + 1

@interface STDSubtasksViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, HPGrowingTextViewDelegate>

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
    
    HPGrowingTextView *textView = (HPGrowingTextView *)[cell.contentView viewWithTag:kTextView];
    if (!textView) {
        textView = [[HPGrowingTextView alloc] initWithFrame:(CGRect){14, 7, 292, 30}];
        textView.tag = kTextView;
        textView.delegate = self;
        textView.isScrollable = NO;
        textView.font = [UIFont systemFontOfSize:17];
        textView.placeholder = @"New Subtask";
        
        [cell.contentView addSubview:textView];
    }
    
    STDSubtask *subtask = [self subtaskForRowAtIndexPath:indexPath];
    textView.text = subtask.name;
    textView.userInteractionEnabled = !subtask;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self textViewHeightForRowAtIndexPath:indexPath];
}

#pragma mark - HPGrowingTextViewDelegate

- (BOOL)growingTextViewShouldEndEditing:(HPGrowingTextView *)growingTextView;
{
    CGPoint hitPoint = [growingTextView convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:hitPoint];
    if (indexPath) {
        STDSubtask *subtask = [self subtaskForRowAtIndexPath:indexPath];
        if (subtask)
            return growingTextView.text.length;
    }
    
    return YES;
}

- (void)growingTextViewDidEndEditing:(HPGrowingTextView *)growingTextView;
{
    if (!growingTextView.text.length)
        return;
    
    CGPoint hitPoint = [growingTextView convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:hitPoint];
    if (indexPath) {
        STDSubtask *subtask = [self subtaskForRowAtIndexPath:indexPath];
        if (!subtask) {
            subtask = [STDSubtask createEntity];
            [self.task addSubtasksObject:subtask];
        }
        
        subtask.name = growingTextView.text;
        
        [[NSManagedObjectContext contextForCurrentThread] saveOnlySelfAndWait];
        
        [self.tableView reloadData];
    }
}

#pragma mark - Helpers

- (CGRect)boundingRectForString:(NSString *)string
{
    return [string boundingRectWithSize:(CGSize){320, MAXFLOAT} options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]} context:nil];
}

- (CGFloat)textViewHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STDSubtask *subtask = [self subtaskForRowAtIndexPath:indexPath];
    CGRect rect = [self boundingRectForString:subtask.name];
    return MAX(44, rect.size.height + 20);
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
