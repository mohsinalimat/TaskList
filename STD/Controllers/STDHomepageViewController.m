//
//  STDHomepageViewController.m
//  STD
//
//  Created by Lasha Efremidze on 5/25/14.
//  Copyright (c) 2014 Appoop Inc. All rights reserved.
//

#import "STDHomepageViewController.h"
#import "STDTaskTableViewCell.h"
#import "UIViewController+BHTKeyboardNotifications.h"
#import "UIImage+Extras.h"
#import "NSObject+Extras.h"
#import "UITableView+LongPressReorder.h"

#import "STDSubtasksViewController.h"
#import "STDNotesViewController.h"
#import "STDSettingsViewController.h"

#define kButton 1000
#define kTextFieldCategory 2000
#define kTextFieldTask 3000

#define kAlertViewCompleteSubtasks 100
#define kAlertViewDeleteCategory 200

#define kNumberOfRowsInSection category.tasks.count + 1

static CGFloat const kBottomInset = 44.0f;

static char kCategoryKey;
static char kTaskKey;

typedef NS_ENUM(NSInteger, UITableViewSectionAction) {
    UITableViewSectionActionExpand,
    UITableViewSectionActionCollapse
};

@interface STDHomepageViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIAlertViewDelegate, STDTaskTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *categories;

@property (strong, nonatomic) NSMutableArray *expandedItems;

@end

@implementation STDHomepageViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerForKeyboardNotifications];
    
    [self styleNavigationController];
    
    [self styleTableView];

    [self load];
    
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [super viewWillDisappear:animated];
}

#pragma mark - IBAction

- (IBAction)didTouchOnSettingsButton:(id)sender
{
    STDSettingsViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"STDSettingsViewControllerId"];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)didTouchOnButton:(id)sender
{
    UIButton *button = sender;
    STDCategory *category = [button.superview associatedObjectForKey:&kCategoryKey];
    NSInteger section = [self sectionForCategory:category];
    if (category) {
        [self animateCategory:category withAction:UITableViewSectionActionExpand completion:^{
            STDTaskTableViewCell *cell = (STDTaskTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:category.tasks.count inSection:section]];
            [cell.textField becomeFirstResponder];
        }];
    } else {
        UIView *view = [self.tableView headerViewForSection:section];
        UITextField *textField = (UITextField *)[view viewWithTag:kTextFieldCategory];
        [textField becomeFirstResponder];
    }
}

- (void)singleTapGestureRecognized:(UITapGestureRecognizer *)recognizer
{
    STDCategory *category = [recognizer.view associatedObjectForKey:&kCategoryKey];
    [self toggleCategory:category];
}

- (void)doubleTapGestureRecognized:(UITapGestureRecognizer *)recognizer
{
    STDCategory *category = [recognizer.view associatedObjectForKey:&kCategoryKey];
    NSInteger section = [self sectionForCategory:category];
    UIView *view = [self.tableView headerViewForSection:section];
    UITextField *textField = (UITextField *)[view viewWithTag:kTextFieldCategory];
    textField.userInteractionEnabled = YES;
    [textField becomeFirstResponder];
}

#pragma mark - Styling

- (void)styleTableView
{
    self.tableView.contentInset = (UIEdgeInsets){0, 0, kBottomInset, 0};
    
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    self.tableView.longPressReorderEnabled = YES;
    self.tableView.lprDelegate = (id)self;
}

- (void)styleNavigationController
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageFromColor:[UIColor colorWithWhite:1.0f alpha:0.8f]] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
}

#pragma mark - Load

- (void)load
{
    NSArray *categories = [STDCategory findAllSortedBy:NSStringFromSelector(@selector(index)) ascending:YES];
    if (!categories.count) {
        STDCategory *category1 = [STDCategory createEntity];
        category1.name = @"Home";
        category1.indexValue = 0;
        
        STDCategory *category2 = [STDCategory createEntity];
        category2.name = @"Work";
        category2.indexValue = 1;
        
        [[NSManagedObjectContext contextForCurrentThread] saveOnlySelfAndWait];
        
        categories = [STDCategory findAllSortedBy:NSStringFromSelector(@selector(index)) ascending:YES];
    }
    self.categories = [NSMutableArray arrayWithArray:categories];
}

- (NSArray *)sortedTasksForCategory:(STDCategory *)category
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(index)) ascending:YES];
    return [category.tasks sortedArrayUsingDescriptors:@[sortDescriptor]];
}

- (STDCategory *)categoryForSection:(NSInteger)section
{
    if (self.categories.count > section)
        return self.categories[section];
    return nil;
}

- (NSUInteger)sectionForCategory:(STDCategory *)category
{
    return [self.categories indexOfObject:category];
}

- (STDTask *)taskForIndexPath:(NSIndexPath *)indexPath
{
    STDCategory *category = [self categoryForSection:indexPath.section];
    if (category) {
        NSArray *tasks = [self sortedTasksForCategory:category];
        if (tasks.count > indexPath.row)
            return tasks[indexPath.row];
    }
    return nil;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.categories.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    STDCategory *category = [self categoryForSection:section];
    return [self isCategoryExpanded:category] ? kNumberOfRowsInSection : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STDTaskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([STDTaskTableViewCell class])];
    if (!cell) {
        cell = (STDTaskTableViewCell *)[[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([STDTaskTableViewCell class]) owner:self options:nil] firstObject];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.clipsToBounds = YES;
        
        cell.delegate = self;
        
        cell.textField.placeholder = @"New Task";
        cell.textField.tag = kTextFieldTask;
        cell.textField.delegate = self;
    }
    
    STDTask *task = [self taskForIndexPath:indexPath];

    cell.task = task;
    
    cell.textField.text = task.name;
    cell.textField.userInteractionEnabled = !task;
    
    if (task) {
        [cell setDefaultColor:[UIColor lightGrayColor]];

        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check.png"]];
        imageView.contentMode = UIViewContentModeCenter;

        UIColor *greenColor = [UIColor colorWithRed:85.0 / 255.0 green:213.0 / 255.0 blue:80.0 / 255.0 alpha:1.0];
        
        // Adding gestures per state basis.
        [cell setSwipeGestureWithView:imageView color:greenColor mode:MCSwipeTableViewCellModeSwitch state:(MCSwipeTableViewCellState1 | MCSwipeTableViewCellState3) completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
            NSLog(@"Did swipe \"Checkmark\" cell");
            
            STDTask *task = ((STDTaskTableViewCell *)cell).task;
            
            task.completed = @YES;
            task.completion_date = [NSDate date];
            
            [[NSManagedObjectContext contextForCurrentThread] saveOnlySelfAndWait];
            
            // check for uncompleted subtasks
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"completedValue == NO"];
            NSSet *uncompleted = [task.subtasks filteredSetUsingPredicate:predicate];
            if (uncompleted.count) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Mark all subtasks complete? If yes, all subtasks will be marked as finished because you're done! If you choose keep, the task will still be viewable until you mark all subtasks completed." delegate:self cancelButtonTitle:@"Keep" otherButtonTitles:@"Yes", nil];
                alertView.tag = kAlertViewCompleteSubtasks;
                [alertView show];
                
                [self setAssociatedObject:task forKey:&kTaskKey];
            }
        }];
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    STDTask *task = [self taskForIndexPath:indexPath];
    if (!task)
        return;
    
    [self toggleTask:task];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STDTask *task = [self taskForIndexPath:indexPath];
    return [self isTaskExpanded:task] ? 88.0f : 44.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *CellIdentifier = @"HeaderFooterView";
    UITableViewHeaderFooterView *headerFooterView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:CellIdentifier];
    if (!headerFooterView) {
        headerFooterView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:CellIdentifier];

        headerFooterView.frame = (CGRect){0, 0, 320, 44};
        headerFooterView.contentView.backgroundColor = [UIColor whiteColor];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureRecognized:)];
        singleTap.numberOfTapsRequired = 1;
        [headerFooterView addGestureRecognizer:singleTap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureRecognized:)];
        doubleTap.numberOfTapsRequired = 2;
        [headerFooterView addGestureRecognizer:doubleTap];
        
        [singleTap requireGestureRecognizerToFail:doubleTap];
    }
    
    STDCategory *category = [self categoryForSection:section];
    
    [headerFooterView setAssociatedObject:category forKey:&kCategoryKey];
    
    UITextField *textField = (UITextField *)[headerFooterView viewWithTag:kTextFieldCategory];
    if (!textField) {
        textField = [[UITextField alloc] initWithFrame:(CGRect){14, 0, 276, 44}];
        textField.textColor = [UIColor colorWithHue:(210.0f / 360.0f) saturation:0.94f brightness:1.0f alpha:1.0f];
        textField.placeholder = @"New Category";
        textField.font = [UIFont boldSystemFontOfSize:18.0f];
        textField.delegate = self;
        textField.tag = kTextFieldCategory;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
        [headerFooterView addSubview:textField];
    }
    
    textField.text = [category.name uppercaseString];
    textField.userInteractionEnabled = !category;
    
    UIButton *button = (UIButton *)[headerFooterView viewWithTag:kButton];
    if (!button) {
        button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = (CGRect){276, 0, 44, 44};
        button.titleLabel.font = [UIFont systemFontOfSize:18.0f];
        button.tintColor = [UIColor darkGrayColor];
        [button addTarget:self action:@selector(didTouchOnButton:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = kButton;
        [headerFooterView addSubview:button];
    }
    
    NSUInteger count = category.tasks.count;
    NSString *title = (count ? [NSString stringWithFormat:@"%d", count] : @"+");
    [button setTitle:title forState:UIControlStateNormal];
    
    return headerFooterView;
}

#pragma mark

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    STDTask *task = [self taskForIndexPath:indexPath];
    return (task != nil);
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    STDTask *sourceTask = [self taskForIndexPath:sourceIndexPath];
    
    STDTask *destinationTask = [self taskForIndexPath:destinationIndexPath];
    STDCategory *destinationCategory = destinationTask.category;
    
    sourceTask.category = destinationCategory;
    
    sourceTask.indexValue = destinationIndexPath.row;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    STDTask *task = [self taskForIndexPath:proposedDestinationIndexPath];
    if (task)
        return proposedDestinationIndexPath;
    
    return sourceIndexPath;
}

#pragma mark - Expand/Collapse

- (void)toggleCategory:(STDCategory *)category
{
    UITableViewSectionAction action = ([self isCategoryExpanded:category] ? UITableViewSectionActionCollapse : UITableViewSectionActionExpand);
    [self animateCategory:category withAction:action completion:nil];
}

- (void)animateCategory:(STDCategory *)category withAction:(UITableViewSectionAction)action completion:(void (^)(void))completion
{
    BOOL expand = (action == UITableViewSectionActionExpand);
    BOOL collapse = (action == UITableViewSectionActionCollapse);
    
    NSMutableArray *indexes = [NSMutableArray array];
    for (NSInteger index = 0; index < kNumberOfRowsInSection; index++) {
        [indexes addObject:[NSIndexPath indexPathForRow:index inSection:[self sectionForCategory:category]]];
    }
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        if ([self isCategoryExpanded:category] && expand)
            if (![[self.tableView indexPathsForVisibleRows] containsObject:indexes.lastObject])
                [self.tableView scrollToRowAtIndexPath:indexes.lastObject atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
        if (completion)
            completion();
    }];
    
    [self.tableView beginUpdates];
    
    if (!self.expandedItems)
        self.expandedItems = [NSMutableArray array];
    BOOL expanded = [self isCategoryExpanded:category];
    if (expanded && collapse) {
        [self.expandedItems removeObject:category];
        
        [self.tableView deleteRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationFade];
    } else if (!expanded && expand) {
        [self.expandedItems addObject:category];
        
        [self.tableView insertRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [self.tableView endUpdates];
    
    [CATransaction commit];
}

- (void)toggleTask:(STDTask *)task
{
    [self.tableView beginUpdates];

    if (!self.expandedItems)
        self.expandedItems = [NSMutableArray array];
    BOOL expanded = [self isTaskExpanded:task];
    if (expanded) {
        [self.expandedItems removeObject:task];
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"class == %@", [STDTask class]];
        NSArray *tasks = [self.expandedItems filteredArrayUsingPredicate:predicate];
        [self.expandedItems removeObjectsInArray:tasks];
        
        [self.expandedItems addObject:task];
    }
    
    [self.tableView endUpdates];
}

- (BOOL)isCategoryExpanded:(STDCategory *)category
{
    return [self.expandedItems containsObject:category];
}

- (BOOL)isTaskExpanded:(STDTask *)task
{
    return [self.expandedItems containsObject:task];
}

#pragma mark - STDTaskTableViewCellDelegate

- (void)taskDetailsTableViewCell:(STDTaskTableViewCell *)cell didTouchOnTasksButton:(id)sender
{
    STDSubtasksViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"STDSubtasksViewControllerId"];
    viewController.task = cell.task;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)taskDetailsTableViewCell:(STDTaskTableViewCell *)cell didTouchOnNotesButton:(id)sender
{
    STDNotesViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"STDNotesViewControllerId"];
    viewController.task = cell.task;
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kAlertViewCompleteSubtasks) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            STDTask *task = [self associatedObjectForKey:&kTaskKey];
            
            for (STDSubtask *subtask in task.subtasks) {
                subtask.completed = @YES;
                subtask.completion_date = [NSDate date];
            }
            
            [[NSManagedObjectContext contextForCurrentThread] saveOnlySelfAndWait];
        }
    } else if (alertView.tag == kAlertViewDeleteCategory) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            STDCategory *category = [self associatedObjectForKey:&kCategoryKey];
            
            NSInteger section = [self sectionForCategory:category];
            
            [self.categories removeObject:category];

            [category deleteEntity];
            
            [[NSManagedObjectContext contextForCurrentThread] saveOnlySelfAndWait];
            
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldClear:(UITextField *)textField;
{
    if (textField.tag == kTextFieldCategory) {
        STDCategory *category = [textField.superview associatedObjectForKey:&kCategoryKey];
        if (category) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure you want to delete this category? All associated tasks will be deleted." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
            alertView.tag = kAlertViewDeleteCategory;
            [alertView show];
            
            [self setAssociatedObject:category forKey:&kCategoryKey];
            
            [textField resignFirstResponder];

            return NO;
        }
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField.tag == kTextFieldCategory) {
        STDCategory *category = [textField.superview associatedObjectForKey:&kCategoryKey];
        if (category)
            return textField.text.length;
    } else if (textField.tag == kTextFieldTask) {
        CGPoint hitPoint = [textField convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:hitPoint];
        if (indexPath) {
            STDTask *task = [self taskForIndexPath:indexPath];
            if (task)
                return textField.text.length;
        }
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (!textField.text.length)
        return;
    
    if (textField.tag == kTextFieldCategory) {
        STDCategory *category = [textField.superview associatedObjectForKey:&kCategoryKey];
        if (!category) {
            category = [STDCategory createEntity];
            [self.categories addObject:category];
        }
        
        category.name = textField.text;
        
        [[NSManagedObjectContext contextForCurrentThread] saveOnlySelfAndWait];
        
        NSUInteger section = [self sectionForCategory:category];
        
        [self.tableView beginUpdates];

        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
        
        if (section == ([self.tableView numberOfSections] - 1))
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:section + 1] withRowAnimation:UITableViewRowAnimationFade];
        
        [self.tableView endUpdates];
    } else if (textField.tag == kTextFieldTask) {
        CGPoint hitPoint = [textField convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:hitPoint];
        if (indexPath) {
            STDCategory *category = [self categoryForSection:indexPath.section];
            if (category) {
                STDTask *task = [self taskForIndexPath:indexPath];
                if (!task) {
                    task = [STDTask createEntity];
                    [category addTasksObject:task];
                }
                
                task.name = textField.text;
                
                [[NSManagedObjectContext contextForCurrentThread] saveOnlySelfAndWait];
                
                [self.tableView beginUpdates];
                
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];

                if (indexPath.row == ([self.tableView numberOfRowsInSection:indexPath.section] - 1))
                    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
                
                [self.tableView endUpdates];
            }
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag == kTextFieldCategory) {
        NSRange lowercaseRange = [string rangeOfCharacterFromSet:[NSCharacterSet lowercaseLetterCharacterSet]];
        if (lowercaseRange.location != NSNotFound) {
            textField.text = [textField.text stringByReplacingCharactersInRange:range withString:[string uppercaseString]];
            return NO;
        }
    }
    return YES;
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
    edgeInsets.bottom = MAX(kBottomInset, contentOffsetForBottom(newFrame));
    self.tableView.contentInset = edgeInsets;
}

@end
