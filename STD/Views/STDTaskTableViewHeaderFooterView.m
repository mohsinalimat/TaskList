//
//  STDTaskTableViewHeaderFooterView.m
//  STD
//
//  Created by Lasha Efremidze on 11/9/14.
//  Copyright (c) 2014 More Voltage. All rights reserved.
//

#import "STDTaskTableViewHeaderFooterView.h"

@implementation STDTaskTableViewHeaderFooterView

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self initGestures];
    }
    return self;
}

- (void)initGestures
{
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureRecognized:)];
    singleTap.numberOfTapsRequired = 1;
    [self addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureRecognized:)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
}

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
        [_button addTarget:self action:@selector(didTouchOnButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_button];
    }
    return _button;
}

#pragma mark - IBActions

- (IBAction)didTouchOnButton:(id)sender;
{
    if ([self.delegate respondsToSelector:@selector(taskTableViewHeaderFooterView:didTouchOnButton:)]) {
        [self.delegate taskTableViewHeaderFooterView:self didTouchOnButton:sender];
    }
}

- (void)singleTapGestureRecognized:(UITapGestureRecognizer *)recognizer;
{
    if ([self.delegate respondsToSelector:@selector(taskTableViewHeaderFooterView:singleTapGestureRecognized:)]) {
        [self.delegate taskTableViewHeaderFooterView:self singleTapGestureRecognized:recognizer];
    }
}

- (void)doubleTapGestureRecognized:(UITapGestureRecognizer *)recognizer;
{
    if ([self.delegate respondsToSelector:@selector(taskTableViewHeaderFooterView:doubleTapGestureRecognized:)]) {
        [self.delegate taskTableViewHeaderFooterView:self doubleTapGestureRecognized:recognizer];
    }
}

@end
