//
//  STDHomepageViewController.m
//  STD
//
//  Created by Lasha Efremidze on 5/25/14.
//  Copyright (c) 2014 Appoop Inc. All rights reserved.
//

#import "STDHomepageViewController.h"
#import "STDTaskDetailsTableViewCell.h"
#import "UIImage+Extras.h"

#import "STDSubtasksViewController.h"
#import "STDNotesViewController.h"

#define kButton 100

#define kTextFieldCategory 10

static NSString *kTextFieldPlaceholder = @"New Category";

@interface STDHomepageViewController () <UITableViewDataSource, UITableViewDelegate, STDTaskDetailsTableViewCellDelegate, UITextFieldDelegate, UIAlertViewDelegate>

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
        
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"New Task" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [alertView textFieldAtIndex:0];
    textField.tag = section;
    textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    [alertView show];
}

- (void)tapGestureRecognized:(UITapGestureRecognizer *)recognizer
{
    NSInteger section = recognizer.view.tag;
    STDCategory *category = [self categoryForSection:section];
    if (!self.expandedItems)
        self.expandedItems = [NSMutableArray array];
    if ([self.expandedItems containsObject:category]) {
        [self.expandedItems removeObject:category];
        for (STDTask *task in category.tasks) {
            [self.expandedItems removeObject:task];
        }
    } else  {
        [self.expandedItems addObject:category];
    }
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Styling

- (void)styleTableView
{
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
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

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.categories.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    STDCategory *category = [self categoryForSection:section];
    return [self.expandedItems containsObject:category] ? category.tasks.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STDTaskDetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([STDTaskDetailsTableViewCell class])];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.clipsToBounds = YES;

    cell.delegate = self;
    
    STDCategory *category = [self categoryForSection:indexPath.section];
    STDTask *task = [self sortedTasksForCategory:category][indexPath.row];

    cell.task = task;
    
    cell.textField.text = task.name;
    cell.textField.userInteractionEnabled = NO;

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    STDCategory *category = [self categoryForSection:indexPath.section];
    STDTask *task = [self sortedTasksForCategory:category][indexPath.row];
    if (!self.expandedItems)
        self.expandedItems = [NSMutableArray array];
    if ([self.expandedItems containsObject:task]) {
        [self.expandedItems removeObject:task];
    } else  {
        [self.expandedItems addObject:task];
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STDCategory *category = [self categoryForSection:indexPath.section];
    STDTask *task = [self sortedTasksForCategory:category][indexPath.row];
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
    textField.placeholder = kTextFieldPlaceholder;
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
    NSString *title = (count && ![self.expandedItems containsObject:category]) ? [NSString stringWithFormat:@"(%d)", count] : @"+";
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
    NSInteger section = textField.superview.tag;
    STDCategory *category = [self categoryForSection:section];
    if (category)
        return textField.text.length;
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (!textField.text.length)
        return;
    
    NSInteger section = textField.superview.tag;
    STDCategory *category = [self categoryForSection:section];
    if (!category) {
        category = [STDCategory createEntity];
        [self.categories addObject:category];
    }
    
    category.name = textField.text;
    
    [[NSManagedObjectContext contextForCurrentThread] saveOnlySelfAndWait];
    
    [self.tableView reloadData];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        if (textField.text.length) {
            NSInteger section = textField.tag;
            STDCategory *category = [self categoryForSection:section];
            if (category) {
                STDTask *task = [STDTask createEntity];
                task.name = textField.text;
                [category addTasksObject:task];
                
                [[NSManagedObjectContext contextForCurrentThread] saveOnlySelfAndWait];
                
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
    }
}

@end
