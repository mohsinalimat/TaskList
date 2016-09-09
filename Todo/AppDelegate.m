//
//  AppDelegate.m
//  Todo
//
//  Created by Lasha Efremidze on 9/9/16.
//  Copyright © 2016 More Voltage. All rights reserved.
//

#import "AppDelegate.h"
#import "STDUserDefaults.h"
#import "UIImage+Extras.h"
#import "STDKeyboardListener.h"

#import "iRate.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

+ (void)initialize
{
    //configure iRate
    [iRate sharedInstance].daysUntilPrompt = 1;
    [iRate sharedInstance].remindPeriod = 5;
    [iRate sharedInstance].onlyPromptIfLatestVersion = YES;
    [iRate sharedInstance].previewMode = NO;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [STDUserDefaults setObject:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] forKey:@"version_preference"];
    
    // MagicalRecord
    [MagicalRecord setupAutoMigratingCoreDataStack];
    
    // Fabric
    [Fabric with:@[CrashlyticsKit]];
    
    // STDKeyboardListener
    [STDKeyboardListener sharedInstance];
    
    UIImage *backgroundImage = [UIImage imageFromColor:[UIColor colorWithWhite:1.0f alpha:0.95f]];
    
    [[UINavigationBar appearance] setBackgroundImage:backgroundImage forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    
    [[UIToolbar appearance] setBackgroundImage:backgroundImage forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [[UIToolbar appearance] setShadowImage:[UIImage new] forToolbarPosition:UIBarPositionAny];
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:STDColorDefault}];
    
    [[UITextField appearance] setTextColor:[UIColor darkGrayColor]];
    [[UITextView appearance] setTextColor:[UIColor darkGrayColor]];
    [[UILabel appearance] setTextColor:[UIColor darkGrayColor]];
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [STDUserDefaults save];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [MagicalRecord cleanUp];
}

@end
