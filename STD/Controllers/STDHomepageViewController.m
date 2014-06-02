//
//  STDHomepageViewController.m
//  STD
//
//  Created by Lasha Efremidze on 5/25/14.
//  Copyright (c) 2014 Appoop Inc. All rights reserved.
//

#import "STDHomepageViewController.h"
#import "RATreeView.h"
#import "UIImage+Extras.h"

#import "STDSubtasksViewController.h"
#import "STDNotesViewController.h"

@interface STDHomepageViewController () <RATreeViewDataSource, RATreeViewDelegate>

@property (strong, nonatomic) RATreeView *treeView;

@property (strong, nonatomic) NSArray *categories;

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
    
    [self load];

    [self.treeView reloadRows];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [super viewWillDisappear:animated];
}

#pragma mark - Styling

- (void)styleNavigationController
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageFromColor:[UIColor colorWithWhite:1.0f alpha:0.8f]] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
}

#pragma mark - Load

- (void)load
{
//    // sample data
//    STDCategory *category = [STDCategory createEntity];
//    category.name = @"category";
//    STDTask *task = [STDTask createEntity];
//    task.name = @"task";
//    [category addTasksObject:task];
//    STDTask *task2 = [STDTask createEntity];
//    task2.name = @"task 2";
//    [category addTasksObject:task2];
//    STDTask *task3 = [STDTask createEntity];
//    task3.name = @"task 3";
//    [category addTasksObject:task3];
//    [category.managedObjectContext saveOnlySelfAndWait];
    
    self.categories = [STDCategory findAll];
}

#pragma mark - RATreeView

- (RATreeView *)treeView
{
    if (!_treeView) {
        _treeView = [[RATreeView alloc] initWithFrame:self.view.bounds];
        _treeView.contentInset = (UIEdgeInsets){[UIApplication sharedApplication].statusBarFrame.size.height, 0, 0, 0};
        _treeView.delegate = self;
        _treeView.dataSource = self;
        _treeView.treeHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
        _treeView.treeFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.view addSubview:_treeView];
    }
    return _treeView;
}

#pragma mark - RATreeViewDataSource

- (NSInteger)treeView:(RATreeView *)treeView numberOfChildrenOfItem:(id)item;
{
    if (!item)
        return self.categories.count;
    else if ([item isKindOfClass:[STDCategory class]])
        return ((STDCategory *)item).tasks.count;
//    else if ([item isKindOfClass:[STDTask class]])
//        return 1;
    return 0;
}

- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(id)item;
{
    if (!item)
        return self.categories[index];
    else if ([item isKindOfClass:[STDCategory class]])
        return ((STDCategory *)item).tasks.allObjects[index];
    return nil;
}

- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo;
{
    static NSString *CellIdentifier = @"TableViewCellStyleDefault";
    UITableViewCell *cell = [treeView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){0, 0, 20, 20}];
    label.text = [NSString stringWithFormat:@"%@", [@(treeNodeInfo.children.count) stringValue]];
    cell.accessoryView = label;
    
    if ([item isKindOfClass:[STDCategory class]]) {
        STDCategory *category = (STDCategory *)item;
        cell.textLabel.text = category.name;
    } else if ([item isKindOfClass:[STDTask class]]) {
        STDTask *task = (STDTask *)item;
        cell.textLabel.text = task.name;
    }
    
    return cell;
}

#pragma mark - RATreeViewDelegate

- (NSInteger)treeView:(RATreeView *)treeView indentationLevelForRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo;
{
    return 2 * treeNodeInfo.treeDepthLevel;
}

- (void)treeView:(RATreeView *)treeView didSelectRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo;
{
    [treeView deselectRowForItem:item animated:YES];
    
    if ([item isKindOfClass:[STDTask class]]) {
        STDTask *task = (STDTask *)item;
        
        STDNotesViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"STDNotesViewControllerId"];
        viewController.task = task;
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

@end
