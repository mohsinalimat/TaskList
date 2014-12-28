//
//  STDCoreDataUtilities.m
//  STD
//
//  Created by Lasha Efremidze on 12/28/14.
//  Copyright (c) 2014 More Voltage. All rights reserved.
//

#import "STDCoreDataUtilities.h"

@implementation STDCoreDataUtilities

+ (STDCoreDataUtilities *)sharedInstance;
{
    static STDCoreDataUtilities *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [STDCoreDataUtilities new];
    });
    return _sharedInstance;
}

#pragma mark - Categories

- (NSArray *)categories
{
    NSFetchRequest *request = [STDCategory requestAllSortedBy:NSStringFromSelector(@selector(index)) ascending:YES];
    [request setRelationshipKeyPathsForPrefetching:@[@"tasks", @"tasks.subtasks"]];
    NSArray *categories = [STDCategory executeFetchRequest:request];
    if (!categories.count) {
        STDCategory *category1 = [STDCategory createEntity];
        category1.name = @"Home";
        category1.indexValue = 0;
        
        STDCategory *category2 = [STDCategory createEntity];
        category2.name = @"Work";
        category2.indexValue = 1;
        
        [[NSManagedObjectContext contextForCurrentThread] saveOnlySelfAndWait];
        
        return [self categories];
    }
    return categories;
}

#pragma mark - Tasks

- (NSSet *)uncompletedTasksForCategory:(STDCategory *)category
{
    return [category.tasks filteredSetUsingPredicate:[self uncompletedPredicate]];
}

- (NSSet *)uncompletedSubtasksForTask:(STDTask *)task
{
    return [task.subtasks filteredSetUsingPredicate:[self uncompletedPredicate]];
}

- (NSArray *)sortedUncompletedTasksForCategory:(STDCategory *)category
{
    return [self indexSortedArrayWithSet:[self uncompletedTasksForCategory:category]];
}

- (NSArray *)sortedUncompletedSubtasksForTask:(STDTask *)task
{
    return [self indexSortedArrayWithSet:[self uncompletedSubtasksForTask:task]];
}

- (NSUInteger)countOfUncompletedTasksForCategory:(STDCategory *)category
{
    return [[self uncompletedTasksForCategory:category] count];
}

- (NSUInteger)countOfUncompletedSubtasksForTask:(STDTask *)task
{
    return [[self uncompletedSubtasksForTask:task] count];
}

- (NSUInteger)countOfSubtasksForTasksForCategory:(STDCategory *)category
{
    NSUInteger count = 0;
    for (STDTask *task in [self uncompletedTasksForCategory:category])
        count += [self countOfUncompletedSubtasksForTask:task];
    return count;
}

- (void)updateIndexesForManagedObjects:(NSArray *)managedObjects
{
    for (NSManagedObject *managedObject in managedObjects) {
        if ([managedObject respondsToSelector:@selector(setIndex:)]) {
            [managedObject performSelector:@selector(setIndex:) withObject:@([managedObjects indexOfObject:managedObject])];
        }
    }
}

#pragma mark - Helpers

- (NSArray *)indexSortedArrayWithSet:(NSSet *)set
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(index)) ascending:YES];
    return [set sortedArrayUsingDescriptors:@[sortDescriptor]];
}

- (NSPredicate *)uncompletedPredicate
{
    return [NSPredicate predicateWithFormat:@"%K != YES", NSStringFromSelector(@selector(completed))];
}

@end
