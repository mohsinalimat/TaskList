//
//  UITableViewCell+Strikethrough.h
//  STD
//
//  Created by Lasha Efremidze on 11/27/14.
//  Copyright (c) 2014 More Voltage. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol STDTableViewCellStrikethroughDelegate <NSObject>

@required

- (void)setAttributedText:(NSAttributedString *)attributedText forTableViewCell:(UITableViewCell *)tableViewCell;
- (NSAttributedString *)attributedTextForTableViewCell:(UITableViewCell *)tableViewCell;

@optional

- (void)strikethroughGestureDidEnd:(UITableViewCell *)tableViewCell;

@end

@interface UITableViewCell (Strikethrough)

@property (weak, nonatomic) id<STDTableViewCellStrikethroughDelegate> strikethroughDelegate;

@end
