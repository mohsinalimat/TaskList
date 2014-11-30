//
//  UITableView+Separator.m
//  STD
//
//  Created by Lasha Efremidze on 9/23/14.
//  Copyright (c) 2014 More Voltage Inc. All rights reserved.
//

#import "UITableView+Separator.h"
#import "JRSwizzle.h"
#import <objc/runtime.h>

@implementation UITableView (Separator)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error = nil;
        [[self class] jr_swizzleMethod:@selector(layoutSubviews) withMethod:@selector(xxx_layoutSubviews) error:&error];
        [[self class] jr_swizzleMethod:@selector(setDelegate:) withMethod:@selector(xxx_setDelegate:) error:&error];
        if (error) NSLog(@"jr_swizzleMethod Error: %@", error);
    });
}

#pragma mark - Method Swizzling

- (void)xxx_layoutSubviews
{
    if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
        [self setLayoutMargins:self.separatorInset];
    }
    
    [self xxx_layoutSubviews];
}

- (void)xxx_setDelegate:(id<UITableViewDelegate>)delegate
{
    Class class = [delegate class];
    
    SEL selector = @selector(tableView:willDisplayCell:forRowAtIndexPath:);
    
    typedef void (*customIMP)(id, SEL, UITableView *tableView, UITableViewCell *cell, NSIndexPath *indexPath);
    
    __block customIMP implementation = (customIMP)class_replaceMethodWithBlock(class, selector, ^(id _self, UITableView *tableView, UITableViewCell *cell, NSIndexPath *indexPath) {
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:tableView.separatorInset];
        }
        
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:tableView.separatorInset];
        }
        
        if (implementation) {
            implementation(_self, selector, tableView, cell, indexPath);
        }
    });
    
    [self xxx_setDelegate:delegate];
}

#pragma mark - Helpers

IMP class_replaceMethodWithBlock(Class class, SEL originalSelector, id block) {
    IMP newImplementation = imp_implementationWithBlock(block);
    Method method = class_getInstanceMethod(class, originalSelector);
    return class_replaceMethod(class, originalSelector, newImplementation, method_getTypeEncoding(method));
}

@end
