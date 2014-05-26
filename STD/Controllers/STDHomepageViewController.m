//
//  STDHomepageViewController.m
//  STD
//
//  Created by Lasha Efremidze on 5/25/14.
//  Copyright (c) 2014 Appoop Inc. All rights reserved.
//

#import "STDHomepageViewController.h"
#import "RATreeView.h"

@interface STDHomepageViewController () <RATreeViewDataSource, RATreeViewDelegate>

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
    
    [self initSubviews];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [super viewWillDisappear:animated];
}

- (void)initSubviews
{
    RATreeView *treeView = [[RATreeView alloc] initWithFrame:self.view.bounds];
    treeView.delegate = self;
    treeView.dataSource = self;
    [self.view addSubview:treeView];
    [treeView reloadData];
}

#pragma mark - RATreeViewDataSource

//- (NSInteger)treeView:(RATreeView *)treeView numberOfChildrenOfItem:(id)item;
//{
//    
//}
//
//- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo;
//{
//    
//}
//
//- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(id)item;
//{
//    
//}

@end
