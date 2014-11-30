//
//  STDHomepageViewController.m
//  STD
//
//  Created by Lasha Efremidze on 5/25/14.
//  Copyright (c) 2014 More Voltage Inc. All rights reserved.
//

#import "STDHomepageViewController.h"
#import "STDTaskTableViewCell.h"
#import "STDTaskTableViewHeaderFooterView.h"
#import "UIViewController+BHTKeyboardNotifications.h"
#import "NSObject+Extras.h"
#import "UITableView+LongPressReorder.h"
#import "PureLayout.h"

#import "STDSubtasksViewController.h"
#import "STDNotesViewController.h"
#import "STDSettingsViewController.h"

#define kTextFieldCategory 2000
#define kTextFieldTask 3000

#define kNumberOfSections self.categories.count + 1
#define kNumberOfRowsInSection [self countOfUncompletedTasksForCategory:category] + 1

static char kCategoryKey;
static char kTaskKey;

static char kBlockKey;

typedef NS_ENUM(NSInteger, UITableViewSectionAction) {
    UITableViewSectionActionExpand,
    UITableViewSectionActionCollapse
};

@interface STDHomepageViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, STDTaskTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) UIView *footerView;

@property (strong, nonatomic) NSMutableArray *categories;

@property (strong, nonatomic) NSMutableArray *expandedItems;

@property (strong, nonatomic) NSLayoutConstraint *heightLayoutConstraint;

@end

@implementation STDHomepageViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerForKeyboardNotifications];
    
    [self styleNavigationController];
    
    [self styleTableView];

    [self load];
    
    [self.tableView reloadData];
    
    [self footerView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.navigationController setToolbarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    [super viewWillDisappear:animated];
    
    [self.view endEditing:NO];
}

#pragma mark - IBActions

- (IBAction)didTouchOnUndoButton:(id)sender
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideFooterView) object:nil];
    
    [self hideFooterView];
    
    STDTask *task = [self associatedObjectForKey:&kTaskKey];
    if (task) {
        // core data
        task.completed = @NO;
        task.completion_date = nil;
        
        [[NSManagedObjectContext contextForCurrentThread] saveOnlySelfAndWait];
        
        NSIndexPath *indexPath = [self indexPathOfTask:task];
        
        // insert
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [self reloadHeaderViewForCategory:task.category];
    }
}

- (IBAction)didTouchOnSettingsButton:(id)sender
{
    STDSettingsViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"STDSettingsViewControllerId"];
    [self pushViewController:viewController];
}

- (IBAction)didTouchOnButton:(id)sender
{
    UIButton *button = sender;
    STDCategory *category = [button.superview associatedObjectForKey:&kCategoryKey];
    NSInteger section = [self sectionForCategory:category];
    if (category) {
        [self animateCategory:category withAction:UITableViewSectionActionExpand completion:^{
            STDTaskTableViewCell *cell = (STDTaskTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self countOfUncompletedTasksForCategory:category] inSection:section]];
            [cell.textField becomeFirstResponder];
        }];
    } else {
        STDTaskTableViewHeaderFooterView *view = (STDTaskTableViewHeaderFooterView *)[self.tableView headerViewForSection:section];
        [view.textField becomeFirstResponder];
    }
}

- (void)singleTapGestureRecognized:(UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
    
    STDCategory *category = [recognizer.view associatedObjectForKey:&kCategoryKey];
    [self toggleCategory:category];
}

- (void)doubleTapGestureRecognized:(UITapGestureRecognizer *)recognizer
{
    STDCategory *category = [recognizer.view associatedObjectForKey:&kCategoryKey];
    NSInteger section = [self sectionForCategory:category];
    STDTaskTableViewHeaderFooterView *view = (STDTaskTableViewHeaderFooterView *)[self.tableView headerViewForSection:section];
    view.textField.userInteractionEnabled = YES;
    [view.textField becomeFirstResponder];
}

- (void)pushViewController:(UIViewController *)viewController
{
    [self.navigationController setToolbarHidden:YES];
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)willCompleteTask:(STDTask *)task
{
    // check for uncompleted subtasks
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"completedValue == NO"];
    NSSet *uncompleted = [task.subtasks filteredSetUsingPredicate:predicate];
    if (uncompleted.count) {
        [UIAlertView showAlertViewWithMessage:@"Mark all subtasks complete? If yes, all subtasks will be marked as finished because you're done! If you choose keep, the task will still be viewable until you mark all subtasks completed." title:nil cancelButtonTitle:@"Keep" otherButtonTitles:@[@"Yes"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex != alertView.cancelButtonIndex) {
                for (STDSubtask *subtask in task.subtasks) {
                    subtask.completed = @YES;
                    subtask.completion_date = [NSDate date];
                }
                
                [[NSManagedObjectContext contextForCurrentThread] saveOnlySelfAndWait];
            }
            
            [self didCompleteTask:task];
        }];
    } else {
        [self didCompleteTask:task];
    }
}

- (void)didCompleteTask:(STDTask *)task
{
    [self setAssociatedObject:task forKey:&kTaskKey];

    NSIndexPath *indexPath = [self indexPathOfTask:task];

    // core data
    task.completed = @YES;
    task.completion_date = [NSDate date];
    
    [[NSManagedObjectContext contextForCurrentThread] saveOnlySelfAndWait];
    
    // delete row
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    [self reloadHeaderViewForCategory:task.category];

    [self showFooterView];
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
}

- (void)styleNavigationController
{
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"\u2699" style:UIBarButtonItemStylePlain target:self action:@selector(didTouchOnSettingsButton:)];
    [settingsButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:24.0]} forState:UIControlStateNormal];
    self.toolbarItems = @[settingsButton];
}

#pragma mark - Footer View

- (void)showFooterView
{
    self.heightLayoutConstraint.constant = 44.0f;
    
    [UIView animateWithDuration:1.0f delay:0 usingSpringWithDamping:0.5f initialSpringVelocity:0.5f options:(UIViewAnimationOptionAllowUserInteraction) animations:^{
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
        
        [_footerView autoPinEdgesToSuperviewEdgesWithInsets:(UIEdgeInsets){0, 0, 44.0f, 0} excludingEdge:ALEdgeTop];
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

- (NSSet *)uncompletedTasksForCategory:(STDCategory *)category
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"completedValue == NO"];
    return [category.tasks filteredSetUsingPredicate:predicate];
}

- (NSUInteger)countOfUncompletedTasksForCategory:(STDCategory *)category
{
    return [[self uncompletedTasksForCategory:category] count];
}

- (NSArray *)sortedUncompletedTasksForCategory:(STDCategory *)category
{
    return [self sortedArrayWithSet:[self uncompletedTasksForCategory:category]];
}

- (NSArray *)sortedArrayWithSet:(NSSet *)set
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(index)) ascending:YES];
    return [set sortedArrayUsingDescriptors:@[sortDescriptor]];
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

// TODO cache tasks for faster loading
- (STDTask *)taskForIndexPath:(NSIndexPath *)indexPath
{
    STDCategory *category = [self categoryForSection:indexPath.section];
    if (category) {
        NSArray *tasks = [self sortedUncompletedTasksForCategory:category];
        if (tasks.count > indexPath.row)
            return tasks[indexPath.row];
    }
    return nil;
}

- (STDTask *)nextTaskForIndexPath:(NSIndexPath *)indexPath
{
    STDCategory *category = [self categoryForSection:indexPath.section];
    if ((indexPath.row + 1) < [self countOfUncompletedTasksForCategory:category]) {
        NSArray *tasks = [self sortedUncompletedTasksForCategory:category];
        return tasks[indexPath.row + 1];
    } else if ((indexPath.section + 1) < self.categories.count) {
        NSInteger section = indexPath.section + 1;
        NSArray *categories = [self.categories subarrayWithRange:NSMakeRange(section, self.categories.count - section)];
        for (STDCategory *category in categories) {
            if ([self countOfUncompletedTasksForCategory:category]) {
                NSArray *tasks = [self sortedUncompletedTasksForCategory:category];
                return [tasks firstObject];
            }
        }
    }
    return nil;
}

- (STDTask *)previousTaskForIndexPath:(NSIndexPath *)indexPath
{
    STDCategory *category = [self categoryForSection:indexPath.section];
    if (indexPath.row > 0) {
        NSArray *tasks = [self sortedUncompletedTasksForCategory:category];
        NSInteger row = MIN(indexPath.row - 1, tasks.count - 1);
        return tasks[row];
    } else if (indexPath.section > 0) {
        NSInteger section = MIN(indexPath.section, self.categories.count);
        NSArray *categories = [[[self.categories reverseObjectEnumerator] allObjects] subarrayWithRange:NSMakeRange(self.categories.count - section, section)];
        for (STDCategory *category in categories) {
            if ([self countOfUncompletedTasksForCategory:category]) {
                NSArray *tasks = [self sortedUncompletedTasksForCategory:category];
                return [tasks lastObject];
            }
        }
    }
    return nil;
}

- (NSIndexPath *)indexPathOfTask:(STDTask *)task
{
    STDCategory *category = task.category;
    NSArray *tasks = [self sortedUncompletedTasksForCategory:category];
    return [NSIndexPath indexPathForRow:[tasks indexOfObject:task] inSection:[self.categories indexOfObject:category]];
}

- (void)updateIndexesForTasks:(NSArray *)tasks
{
    for (STDTask *task in tasks) {
        task.indexValue = [tasks indexOfObject:task];
    }
}

- (NSString *)taskCountStringForCategory:(STDCategory *)category
{
    if (category) {
        NSUInteger count = [self countOfUncompletedTasksForCategory:category];
        return (count ? [NSString stringWithFormat:@"%lu", (unsigned long)count] : @"+");
    }
    return nil;
}

- (void)reloadHeaderViewForCategory:(STDCategory *)category
{
    NSInteger section = [self sectionForCategory:category];
    STDTaskTableViewHeaderFooterView *view = (STDTaskTableViewHeaderFooterView *)[self.tableView headerViewForSection:section];
    [self reloadHeaderView:view forCategory:category];
}

- (void)reloadHeaderView:(STDTaskTableViewHeaderFooterView *)view forCategory:(STDCategory *)category
{
    NSString *title = [self taskCountStringForCategory:category];
    [view.button setTitle:title forState:UIControlStateNormal];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    STDCategory *category = [self categoryForSection:section];
    NSInteger numberOfRows = [self isCategoryExpanded:category] ? kNumberOfRowsInSection : 0;
    return numberOfRows + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STDTaskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([STDTaskTableViewCell class])];
    if (!cell) {
        cell = [[STDTaskTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([STDTaskTableViewCell class])];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.clipsToBounds = YES;
        
        cell.delegate = self;
        
        cell.textField.font = [UIFont systemFontOfSize:14.0f];
        cell.textField.placeholder = @"New Task";
        cell.textField.tag = kTextFieldTask;
        cell.textField.delegate = self;
    }
    
    STDTask *task = [self taskForIndexPath:indexPath];

    cell.task = task;
    
    cell.textField.userInteractionEnabled = !task;
    
    cell.textField.attributedText = nil;
    if (task.name) {
        cell.textField.attributedText = [[NSAttributedString alloc] initWithString:task.name attributes:@{NSFontAttributeName:cell.textField.font}];
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
    NSInteger numberOfRows = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    if (indexPath.row < (numberOfRows - 1)) {
        STDTask *task = [self taskForIndexPath:indexPath];
        return [self isTaskExpanded:task] ? 88.0f : 44.0f;
    }
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    STDTaskTableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([STDTaskTableViewHeaderFooterView class])];
    if (!view) {
        view = [[STDTaskTableViewHeaderFooterView alloc] initWithReuseIdentifier:NSStringFromClass([STDTaskTableViewHeaderFooterView class])];
        
        view.frame = (CGRect){0, 0, CGRectGetWidth(tableView.bounds), 44};
        view.contentView.backgroundColor = [UIColor whiteColor];
        
        view.textField.delegate = self;
        view.textField.tag = kTextFieldCategory;
        view.textField.placeholder = @"New Category";
        
        [view.button addTarget:self action:@selector(didTouchOnButton:) forControlEvents:UIControlEventTouchUpInside];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureRecognized:)];
        singleTap.numberOfTapsRequired = 1;
        [view addGestureRecognizer:singleTap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureRecognized:)];
        doubleTap.numberOfTapsRequired = 2;
        [view addGestureRecognizer:doubleTap];
        
        [singleTap requireGestureRecognizerToFail:doubleTap];
    }
    
    STDCategory *category = [self categoryForSection:section];
    
    [view setAssociatedObject:category forKey:&kCategoryKey];
    
    view.textField.text = [category.name uppercaseString];
    view.textField.userInteractionEnabled = !category;
    
    [self reloadHeaderView:view forCategory:category];
    
    return view;
}

#pragma mark - Reorder

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    STDTask *task = [self taskForIndexPath:indexPath];
    return (task != nil);
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    BOOL isSameCategory = (sourceIndexPath.section == destinationIndexPath.section);
    
    STDTask *sourceTask = [self taskForIndexPath:sourceIndexPath];
    
    STDCategory *sourceCategory = [self categoryForSection:sourceIndexPath.section];
    STDCategory *destinationCategory = [self categoryForSection:destinationIndexPath.section];
    
    [sourceCategory removeTasksObject:sourceTask];
    
    if (!isSameCategory) {
        NSArray *sourceTasks = [self sortedUncompletedTasksForCategory:sourceCategory];
        [self updateIndexesForTasks:sourceTasks];
    }
    
    NSMutableArray *destinationTasks = [NSMutableArray arrayWithArray:[self sortedUncompletedTasksForCategory:destinationCategory]];
    [destinationTasks insertObject:sourceTask atIndex:destinationIndexPath.row];
    destinationCategory.tasks = [NSSet setWithArray:destinationTasks];
    
    [self updateIndexesForTasks:destinationTasks];
    
    if (!isSameCategory) {
        [self reloadHeaderViewForCategory:sourceCategory];
        [self reloadHeaderViewForCategory:destinationCategory];
    }
    
    [[NSManagedObjectContext contextForCurrentThread] saveOnlySelfAndWait];
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    STDCategory *category = [self categoryForSection:proposedDestinationIndexPath.section];
    if (category) {
        if (![self isCategoryExpanded:category]) {
            [self animateCategory:category withAction:UITableViewSectionActionExpand completion:nil];
            return sourceIndexPath;
        }
        
        if (proposedDestinationIndexPath.row == 0)
            return proposedDestinationIndexPath;
        
        STDTask *task = [self taskForIndexPath:proposedDestinationIndexPath];
        if (!task) {
            if ([sourceIndexPath compare:proposedDestinationIndexPath] == NSOrderedDescending) {
                task = [self previousTaskForIndexPath:proposedDestinationIndexPath];
                if (!task) {
                    task = [self nextTaskForIndexPath:proposedDestinationIndexPath];
                }
            } else if ([sourceIndexPath compare:proposedDestinationIndexPath] == NSOrderedAscending) {
                task = [self nextTaskForIndexPath:proposedDestinationIndexPath];
                if (!task) {
                    task = [self previousTaskForIndexPath:proposedDestinationIndexPath];
                }
            }
        }
        
        if (task)
            return [self indexPathOfTask:task];
    }
    return sourceIndexPath;
}

#pragma mark - Expand/Collapse

- (void)toggleCategory:(STDCategory *)category
{
    UITableViewSectionAction action = ([self isCategoryExpanded:category] ? UITableViewSectionActionCollapse : UITableViewSectionActionExpand);
    [self animateCategory:category withAction:action completion:nil];
}

- (void)animateCategory:(STDCategory *)category withAction:(UITableViewSectionAction)action completion:(Block)completion
{
    BOOL expand = (action == UITableViewSectionActionExpand);
    BOOL collapse = (action == UITableViewSectionActionCollapse);
    
    NSUInteger section = [self sectionForCategory:category];
    
    NSMutableArray *indexes = [NSMutableArray array];
    for (NSInteger index = 0; index < kNumberOfRowsInSection; index++) {
        [indexes addObject:[NSIndexPath indexPathForRow:index inSection:section]];
    }
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        BOOL expanded = [self isCategoryExpanded:category];
        if (expanded && expand) {
            if (![[self.tableView indexPathsForVisibleRows] containsObject:indexes.lastObject]) {
                [self.tableView scrollToRowAtIndexPath:indexes.lastObject atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                [self setAssociatedObject:completion forKey:&kBlockKey];
                return;
            }
        }
        
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
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"class == %@", [task class]];
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

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    Block block = [self associatedObjectForKey:&kBlockKey];
    [self setAssociatedObject:nil forKey:&kBlockKey];
    if (block) block();
}

#pragma mark - STDTaskTableViewCellDelegate

- (void)taskTableViewCell:(STDTaskTableViewCell *)cell didTouchOnTasksButton:(id)sender
{
    STDSubtasksViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"STDSubtasksViewControllerId"];
    viewController.task = cell.task;
    [self pushViewController:viewController];
}

- (void)taskTableViewCell:(STDTaskTableViewCell *)cell didTouchOnNotesButton:(id)sender
{
    STDNotesViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"STDNotesViewControllerId"];
    viewController.task = cell.task;
    [self pushViewController:viewController];
}

- (void)didSwipeRight:(STDTaskTableViewCell *)cell
{
    [self willCompleteTask:cell.task];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldClear:(UITextField *)textField;
{
    if (textField.tag == kTextFieldCategory) {
        STDCategory *category = [textField.superview associatedObjectForKey:&kCategoryKey];
        if (category) {
            [UIAlertView showAlertViewWithMessage:@"Are you sure you want to delete this category? All associated tasks will be deleted." title:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Yes"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex != alertView.cancelButtonIndex) {
                    NSInteger section = [self sectionForCategory:category];
                    
                    [self.categories removeObject:category];
                    
                    [category deleteEntity];
                    
                    [[NSManagedObjectContext contextForCurrentThread] saveOnlySelfAndWait];
                    
                    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
                }
            }];
            
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

                if (indexPath.row == ([self.tableView numberOfRowsInSection:indexPath.section] - 2))
                    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
                
                [self.tableView endUpdates];
                
                [self reloadHeaderViewForCategory:category];
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

- (CGFloat)contentOffsetForKeyboardFrame:(CGRect)keyboardFrame
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIView *view = window.rootViewController.view;
    CGRect convertedRect = [view convertRect:keyboardFrame fromView:nil];
    CGFloat offset = CGRectGetHeight(view.frame) - CGRectGetMinY(convertedRect);
    return CGRectIsNull(convertedRect) ? 0 : offset;
}

- (CGFloat)toolbarHeight
{
    return self.navigationController.toolbarHidden ? 0.0f : 44.0f;
}

- (void)keyboardFrameChanged:(CGRect)newFrame
{
    if (CGRectIsNull(newFrame))
        return;
    
    UIEdgeInsets edgeInsets = self.tableView.contentInset;
    edgeInsets.bottom = MAX([self toolbarHeight], [self contentOffsetForKeyboardFrame:newFrame]);
    self.tableView.contentInset = edgeInsets;
}

@end
