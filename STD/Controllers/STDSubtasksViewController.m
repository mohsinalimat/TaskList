//
//  STDSubtasksViewController.m
//  STD
//
//  Created by Lasha Efremidze on 5/25/14.
//  Copyright (c) 2014 More Voltage Inc. All rights reserved.
//

#import "STDSubtasksViewController.h"
#import "STDSubtaskTableViewCell.h"
#import "UIViewController+BHTKeyboardNotifications.h"
#import "NSObject+Extras.h"
#import "UITableView+LongPressReorder.h"
#import "UITableViewCell+Strikethrough.h"
#import "PureLayout.h"
#import "STDCoreDataUtilities.h"

#import "STDNotesViewController.h"

#define kNumberOfRowsInSection self.subtasks.count + 1
#define kTextViewFont [UIFont systemFontOfSize:17]

static char kTextViewKey;
static char kDummyTextViewKey;

static char kSubtaskKey;

@interface STDSubtasksViewController () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, STDTableViewCellStrikethroughDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) UIView *footerView;

@property (strong, nonatomic) NSMutableArray *subtasks;

@property (strong, nonatomic) NSLayoutConstraint *heightLayoutConstraint;

@end

@implementation STDSubtasksViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = self.task.name;
    
    [self registerForKeyboardNotifications];
    
    [self styleTableView];
    
    [self load];
    
    [self.tableView reloadData];
    
    [self footerView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        UIViewController *viewController = self.navigationController.topViewController;
        if ([viewController respondsToSelector:@selector(tableView)]) {
            UITableView *tableView = [viewController performSelector:@selector(tableView)];
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:[[[STDCoreDataUtilities sharedInstance] categories] indexOfObject:self.task.category]] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    
    [super viewWillDisappear:animated];
}

#pragma mark - IBActions

- (IBAction)didTouchOnUndoButton:(id)sender
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideFooterView) object:nil];
    
    [self hideFooterView];
    
    STDTask *subtask = [self associatedObjectForKey:&kSubtaskKey];
    if (subtask) {
        // core data
        subtask.completed = @NO;
        subtask.completion_date = nil;
        
        [self load];
        
        [[NSManagedObjectContext contextForCurrentThread] saveOnlySelfAndWait];
        
        NSIndexPath *indexPath = [self indexPathOfSubtask:subtask];
        
        // insert
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)didCompleteSubtask:(STDTask *)subtask
{
    [self setAssociatedObject:subtask forKey:&kSubtaskKey];
    
    NSIndexPath *indexPath = [self indexPathOfSubtask:subtask];
    
    // core data
    subtask.completed = @YES;
    subtask.completion_date = [NSDate date];
    
    [self load];
    
    [[NSManagedObjectContext contextForCurrentThread] saveOnlySelfAndWait];
    
    // delete row
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    [self showFooterView];
}

- (void)doubleTapGestureRecognized:(UITapGestureRecognizer *)recognizer;
{
    CGPoint hitPoint = [recognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:hitPoint];
    STDSubtaskTableViewCell *cell = (STDSubtaskTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if (cell) {
        cell.textView.userInteractionEnabled = YES;
        [cell.textView becomeFirstResponder];
    }
}

#pragma mark - Styling

- (void)styleTableView
{
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    self.tableView.longPressReorderEnabled = YES;
    self.tableView.lprDelegate = (id)self;
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureRecognized:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.tableView addGestureRecognizer:doubleTap];
}

#pragma mark - Footer View

- (void)showFooterView
{
    self.heightLayoutConstraint.constant = 44.0f;
    
    [UIView animateWithDuration:0.3f animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self performSelector:@selector(hideFooterView) withObject:nil afterDelay:5.0f];
    }];
}

- (void)hideFooterView
{
    self.heightLayoutConstraint.constant = 0.0f;
    
    [UIView animateWithDuration:0.3f animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (UIView *)footerView
{
    if (!_footerView) {
        _footerView = [UIView newAutoLayoutView];
        _footerView.clipsToBounds = YES;
        [self.view addSubview:_footerView];
        
        [_footerView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
        self.heightLayoutConstraint = [_footerView autoSetDimension:ALDimensionHeight toSize:0.0f];
        
        UIButton *undoButton = [UIButton buttonWithType:UIButtonTypeSystem];
        undoButton.translatesAutoresizingMaskIntoConstraints = NO;
        undoButton.backgroundColor = [UIColor colorWithHue:(210.0f / 360.0f) saturation:0.94f brightness:1.0f alpha:1.0f];
        undoButton.tintColor = [UIColor whiteColor];
        [undoButton setTitle:@"Undo" forState:UIControlStateNormal];
        [undoButton addTarget:self action:@selector(didTouchOnUndoButton:) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:undoButton];
        
        [undoButton autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
        [undoButton autoSetDimension:ALDimensionHeight toSize:44.0f];
    }
    return _footerView;
}

#pragma mark - Load

- (void)load
{
    NSArray *subtasks = [[STDCoreDataUtilities sharedInstance] sortedUncompletedSubtasksForTask:self.task];
    self.subtasks = [NSMutableArray arrayWithArray:subtasks];
}

- (STDTask *)subtaskForIndexPath:(NSIndexPath *)indexPath
{
    STDTask *subtask;
    if (self.subtasks.count > indexPath.row)
        subtask = self.subtasks[indexPath.row];
    return subtask;
}

- (NSIndexPath *)indexPathOfSubtask:(STDTask *)subtask
{
    return [NSIndexPath indexPathForRow:[self.subtasks indexOfObject:subtask] inSection:0];
}

- (NSString *)textForIndexPath:(NSIndexPath *)indexPath
{
    UITextView *textView = [self associatedObjectForKey:&kTextViewKey];
    if (textView) {
        NSInteger row = textView.superview.tag;
        if (indexPath.row == row)
            return textView.text;
    }
    
    STDTask *subtask = [self subtaskForIndexPath:indexPath];
    return subtask.name;
}

- (CGFloat)heightForTextView:(UITextView *)textView
{
    CGSize size = [textView sizeThatFits:(CGSize){CGRectGetWidth(self.view.bounds) - 28.0f, FLT_MAX}];
    return [self adjustHeight:size.height];
}

- (CGFloat)adjustHeight:(CGFloat)height
{
    return MAX(44.0f, height + 2.5f);
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
        
        cell.strikethroughDelegate = self;
        
        cell.textView.font = kTextViewFont;
        cell.textView.placeholder = @"New Task";
        cell.textView.delegate = self;
    }
    
    cell.contentView.tag = indexPath.row;
    
    STDTask *subtask = [self subtaskForIndexPath:indexPath];
    
    cell.textView.userInteractionEnabled = !subtask;
    
    cell.textView.attributedText = nil;
    if (subtask.name) {
        cell.textView.attributedText = [[NSAttributedString alloc] initWithString:subtask.name attributes:@{NSFontAttributeName:cell.textView.font}];
    }
    
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
    textView.text = [self textForIndexPath:indexPath];
    return [self heightForTextView:textView];
}

#pragma mark - Reorder

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    STDTask *subtask = [self subtaskForIndexPath:indexPath];
    return (subtask != nil);
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [self.subtasks exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
    
    [self.task.subtasksSet addObjectsFromArray:self.subtasks];
    
    [[STDCoreDataUtilities sharedInstance] updateIndexesForManagedObjects:self.subtasks];

    [self load];
    
    [[NSManagedObjectContext contextForCurrentThread] saveOnlySelfAndWait];
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    STDTask *subtask = [self subtaskForIndexPath:proposedDestinationIndexPath];
    return (subtask ? proposedDestinationIndexPath : sourceIndexPath);
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
    STDTask *subtask = [self subtaskForIndexPath:indexPath];
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
    STDTask *subtask = [self subtaskForIndexPath:indexPath];
    if (!subtask) {
        subtask = [STDTask createEntity];
        [self.task addSubtasksObject:subtask];
        [self.subtasks addObject:subtask];
    }
    
    subtask.name = textView.text;
    
    [[NSManagedObjectContext contextForCurrentThread] saveOnlySelfAndWait];
    
    BOOL isNew = (indexPath.row == ([self.tableView numberOfRowsInSection:indexPath.section] - 1));

    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        if (isNew) {
            STDSubtaskTableViewCell *cell = (STDSubtaskTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section]];
            [cell.textView becomeFirstResponder];
        }
    }];
    
    [self.tableView beginUpdates];
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];

    if (isNew) {
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [self.tableView endUpdates];
    
    [CATransaction commit];
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
    CGFloat oldHeight = [self adjustHeight:textView.bounds.size.height];
    CGFloat newHeight = [self heightForTextView:textView];
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

#pragma mark - STDTableViewCellStrikethroughDelegate

- (void)setAttributedText:(NSAttributedString *)attributedText forTableViewCell:(STDSubtaskTableViewCell *)tableViewCell
{
    tableViewCell.textView.attributedText = attributedText;
}

- (NSAttributedString *)attributedTextForTableViewCell:(STDSubtaskTableViewCell *)tableViewCell
{
    return tableViewCell.textView.attributedText;
}

- (void)strikethroughGestureDidEnd:(UITableViewCell *)tableViewCell;
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:tableViewCell];
    if (indexPath) {
        STDTask *subtask = [self subtaskForIndexPath:indexPath];
        [self didCompleteSubtask:subtask];
    }
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
    
    UIEdgeInsets edgeInsets = self.tableView.contentInset;
    edgeInsets.bottom = MAX(0, [self contentOffsetForKeyboardFrame:newFrame]);
    self.tableView.contentInset = edgeInsets;
}

@end
