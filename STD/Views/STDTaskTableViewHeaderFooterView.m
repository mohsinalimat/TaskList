//
//  STDTaskTableViewHeaderFooterView.m
//  STD
//
//  Created by Lasha Efremidze on 11/9/14.
//  Copyright (c) 2014 More Voltage. All rights reserved.
//

#import "STDTaskTableViewHeaderFooterView.h"
#import "PureLayout.h"

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

#pragma mark - Override Properties

- (UITextField *)textField
{
    if (!_textField) {
        _textField = [STDTextField newAutoLayoutView];
        _textField.textColor = [UIColor colorWithHue:(210.0f / 360.0f) saturation:0.94f brightness:1.0f alpha:1.0f];
        _textField.font = [UIFont boldSystemFontOfSize:18.0f];
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
        _textField.rightView = [self rightView];
        _textField.rightViewMode = UITextFieldViewModeUnlessEditing;
        [self.contentView addSubview:_textField];
        
        [self.textField autoPinEdgesToSuperviewEdgesWithInsets:(UIEdgeInsets){0, 14, 0, 7}];
    }
    return _textField;
}

- (UIButton *)rightView
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = (CGRect){0, 0, 28, 40};
    button.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    button.tintColor = [UIColor darkGrayColor];
    [button addTarget:self action:@selector(didTouchOnButton:) forControlEvents:UIControlEventTouchUpInside];
    return button;
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
