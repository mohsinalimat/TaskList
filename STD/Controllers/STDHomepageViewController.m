//
//  STDHomepageViewController.m
//  STD
//
//  Created by Lasha Efremidze on 5/25/14.
//  Copyright (c) 2014 Appoop Inc. All rights reserved.
//

#import "STDHomepageViewController.h"
#import "STDTaskDetailsTableViewCell.h"
#import "RATreeView.h"
#import "UIImage+Extras.h"

#import "STDSubtasksViewController.h"
#import "STDNotesViewController.h"

@interface STDHomepageViewController () <RATreeViewDataSource, RATreeViewDelegate, STDTaskDetailsTableViewCellDelegate>

@property (strong, nonatomic) RATreeView *treeView;

@property (strong, nonatomic) NSArray *categories;

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
    NSArray *categories = [STDCategory findAllSortedBy:NSStringFromSelector(@selector(index)) ascending:YES];
    if (!categories.count) {
        STDCategory *category1 = [STDCategory createEntity];
        category1.name = @"Home";
        
        STDCategory *category2 = [STDCategory createEntity];
        category2.name = @"Work";
        
        [[NSManagedObjectContext contextForCurrentThread] saveOnlySelfAndWait];
        
        categories = [STDCategory findAllSortedBy:NSStringFromSelector(@selector(index)) ascending:YES];
    }
    self.categories = categories;
}

- (NSArray *)sortedTasksForCategory:(STDCategory *)category
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(index)) ascending:YES];
    return [category.tasks sortedArrayUsingDescriptors:@[sortDescriptor]];
}

#pragma mark - RATreeView

- (RATreeView *)treeView
{
    if (!_treeView) {
        _treeView = [[RATreeView alloc] initWithFrame:self.view.bounds style:RATreeViewStyleGrouped];
        _treeView.delegate = self;
        _treeView.dataSource = self;
        _treeView.treeHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
        _treeView.treeFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _treeView.rowsExpandingAnimation = RATreeViewRowAnimationMiddle;
        _treeView.rowsCollapsingAnimation = RATreeViewRowAnimationMiddle;
        _treeView.separatorStyle = RATreeViewCellSeparatorStyleNone;
        [_treeView registerNib:[UINib nibWithNibName:NSStringFromClass([STDTaskDetailsTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([STDTaskDetailsTableViewCell class])];
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
    else if ([item isKindOfClass:[STDTask class]])
        return 1;
    return 0;
}

- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(id)item;
{
    if (!item)
        return self.categories[index];
    else if ([item isKindOfClass:[STDCategory class]])
        return [self sortedTasksForCategory:item][index];
    return [NSNull null];
}

- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo;
{
    static NSString *CellIdentifier = @"TableViewCellStyleDefault";
    UITableViewCell *cell = [treeView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    if ([item isKindOfClass:[NSNull class]]) {
        id parentItem = ((RATreeNodeInfo *)treeNodeInfo.parent).item;
        STDTask *task = (STDTask *)parentItem;

        STDTaskDetailsTableViewCell *cell = [treeView dequeueReusableCellWithIdentifier:NSStringFromClass([STDTaskDetailsTableViewCell class])];
        cell.delegate = self;
        cell.task = task;
        return cell;
    } else if ([item isKindOfClass:[STDCategory class]]) {
        STDCategory *category = (STDCategory *)item;
        cell.textLabel.text = [category.name uppercaseString];
    } else if ([item isKindOfClass:[STDTask class]]) {
        STDTask *task = (STDTask *)item;
        cell.textLabel.text = task.name;
    }
    
    UIButton *button = (UIButton *)cell.accessoryView;
    if (!button) {
        button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = (CGRect){0, 0, 44, 44};
        button.titleLabel.font = [UIFont systemFontOfSize:20.0f];
        button.tintColor = [UIColor blackColor];
        cell.accessoryView = button;
    }
    
    NSString *title = @"+";
    NSUInteger count = treeNodeInfo.children.count;
    if (count) title = [@(count) stringValue];
    [button setTitle:title forState:UIControlStateNormal];
    
    return cell;
}

- (BOOL)treeView:(RATreeView *)treeView canMoveRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo;
{
    if ([item isKindOfClass:[NSNull class]])
        return NO;
    
    [treeView collapseRowForItem:item];
    
    return YES;
}

- (void)treeView:(RATreeView *)treeView moveRowForItem:(id)sourceItem treeNodeInfo:(RATreeNodeInfo *)sourceTreeNodeInfo toRowForItem:(id)destinationItem treeNodeInfo:(RATreeNodeInfo *)destinationTreeNodeInfo
{
    if ([sourceItem isKindOfClass:[STDCategory class]]) {
        STDCategory *sourceCategory = (STDCategory *)sourceItem;
        STDCategory *destinationCategory = (STDCategory *)destinationItem;
        
        NSNumber *sourceCategoryIndex = sourceCategory.index;
        sourceCategory.index = destinationCategory.index;
        destinationCategory.index = sourceCategoryIndex;
        
        [[NSManagedObjectContext contextForCurrentThread] saveOnlySelfAndWait];
        
        self.categories = [STDCategory findAllSortedBy:NSStringFromSelector(@selector(index)) ascending:YES];
        
        [self.treeView reloadData];
    } else if ([sourceItem isKindOfClass:[STDTask class]]) {
        STDTask *sourceTask = (STDTask *)sourceItem;
        
        if ([destinationItem isKindOfClass:[STDCategory class]]) {
            STDCategory *destinationCategory = (STDCategory *)destinationItem;
            sourceTask.category = destinationCategory;
            sourceTask.indexValue = destinationCategory.tasks.count;
        } else if ([destinationItem isKindOfClass:[STDTask class]]) {
            STDTask *destinationTask = (STDTask *)destinationItem;
            if (![sourceTask.category.category_id isEqualToString:destinationTask.category.category_id])
                sourceTask.category = destinationTask.category;
            
            NSNumber *sourceTaskIndex = sourceTask.index;
            sourceTask.index = destinationTask.index;
            destinationTask.index = sourceTaskIndex;
        }
        
        [[NSManagedObjectContext contextForCurrentThread] saveOnlySelfAndWait];
        
        [self.treeView reloadData];
    }
}

#pragma mark - RATreeViewDelegate

- (NSInteger)treeView:(RATreeView *)treeView indentationLevelForRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo;
{
    return 2 * MIN(treeNodeInfo.treeDepthLevel, 1);
}

- (void)treeView:(RATreeView *)treeView didExpandRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo;
{
    if (!self.expandedItems)
        self.expandedItems = [NSMutableArray array];
    [self.expandedItems addObject:item];
    
    id lastItem = ((RATreeNodeInfo *)treeNodeInfo.children.lastObject).item;
    UITableViewCell *cell = [treeView cellForItem:lastItem];
    if (![[treeView visibleCells] containsObject:cell]) {
        [treeView scrollToRowForItem:lastItem atScrollPosition:RATreeViewScrollPositionBottom animated:YES];
    }
}

- (void)treeView:(RATreeView *)treeView didCollapseRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo;
{
    [self.expandedItems removeObject:item];
}

- (BOOL)treeView:(RATreeView *)treeView shouldItemBeExpandedAfterDataReload:(id)item treeDepthLevel:(NSInteger)treeDepthLevel;
{
    return [self.expandedItems containsObject:item];
}

- (id)treeView:(RATreeView *)treeView targetItemForMoveFromRowForItem:(id)sourceItem treeNodeInfo:(RATreeNodeInfo *)sourceTreeNodeInfo indexPath:(NSIndexPath *)sourceIndexPath toProposedRowForItem:(id)destinationItem treeNodeInfo:(RATreeNodeInfo *)destinationTreeNodeInfo indexPath:(NSIndexPath *)destinationIndexPath
{
    NSLog(@"sourceItem %@", [sourceItem class]);
    NSLog(@"destinationItem %@", [destinationItem class]);
    
    if ([sourceItem isKindOfClass:[STDCategory class]]) {
//        if ([destinationItem isKindOfClass:[STDCategory class]])
//            if (destinationTreeNodeInfo.expanded)
//                if (destinationTreeNodeInfo.children.count)
//                    return ((RATreeNodeInfo *)destinationTreeNodeInfo.children.lastObject).item;
        
        if ([destinationItem isKindOfClass:[STDTask class]])
            return destinationTreeNodeInfo.parent.item;
    } else if ([sourceItem isKindOfClass:[STDTask class]]) {
        if ([destinationItem isKindOfClass:[STDCategory class]]) {
            if (destinationTreeNodeInfo.children.count)
                if (!destinationTreeNodeInfo.expanded)
                    [treeView expandRowForItem:destinationItem];
            
            if (destinationIndexPath.row == 0)
                return sourceItem;
        }
    }
    
    return destinationItem;
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

@end
