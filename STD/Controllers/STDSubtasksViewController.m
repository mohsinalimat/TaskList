//
//  STDSubtasksViewController.m
//  STD
//
//  Created by Lasha Efremidze on 5/25/14.
//  Copyright (c) 2014 Appoop Inc. All rights reserved.
//

#import "STDSubtasksViewController.h"
#import "HPGrowingTextView.h"

#define kTextView 10

@interface STDSubtasksViewController () <UITableViewDataSource, UITableViewDelegate, HPGrowingTextViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@property (strong, nonatomic) NSArray *subtasks;

@end

@implementation STDSubtasksViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (NSArray *)subtasks
{
    if (!_subtasks) {
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
    return self.subtasks.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TableViewCellStyleDefault";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    HPGrowingTextView *textView = (HPGrowingTextView *)[cell viewWithTag:kTextView];
    if (!textView) {
        textView = [[HPGrowingTextView alloc] initWithFrame:cell.bounds];
        textView.tag = kTextView;
        textView.delegate = self;
        textView.isScrollable = NO;
        textView.font = [UIFont systemFontOfSize:17];
        
        [cell.contentView addSubview:textView];
    }
    
    STDSubtask *subtask = [self subtaskForRowAtIndexPath:indexPath];
    textView.text = subtask.name;
    
    if (!subtask) textView.placeholder = @"Add a subtask";
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self textViewHeightForRowAtIndexPath:indexPath];
}

- (CGRect)textViewRectForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STDSubtask *subtask = [self subtaskForRowAtIndexPath:indexPath];
    NSString *text = subtask.name;
    NSLog(@"text %@", text);
    UIFont *font = [UIFont systemFontOfSize:17];
    return [text boundingRectWithSize:(CGSize){320, MAXFLOAT} options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
}

- (CGFloat)textViewHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect rect = [self textViewRectForRowAtIndexPath:indexPath];
    return MAX(44, rect.size.height + 20);
}

#pragma mark - HPGrowingTextViewDelegate

- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView;
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    return YES;
}

- (void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (BOOL)growingTextViewShouldEndEditing:(HPGrowingTextView *)growingTextView;
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    return YES;
}

- (void)growingTextViewDidEndEditing:(HPGrowingTextView *)growingTextView;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView;
{
//    CGPoint location = [growingTextView.superview convertPoint:growingTextView.center toView:self.tableView];
//    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
//    STDSubtask *subtask = [self subtaskForRowAtIndexPath:indexPath];
//    if (!subtask) {
//        subtask = [STDSubtask createEntity];
//        subtask.indexValue = self.subtasks.count;
//        [self.task addSubtasksObject:subtask];
//        self.subtasks = [self.subtasks arrayByAddingObject:subtask];
//    }
//    subtask.name = growingTextView.text;
//    NSMutableArray *array = [self.subtasks mutableCopy];
//    [array replaceObjectAtIndex:indexPath.row withObject:subtask];
//    self.subtasks = [NSArray arrayWithArray:array];
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView didChangeHeight:(float)height;
{
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
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
