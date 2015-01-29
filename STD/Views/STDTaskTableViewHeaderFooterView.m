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
    [self.contentView addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureRecognized:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.contentView addGestureRecognizer:doubleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
}

#pragma mark - Override Properties

- (UITextField *)textField
{
    if (!_textField) {
        _textField = ({
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectInset(self.contentView.bounds, 14, 0)];
            textField.center = self.contentView.center;
            textField.textColor = STDColorDefault;
            textField.font = STDFontBlack20;
            textField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
            textField.autocorrectionType = UITextAutocorrectionTypeNo;
            textField;
        });
        [self.contentView addSubview:_textField];
    }
    return _textField;
}

- (UIButton *)button
{
    if (!_button) {
        _button = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            button.frame = ({
                CGRect frame = (CGRect){0, 0, 44, 44};
                frame.origin.x = CGRectGetMaxX(self.contentView.frame) - CGRectGetWidth(frame);
                frame;
            });
            button.tintColor = STDColorDefault;
            [button addTarget:self action:@selector(didTouchOnButton:) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
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
