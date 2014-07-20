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
    
    [self load];

    [self.treeView reloadRows];
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

#pragma mark - RATreeView

- (RATreeView *)treeView
{
    if (!_treeView) {
        _treeView = [[RATreeView alloc] initWithFrame:self.view.bounds style:RATreeViewStyleGrouped];
        _treeView.delegate = self;
        _treeView.dataSource = self;
        _treeView.treeHeaderView = ({
            UIView *view = [[UIView alloc] initWithFrame:(CGRect){0, 0, 320, 44}];
            
            UITextField *textField = [[UITextField alloc] initWithFrame:(CGRect){0, 0, 320, 44}];
            [view addSubview:textField];
            
            UIView *bottomView = [[UIView alloc] initWithFrame:(CGRect){0, 43, 320, 1}];
            bottomView.backgroundColor = [UIColor colorWithWhite:0.6f alpha:1.0f];
            [view addSubview:bottomView];
            
            view;
        });
        _treeView.treeFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _treeView.rowsExpandingAnimation = RATreeViewRowAnimationMiddle;
        _treeView.rowsCollapsingAnimation = RATreeViewRowAnimationMiddle;
        _treeView.separatorStyle = RATreeViewCellSeparatorStyleNone;
        _treeView.contentInset = (UIEdgeInsets){-_treeView.treeHeaderView.frame.size.height, 0, 0, 0};
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
        
        BOOL isLastCategory = (self.categories.lastObject == item);
        // use textfield here and let user enter category
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
        [button addTarget:self action:@selector(didTouchOnAccessoryButton:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = button;
    }
    
    NSString *title = @"+";
    if (![self.expandedItems containsObject:item]) {
        NSUInteger count = treeNodeInfo.children.count;
        if (count) title = [@(count) stringValue];
    }
    [button setTitle:title forState:UIControlStateNormal];
    
    return cell;
}

- (BOOL)treeView:(RATreeView *)treeView canMoveRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo;
{
    if ([item isKindOfClass:[STDCategory class]])
        if (treeNodeInfo.expanded)
            [treeView collapseRowForItem:item];

    return ![item isKindOfClass:[NSNull class]];
}

- (void)treeView:(RATreeView *)treeView moveRowForItem:(id)sourceItem treeNodeInfo:(RATreeNodeInfo *)sourceTreeNodeInfo toRowForItem:(id)destinationItem treeNodeInfo:(RATreeNodeInfo *)destinationTreeNodeInfo
{
    NSLog(@"moveRowForItem sourceItem %@", [sourceItem class]);
    NSLog(@"moveRowForItem destinationItem %@", [destinationItem class]);
    
    if ([sourceItem isKindOfClass:[STDCategory class]] && [destinationItem isKindOfClass:[STDCategory class]]) {
        STDCategory *sourceCategory = (STDCategory *)sourceItem;
        STDCategory *destinationCategory = (STDCategory *)destinationItem;
        
        NSUInteger sourceCategoryIndex = [self.categories indexOfObject:sourceCategory];
        NSUInteger destinationCategoryIndex = [self.categories indexOfObject:destinationCategory];
        
        sourceCategory.indexValue = destinationCategoryIndex;
        destinationCategory.indexValue = sourceCategoryIndex;
        
        [[NSManagedObjectContext contextForCurrentThread] saveOnlySelfAndWait];
        
        [self.categories exchangeObjectAtIndex:sourceCategoryIndex withObjectAtIndex:destinationCategoryIndex];
        
        [self.treeView reloadData];
    }
    
//    if ([sourceItem isKindOfClass:[STDCategory class]])
//        if ([destinationItem isKindOfClass:[STDCategory class]])
//            if (![((STDCategory *)sourceItem).category_id isEqualToString:((STDCategory *)destinationItem).category_id])
//                if (destinationTreeNodeInfo.expanded) {
//                    [self.expandedItems removeObject:destinationItem];
//                    [treeView collapseRowForItem:destinationItem];
//                }
    
//    if ([sourceItem isKindOfClass:[STDTask class]]) {
//        STDTask *sourceTask = (STDTask *)sourceItem;
//        
//        if ([destinationItem isKindOfClass:[STDCategory class]]) {
//            STDCategory *destinationCategory = (STDCategory *)destinationItem;
//            sourceTask.category = destinationCategory;
//            sourceTask.indexValue = destinationCategory.tasks.count;
//        } else if ([destinationItem isKindOfClass:[STDTask class]]) {
//            STDTask *destinationTask = (STDTask *)destinationItem;
//            if (![sourceTask.category.category_id isEqualToString:destinationTask.category.category_id])
//                sourceTask.category = destinationTask.category;
//            
//            NSNumber *sourceTaskIndex = sourceTask.index;
//            sourceTask.index = destinationTask.index;
//            destinationTask.index = sourceTaskIndex;
//        }
//    }
    
    NSLog(@"sourceItem %@", sourceItem);
}

#pragma mark - RATreeViewDelegate

- (NSInteger)treeView:(RATreeView *)treeView indentationLevelForRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo;
{
    return 2 * MIN(treeNodeInfo.treeDepthLevel, 1);
}

- (void)treeView:(RATreeView *)treeView willExpandRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo;
{
    if (!self.expandedItems)
        self.expandedItems = [NSMutableArray array];
    [self.expandedItems addObject:item];
    
    [treeView reloadRowsForItems:@[item] withRowAnimation:RATreeViewRowAnimationNone];
}

- (void)treeView:(RATreeView *)treeView didExpandRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo;
{
    id lastItem = ((RATreeNodeInfo *)treeNodeInfo.children.lastObject).item;
    UITableViewCell *cell = [treeView cellForItem:lastItem];
    if (![[treeView visibleCells] containsObject:cell])
        [treeView scrollToRowForItem:lastItem atScrollPosition:RATreeViewScrollPositionBottom animated:YES];
}

- (void)treeView:(RATreeView *)treeView willCollapseRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo;
{
    [self.expandedItems removeObject:item];
    
    [treeView reloadRowsForItems:@[item] withRowAnimation:RATreeViewRowAnimationNone];
}

- (BOOL)treeView:(RATreeView *)treeView shouldItemBeExpandedAfterDataReload:(id)item treeDepthLevel:(NSInteger)treeDepthLevel;
{
    return [self.expandedItems containsObject:item];
}

- (id)treeView:(RATreeView *)treeView targetItemForMoveFromRowForItem:(id)sourceItem treeNodeInfo:(RATreeNodeInfo *)sourceTreeNodeInfo indexPath:(NSIndexPath *)sourceIndexPath toProposedRowForItem:(id)destinationItem treeNodeInfo:(RATreeNodeInfo *)destinationTreeNodeInfo indexPath:(NSIndexPath *)destinationIndexPath
{
    NSLog(@"targetItemForMoveFromRowForItem sourceItem %@", [sourceItem class]);
    NSLog(@"targetItemForMoveFromRowForItem destinationItem %@", [destinationItem class]);
    
//    if ([destinationItem isKindOfClass:[STDCategory class]])
//        if (destinationTreeNodeInfo.children.count)
//            if (!destinationTreeNodeInfo.expanded)
//                [treeView expandRowForItem:destinationItem];
    
//    // collapse expanded category
//    if ([sourceItem isKindOfClass:[STDTask class]])
//        if ([destinationItem isKindOfClass:[STDTask class]])
//            if (![((STDTask *)sourceItem).category.category_id isEqualToString:((STDTask *)destinationItem).category.category_id])
//                if (destinationTreeNodeInfo.parent.expanded)
//                    [treeView collapseRowForItem:destinationTreeNodeInfo.parent.item];
    
    // expand expanded category
    if ([sourceItem isKindOfClass:[STDCategory class]] && [destinationItem isKindOfClass:[STDTask class]]) {
        if (![((STDCategory *)sourceItem).category_id isEqualToString:((STDTask *)destinationItem).category.category_id]) {
            if (destinationTreeNodeInfo.parent.expanded) {
//                [self.expandedItems removeObject:destinationTreeNodeInfo.parent.item];
//                [treeView collapseRowForItem:destinationTreeNodeInfo.parent.item];
                return destinationTreeNodeInfo.parent.item;
            }
        }
    }
    
    return destinationIndexPath;
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
    CGPoint offset = self.treeView.contentOffset;
    
    CGFloat height = self.treeView.treeHeaderView.frame.size.height;
    if (offset.y <= (height / 2.0f)) {
        self.treeView.contentInset = UIEdgeInsetsZero;
    } else {
        self.treeView.contentInset = (UIEdgeInsets){-height, 0, 0, 0};
    }
    
    self.treeView.contentOffset = offset;
}

@end
