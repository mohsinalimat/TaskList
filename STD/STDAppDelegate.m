//
//  STDAppDelegate.m
//  STD
//
//  Created by Lasha Efremidze on 5/17/14.
//  Copyright (c) 2014 More Voltage Inc. All rights reserved.
//

#import "STDAppDelegate.h"
#import "STDUserDefaults.h"
#import "UIImage+Extras.h"
#import "STDKeyboardListener.h"

#import "iRate.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@implementation STDAppDelegate

+ (void)initialize
{
    //configure iRate
    [iRate sharedInstance].daysUntilPrompt = 1;
    [iRate sharedInstance].remindPeriod = 5;
    [iRate sharedInstance].onlyPromptIfLatestVersion = YES;
    [iRate sharedInstance].previewMode = NO;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // settings bundle
    [STDUserDefaults setObject:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] forKey:@"version_preference"];
    
    // Magical Record
    [MagicalRecord setupAutoMigratingCoreDataStack];
    
    // Fabric
    [Fabric with:@[CrashlyticsKit]];
    
    // Init Keyboard Listener
    [STDKeyboardListener sharedInstance];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    // root view controller
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"STDHomepageViewControllerId"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    self.window.rootViewController = navigationController;
    
    UIImage *backgroundImage = [UIImage imageFromColor:[UIColor colorWithWhite:1.0f alpha:0.95f]];
    
    [[UINavigationBar appearance] setBackgroundImage:backgroundImage forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    
    [[UIToolbar appearance] setBackgroundImage:backgroundImage forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [[UIToolbar appearance] setShadowImage:[UIImage new] forToolbarPosition:UIBarPositionAny];
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:STDColorDefault}];
    
    [[UITextField appearance] setTextColor:[UIColor darkGrayColor]];
    [[UITextView appearance] setTextColor:[UIColor darkGrayColor]];
    [[UILabel appearance] setTextColor:[UIColor darkGrayColor]];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [STDUserDefaults save];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [MagicalRecord cleanUp];
}

@end
