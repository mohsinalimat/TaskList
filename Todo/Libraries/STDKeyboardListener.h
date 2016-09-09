//
//  STDKeyboardListener.h
//  STD
//
//  Created by Lasha Efremidze on 1/18/15.
//  Copyright (c) 2015 More Voltage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STDKeyboardListener : NSObject

@property (nonatomic, readonly, getter = isVisible) BOOL visible;

+ (STDKeyboardListener *)sharedInstance;

@end
