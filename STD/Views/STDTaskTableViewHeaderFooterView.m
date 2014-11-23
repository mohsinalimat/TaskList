//
//  STDTaskTableViewHeaderFooterView.m
//  STD
//
//  Created by Lasha Efremidze on 11/9/14.
//  Copyright (c) 2014 More Voltage. All rights reserved.
//

#import "STDTaskTableViewHeaderFooterView.h"

@implementation STDTaskTableViewHeaderFooterView

- (UITextField *)textField
{
    if (!_textField) {
        _textField = [[UITextField alloc] initWithFrame:(CGRect){14, 0, CGRectGetWidth(self.bounds) - 44 - 7, 44}];
        _textField.textColor = [UIColor colorWithHue:(210.0f / 360.0f) saturation:0.94f brightness:1.0f alpha:1.0f];
        _textField.font = [UIFont boldSystemFontOfSize:18.0f];
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
        [self.contentView addSubview:_textField];
    }
    return _textField;
}

- (UIButton *)button
{
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeSystem];
        _button.frame = (CGRect){CGRectGetWidth(self.bounds) - 44, 0, 44, 44};
        _button.titleLabel.font = [UIFont systemFontOfSize:18.0f];
        _button.tintColor = [UIColor darkGrayColor];
        [self.contentView addSubview:_button];
    }
    return _button;
}

@end
