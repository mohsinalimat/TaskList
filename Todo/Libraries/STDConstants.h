//
//  STDConstants.h
//  STD
//
//  Created by Lasha Efremidze on 1/18/15.
//  Copyright (c) 2015 More Voltage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STDConstants : NSObject

// Logging
#define STDDefaultLog [NSString stringWithFormat:@"%s (line %d)", __PRETTY_FUNCTION__, __LINE__]
#define STDLogInfo(format, ...) NSLog((@"%@ " format), STDDefaultLog, ##__VA_ARGS__)
#define STDLogWarn(format, ...) NSLog((@"%@ -> WARNING: " format), STDDefaultLog, ##__VA_ARGS__)
#define STDLogError(format, ...) NSLog((@"%@ -> ERROR: " format), STDDefaultLog, ##__VA_ARGS__)

// Fonts
#define STDFontLight16 [UIFont fontWithName:kAvenirLight size:16.0f]

#define STDFontMedium16 [UIFont fontWithName:kAvenirMedium size:16.0f]
#define STDFontMedium24 [UIFont fontWithName:kAvenirMedium size:24.0f]

#define STDFontBlack20 [UIFont fontWithName:kAvenirBlack size:20.0f]
#define STDFontBlack24 [UIFont fontWithName:kAvenirBlack size:24.0f]
#define STDFontBlack36 [UIFont fontWithName:kAvenirBlack size:36.0f]

#define kAvenirLight @"Avenir-Light"
#define kAvenirMedium @"Avenir-Medium"
#define kAvenirBlack @"Avenir-Black"

// Colors
#define STDColorBlue [UIColor colorWithHue:(210.0f / 360.0f) saturation:0.94f brightness:1.0f alpha:1.0f]
#define STDColorDefault STDColorBlue

@end
