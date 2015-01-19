//
//  STDKeyboardListener.m
//  STD
//
//  Created by Lasha Efremidze on 1/18/15.
//  Copyright (c) 2015 More Voltage. All rights reserved.
//

#import "STDKeyboardListener.h"

@implementation STDKeyboardListener {
    BOOL _isVisible;
}

+ (STDKeyboardListener *)sharedInstance;
{
    static STDKeyboardListener *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [STDKeyboardListener new];
    });
    return _sharedInstance;
}

- (id)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

#pragma mark - Visible

- (BOOL)isVisible
{
    return _isVisible;
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    _isVisible = YES;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    _isVisible = NO;
}

@end
