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

@interface STDHomepageViewController () <UITableViewDataSource, UITableViewDelegate, STDTaskDetailsTableViewCellDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *categories;

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
    
    [self styleViewController];
    
    [self styleNavigationController];
    
    [self load];
    
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [super viewWillDisappear:animated];
}

#pragma mark - IBAction

- (IBAction)didTouchOnAccessoryButton:(id)sender
{
    
}

#pragma mark - Styling

- (void)styleViewController
{
    self.tableView.tableHeaderView = ({
        UIView *view = [[UIView alloc] initWithFrame:(CGRect){0, 0, 320, 44}];
        
        UITextField *textField = [[UITextField alloc] initWithFrame:(CGRect){14, 0, 298, 44}];
        [view addSubview:textField];
        
        UIView *bottomView = [[UIView alloc] initWithFrame:(CGRect){0, 43, 320, 1}];
        bottomView.backgroundColor = [UIColor colorWithWhite:0.6f alpha:1.0f];
        [view addSubview:bottomView];
        
        view;
    });
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = (UIEdgeInsets){-self.tableView.tableHeaderView.frame.size.height, 0, 0, 0};
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
        
        STDCategory *category3 = [STDCategory createEntity];
        category3.name = @"New Category";
        category3.indexValue = 2;
        
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

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.categories.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    STDCategory *category = self.categories[section];
    return category.tasks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TableViewCellStyleDefault";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    STDCategory *category = self.categories[indexPath.section];
    STDTask *task = [self sortedTasksForCategory:category][indexPath.row];
    cell.textLabel.text = task.name;
    
    UIButton *button = (UIButton *)cell.accessoryView;
    if (!button) {
        button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = (CGRect){0, 0, 44, 44};
        button.titleLabel.font = [UIFont systemFontOfSize:20.0f];
        button.tintColor = [UIColor blackColor];
        [button addTarget:self action:@selector(didTouchOnAccessoryButton:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = button;
    }
    
    NSString *title = @"+";
    NSUInteger count = task.subtasks.count;
    if (count) title = [@(count) stringValue];
    [button setTitle:title forState:UIControlStateNormal];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    STDCategory *category = self.categories[section];

    UIView *view = [[UIView alloc] initWithFrame:(CGRect){0, 0, 320, 44}];
    
    UITextField *textField = [[UITextField alloc] initWithFrame:(CGRect){14, 0, 298, 44}];
    textField.text = [category.name uppercaseString];
    [view addSubview:textField];
    
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

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGPoint offset = self.tableView.contentOffset;
    
    CGFloat height = self.tableView.tableHeaderView.frame.size.height;
    if (offset.y <= (height / 2.0f)) {
        self.tableView.contentInset = UIEdgeInsetsZero;
    } else {
        self.tableView.contentInset = (UIEdgeInsets){-height, 0, 0, 0};
    }
    
    self.tableView.contentOffset = offset;
}

@end
