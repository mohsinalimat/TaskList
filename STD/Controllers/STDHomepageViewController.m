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
#import "BVReorderTableView.h"

#import "STDSubtasksViewController.h"
#import "STDNotesViewController.h"
#import "STDSettingsViewController.h"

#define kButton 1000
#define kTextFieldCategory 2000
#define kTextFieldTask 3000

#define kNumberOfRowsInSection category.tasks.count + 1

static CGFloat const kBottomInset = 44.0f;

typedef NS_ENUM(NSInteger, UITableViewSectionAction) {
    UITableViewSectionActionExpand,
    UITableViewSectionActionCollapse
};

@interface STDHomepageViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, STDTaskTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *categories;

@property (strong, nonatomic) NSMutableArray *expandedItems;

@property (strong, nonatomic) STDTask *dummyTask;

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
    NSInteger section = button.superview.tag;
    STDCategory *category = [self categoryForSection:section];
    if (category) {
        [self animateSection:section withAction:UITableViewSectionActionExpand completion:^{
            STDTaskTableViewCell *cell = (STDTaskTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:([self.tableView numberOfRowsInSection:section] - 1) inSection:section]];
            [cell.textField becomeFirstResponder];
        }];
    } else {
        UIView *view = [self.tableView headerViewForSection:section];
        UITextField *textField = (UITextField *)[view viewWithTag:kTextFieldCategory];
        [textField becomeFirstResponder];
    }
}

- (void)tapGestureRecognized:(UITapGestureRecognizer *)recognizer
{
    NSInteger section = recognizer.view.tag;
    [self toggleSection:section];
}

#pragma mark - Styling

- (void)styleTableView
{
    self.tableView.contentInset = (UIEdgeInsets){0, 0, kBottomInset, 0};
    
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([STDTaskTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([STDTaskTableViewCell class])];
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
        
//        STDTask *task1 = [STDTask createEntity];
//        task1.name = @"task1";
//        [category1 addTasksObject:task1];
//        
//        STDTask *task2 = [STDTask createEntity];
//        task2.name = @"task2";
//        [category2 addTasksObject:task2];
        
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
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.clipsToBounds = YES;

    cell.delegate = self;
    
    STDTask *task = [self taskForIndexPath:indexPath];

    cell.task = task;
    
    cell.textField.text = task.name;
    cell.textField.placeholder = @"New Task";
    cell.textField.userInteractionEnabled = !task;
    cell.textField.tag = kTextFieldTask;
    cell.textField.delegate = self;

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    STDTask *task = [self taskForIndexPath:indexPath];
    return (task != nil);
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    STDTask *task = [self taskForIndexPath:indexPath];
    if (!task)
        return;
    
    if (!self.expandedItems)
        self.expandedItems = [NSMutableArray array];
    if ([self isTaskExpanded:task]) {
        [self.expandedItems removeObject:task];
    } else  {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"class == %@", [STDTask class]];
        NSArray *tasks = [self.expandedItems filteredArrayUsingPredicate:predicate];
        [self.expandedItems removeObjectsInArray:tasks];

        [self.expandedItems addObject:task];
    }
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
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
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognized:)];
        singleTap.numberOfTapsRequired = 1;
        [headerFooterView addGestureRecognizer:singleTap];
    }
    
    headerFooterView.tag = section;
    
    STDCategory *category = [self categoryForSection:section];
    
    UITextField *textField = (UITextField *)[headerFooterView viewWithTag:kTextFieldCategory];
    if (!textField) {
        textField = [[UITextField alloc] initWithFrame:(CGRect){14, 0, 276, 44}];
        textField.textColor = [UIColor colorWithHue:(210.0f / 360.0f) saturation:0.94f brightness:1.0f alpha:1.0f];
        textField.placeholder = @"New Category";
        textField.font = [UIFont boldSystemFontOfSize:18.0f];
        textField.delegate = self;
        textField.tag = kTextFieldCategory;
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
    NSString *title = (count ? [NSString stringWithFormat:@"(%d)", count] : @"+");
    [button setTitle:title forState:UIControlStateNormal];
    
    return headerFooterView;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
//    //    if ([destinationItem isKindOfClass:[STDCategory class]])
//    //        if (destinationTreeNodeInfo.children.count)
//    //            if (!destinationTreeNodeInfo.expanded)
//    //                [treeView expandRowForItem:destinationItem];
//    
//    //    // collapse expanded category
//    //    if ([sourceItem isKindOfClass:[STDTask class]])
//    //        if ([destinationItem isKindOfClass:[STDTask class]])
//    //            if (![((STDTask *)sourceItem).category.category_id isEqualToString:((STDTask *)destinationItem).category.category_id])
//    //                if (destinationTreeNodeInfo.parent.expanded)
//    //                    [treeView collapseRowForItem:destinationTreeNodeInfo.parent.item];
//    
//    // expand expanded category
//    if ([sourceItem isKindOfClass:[STDCategory class]] && [destinationItem isKindOfClass:[STDTask class]]) {
//        if (![((STDCategory *)sourceItem).category_id isEqualToString:((STDTask *)destinationItem).category.category_id]) {
//            if (destinationTreeNodeInfo.parent.expanded) {
//                //                [self.expandedItems removeObject:destinationTreeNodeInfo.parent.item];
//                //                [treeView collapseRowForItem:destinationTreeNodeInfo.parent.item];
//                return destinationTreeNodeInfo.parent.item;
//            }
//        }
//    }
    
    STDTask *task = [self taskForIndexPath:proposedDestinationIndexPath];
    if (task)
        return proposedDestinationIndexPath;
    return sourceIndexPath;
}

#pragma mark - ReorderTableViewDelegate

// This method is called when starting the re-ording process. You insert a blank row object into your
// data source and return the object you want to save for later. This method is only called once.
- (id)saveObjectAndInsertBlankRowAtIndexPath:(NSIndexPath *)indexPath
{
    STDTask *task = [self taskForIndexPath:indexPath];
    STDCategory *category = task.category;
    
    if (!self.dummyTask)
        self.dummyTask = [STDTask createEntity];
    self.dummyTask.index = task.index;

    [category removeTasksObject:task];
    [category addTasksObject:self.dummyTask];
    
    return task;
}

// This method is called when the selected row is dragged to a new position. You simply update your
// data source to reflect that the rows have switched places. This can be called multiple times
// during the reordering process.
- (void)moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    STDTask *sourceTask = [self taskForIndexPath:fromIndexPath];
    STDCategory *sourceCategory = sourceTask.category;

    [sourceCategory removeTasksObject:sourceTask];

    STDTask *destinationTask = [self taskForIndexPath:toIndexPath];
    STDCategory *destinationCategory = destinationTask.category;

    sourceTask.index = destinationTask.index;
    
    [destinationCategory addTasksObject:sourceTask];
    
//    STDTask *sourceTask = [self taskForIndexPath:fromIndexPath];
//    STDTask *destinationTask = [self taskForIndexPath:toIndexPath];
//    if (sourceTask.category != destinationTask.category) {
//        STDCategory *category = sourceTask.category;
//        sourceTask.category = destinationTask.category;
//        destinationTask.category = category;
//    }
//    
//    NSNumber *index = sourceTask.index;
//    sourceTask.index = destinationTask.index;
//    destinationTask.index = index;
//
//    [[NSManagedObjectContext contextForCurrentThread] saveOnlySelfAndWait];
}

// This method is called when the selected row is released to its new position. The object is the same
// object you returned in saveObjectAndInsertBlankRowAtIndexPath:. Simply update the data source so the
// object is in its new position. You should do any saving/cleanup here.
- (void)finishReorderingWithObject:(id)object atIndexPath:(NSIndexPath *)indexPath;
{
//    [section replaceObjectAtIndex:indexPath.row withObject:object];
    // do any additional cleanup here
}

#pragma mark - Expand/Collapse

- (void)toggleSection:(NSInteger)section
{
    STDCategory *category = [self categoryForSection:section];
    UITableViewSectionAction action = ([self isCategoryExpanded:category] ? UITableViewSectionActionCollapse : UITableViewSectionActionExpand);
    [self animateSection:section withAction:action completion:nil];
}

- (void)animateSection:(NSInteger)section withAction:(UITableViewSectionAction)action completion:(void (^)(void))completion
{
    BOOL expand = (action == UITableViewSectionActionExpand);
    BOOL collapse = (action == UITableViewSectionActionCollapse);
    
    STDCategory *category = [self categoryForSection:section];
    
    NSMutableArray *indexes = [NSMutableArray array];
    for (NSInteger index = 0; index < kNumberOfRowsInSection; index++) {
        [indexes addObject:[NSIndexPath indexPathForRow:index inSection:section]];
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

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField.tag == kTextFieldCategory) {
        NSInteger section = textField.superview.tag;
        STDCategory *category = [self categoryForSection:section];
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
        NSInteger section = textField.superview.tag;
        STDCategory *category = [self categoryForSection:section];
        if (!category) {
            category = [STDCategory createEntity];
            [self.categories addObject:category];
        }
        
        category.name = textField.text;
        
        [[NSManagedObjectContext contextForCurrentThread] saveOnlySelfAndWait];
        
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
