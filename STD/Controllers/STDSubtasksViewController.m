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
#import "UITableView+LongPressReorder.h"

#import "STDNotesViewController.h"

#define kNumberOfRowsInSection self.subtasks.count + 1
#define kTextViewFont [UIFont systemFontOfSize:17]

static char kTextViewKey;
static char kDummyTextViewKey;

@interface STDSubtasksViewController () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, STDSubtaskTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *subtasks;

@property (strong, nonatomic) NSMutableArray *expandedItems;

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
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0f;
    
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    self.tableView.longPressReorderEnabled = YES;
    self.tableView.lprDelegate = (id)self;
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

- (void)updateIndexesForSubtasks:(NSArray *)subtasks
{
    for (STDSubtask *subtask in subtasks) {
        subtask.indexValue = [subtasks indexOfObject:subtask];
    }
}

- (STDSubtask *)subtaskForIndexPath:(NSIndexPath *)indexPath
{
    STDSubtask *subtask;
    if (self.subtasks.count > indexPath.row)
        subtask = self.subtasks[indexPath.row];
    return subtask;
}

- (NSString *)textForIndexPath:(NSIndexPath *)indexPath
{
    UITextView *textView = [self associatedObjectForKey:&kTextViewKey];
    if (textView) {
        NSInteger row = textView.superview.tag;
        if (indexPath.row == row)
            return textView.text;
    }
    
    STDSubtask *subtask = [self subtaskForIndexPath:indexPath];
    return subtask.name;
}

- (CGFloat)heightForTextView:(UITextView *)textView
{
    CGSize size = [textView sizeThatFits:(CGSize){CGRectGetWidth(self.view.bounds) - 28.0f, FLT_MAX}];
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
        cell = (STDSubtaskTableViewCell *)[[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([STDSubtaskTableViewCell class]) owner:self options:nil] firstObject];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.clipsToBounds = YES;
        
        cell.delegate = self;
        
        cell.textView.delegate = self;
        cell.textView.font = kTextViewFont;
        cell.textView.placeholder = @"New Subtask";
    }
    
    cell.contentView.tag = indexPath.row;
    
    STDSubtask *subtask = [self subtaskForIndexPath:indexPath];
    cell.textView.text = subtask.name;
    cell.textView.userInteractionEnabled = !subtask;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    STDSubtask *subtask = [self subtaskForIndexPath:indexPath];
    if (!subtask)
        return;
    
    [self toggleSubtask:subtask];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITextView *textView = [self associatedObjectForKey:&kDummyTextViewKey];
    if (!textView) {
        textView = [UITextView new];
        textView.font = kTextViewFont;
        [self setAssociatedObject:textView forKey:&kDummyTextViewKey];
    }
    textView.text = [self textForIndexPath:indexPath];
    CGFloat height = [self heightForTextView:textView];
    
    STDSubtask *subtask = [self subtaskForIndexPath:indexPath];
    if ([self isSubtaskExpanded:subtask])
        height += 44.0f;
    
    return height;
}

#pragma mark - Reorder

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    STDSubtask *subtask = [self subtaskForIndexPath:indexPath];
    return (subtask != nil);
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    STDSubtask *subtask = [self subtaskForIndexPath:sourceIndexPath];
    
    [self.task removeSubtasksObject:subtask];
    
    NSMutableArray *subtasks = [NSMutableArray arrayWithArray:self.subtasks];
    [subtasks insertObject:subtask atIndex:destinationIndexPath.row];
    self.task.subtasks = [NSSet setWithArray:subtasks];
    
    [self updateIndexesForSubtasks:subtasks];
    
    [[NSManagedObjectContext contextForCurrentThread] saveOnlySelfAndWait];
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    STDSubtask *subtask = [self subtaskForIndexPath:proposedDestinationIndexPath];
    return (subtask ? proposedDestinationIndexPath : sourceIndexPath);
}

#pragma mark - Expand/Collapse

- (void)toggleSubtask:(STDSubtask *)subtask
{
    [self.tableView beginUpdates];
    
    if (!self.expandedItems)
        self.expandedItems = [NSMutableArray array];
    BOOL expanded = [self isSubtaskExpanded:subtask];
    if (expanded) {
        [self.expandedItems removeObject:subtask];
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"class == %@", [subtask class]];
        NSArray *tasks = [self.expandedItems filteredArrayUsingPredicate:predicate];
        [self.expandedItems removeObjectsInArray:tasks];
        
        [self.expandedItems addObject:subtask];
    }
    
    [self.tableView endUpdates];
}

- (BOOL)isSubtaskExpanded:(STDSubtask *)subtask
{
    return [self.expandedItems containsObject:subtask];
}

#pragma mark - STDSubtaskTableViewCellDelegate

- (void)subtaskTableViewCell:(STDSubtaskTableViewCell *)cell didTouchOnNotesButton:(id)sender;
{
    STDNotesViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"STDNotesViewControllerId"];
    viewController.task = self.task;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)subtaskTableViewCell:(STDSubtaskTableViewCell *)cell didTouchOnMoveButton:(id)sender;
{
    
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
    STDSubtask *subtask = [self subtaskForIndexPath:indexPath];
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
    STDSubtask *subtask = [self subtaskForIndexPath:indexPath];
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
