//
//  STDHomepageViewController.m
//  STD
//
//  Created by Lasha Efremidze on 5/25/14.
//  Copyright (c) 2014 Appoop Inc. All rights reserved.
//

#import "STDHomepageViewController.h"
#import "STDTaskDetailsTableViewCell.h"
#import "UIViewController+BHTKeyboardNotifications.h"
#import "UIImage+Extras.h"

#import "STDSubtasksViewController.h"
#import "STDNotesViewController.h"

#define kButton 100

#define kTextFieldCategory 10
#define kTextFieldTask 20

#define kNumberOfRowsInSection category.tasks.count + 1

@interface STDHomepageViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, STDTaskDetailsTableViewCellDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

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

- (IBAction)didTouchOnButton:(id)sender
{
    UIButton *button = sender;
    NSInteger section = button.superview.tag;
}

- (void)tapGestureRecognized:(UITapGestureRecognizer *)recognizer
{
    NSInteger section = recognizer.view.tag;
    STDCategory *category = [self categoryForSection:section];
    
    NSMutableArray *indexes = [NSMutableArray array];
    for (NSInteger index = 0; index < kNumberOfRowsInSection; index++) {
        [indexes addObject:[NSIndexPath indexPathForRow:index inSection:section]];
    }
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        if ([self.expandedItems containsObject:category])
            if (![[self.tableView indexPathsForVisibleRows] containsObject:indexes.lastObject])
                [self.tableView scrollToRowAtIndexPath:indexes.lastObject atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }];
    
    [self.tableView beginUpdates];

    if (!self.expandedItems)
        self.expandedItems = [NSMutableArray array];
    if ([self.expandedItems containsObject:category]) {
        [self.expandedItems removeObject:category];
        
        [self.tableView deleteRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationFade];
    } else  {
        [self.expandedItems addObject:category];
        
        [self.tableView insertRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [self.tableView endUpdates];
    
    [CATransaction commit];
}

#pragma mark - Styling

- (void)styleTableView
{
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([STDTaskDetailsTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([STDTaskDetailsTableViewCell class])];
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
    return [self.expandedItems containsObject:category] ? kNumberOfRowsInSection : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STDTaskDetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([STDTaskDetailsTableViewCell class])];
    
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

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    STDTask *task = [self taskForIndexPath:indexPath];
    if (!task)
        return;
    
    if (!self.expandedItems)
        self.expandedItems = [NSMutableArray array];
    if ([self.expandedItems containsObject:task]) {
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
    return [self.expandedItems containsObject:task] ? 88.0f : 44.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    STDCategory *category = [self categoryForSection:section];
    
    UIView *view = [[UIView alloc] initWithFrame:(CGRect){0, 0, 320, 44}];
    view.backgroundColor = [UIColor whiteColor];
    view.tag = section;
    
    UITextField *textField = [[UITextField alloc] initWithFrame:(CGRect){14, 0, 276, 44}];
    textField.text = [category.name uppercaseString];
    textField.textColor = [UIColor colorWithHue:(210.0f / 360.0f) saturation:0.94f brightness:1.0f alpha:1.0f];
    textField.placeholder = @"New Category";
    textField.font = [UIFont boldSystemFontOfSize:18.0f];
    textField.userInteractionEnabled = !category;
    textField.delegate = self;
    textField.tag = kTextFieldCategory;
    [view addSubview:textField];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = (CGRect){276, 0, 44, 44};
    button.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    button.tintColor = [UIColor darkGrayColor];
    [button addTarget:self action:@selector(didTouchOnButton:) forControlEvents:UIControlEventTouchUpInside];
    NSUInteger count = category.tasks.count;
    NSString *title = (count ? [NSString stringWithFormat:@"(%d)", count] : @"+");
    [button setTitle:title forState:UIControlStateNormal];
    [view addSubview:button];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognized:)];
    singleTap.numberOfTapsRequired = 1;
    [view addGestureRecognizer:singleTap];
    
    return view;
}

#pragma mark - STDTaskDetailsTableViewCellDelegate

- (void)taskDetailsTableViewCell:(STDTaskDetailsTableViewCell *)cell didTouchOnTasksButton:(id)sender
{
    STDSubtasksViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"STDSubtasksViewControllerId"];
    viewController.task = cell.task;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)taskDetailsTableViewCell:(STDTaskDetailsTableViewCell *)cell didTouchOnNotesButton:(id)sender
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
        
        [self.tableView reloadData];
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
                
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
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
    edgeInsets.bottom = MAX(0.0f, contentOffsetForBottom(newFrame));
    self.tableView.contentInset = edgeInsets;
}

@end
