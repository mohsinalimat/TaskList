//
//  STDCoreDataUtilities.h
//  STD
//
//  Created by Lasha Efremidze on 12/28/14.
//  Copyright (c) 2014 More Voltage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STDCoreDataUtilities : NSObject

+ (STDCoreDataUtilities *)sharedInstance;

- (NSArray *)categories;

- (NSSet *)uncompletedTasksForCategory:(STDCategory *)category;
- (NSSet *)uncompletedSubtasksForTask:(STDTask *)task;
- (NSArray *)sortedUncompletedTasksForCategory:(STDCategory *)category;
- (NSArray *)sortedUncompletedSubtasksForTask:(STDTask *)task;
- (NSUInteger)countOfUncompletedTasksForCategory:(STDCategory *)category;
- (NSUInteger)countOfUncompletedSubtasksForTask:(STDTask *)task;
- (NSUInteger)countOfSubtasksForTasksForCategory:(STDCategory *)category;
- (void)updateIndexesForManagedObjects:(NSArray *)managedObjects;

@end
