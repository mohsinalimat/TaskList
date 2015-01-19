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
#define STDFontBold36 [UIFont boldSystemFontOfSize:36.0f]
#define STDFontBold24 [UIFont boldSystemFontOfSize:24.0f]
#define STDFontBold18 [UIFont boldSystemFontOfSize:18.0f]
#define STDFontBold16 [UIFont boldSystemFontOfSize:16.0f]

#define STDFont16 [UIFont systemFontOfSize:16.0f]

@end
