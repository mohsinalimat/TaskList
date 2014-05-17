//
//  STDAppDelegate.h
//  STD
//
//  Created by Lasha Efremidze on 5/17/14.
//  Copyright (c) 2014 Appoop Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STDAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
