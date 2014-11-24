//
//  UITableViewCell+Strikethrough.h
//  STD
//
//  Created by Lasha Efremidze on 11/9/14.
//  Copyright (c) 2014 More Voltage. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StrikethroughTableViewCellDelegate <NSObject>

- (void)tableViewCell:(UITableViewCell *)tableViewCell strikethroughDidChange:(NSUInteger)length;
- (void)tableViewCell:(UITableViewCell *)tableViewCell strikethroughDidEndPanning:(NSUInteger)length;

@end

@interface UITableViewCell (Strikethrough)

@property (weak, nonatomic) id<StrikethroughTableViewCellDelegate> strikethroughDelegate;

@property (nonatomic, getter = isStrikethroughEnabled) BOOL strikethroughEnabled;

@end
