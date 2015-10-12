#import "STDCategory.h"


@interface STDCategory ()

// Private interface goes here.

@end


@implementation STDCategory

// Custom logic goes here.

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    
    if (![self primitiveValueForKey:NSStringFromSelector(@selector(category_id))]) {
        [self setPrimitiveValue:[[NSUUID UUID] UUIDString] forKey:NSStringFromSelector(@selector(category_id))];
    }
    
    if (![self primitiveValueForKey:NSStringFromSelector(@selector(index))]) {
        [self setPrimitiveValue:@([STDCategory MR_countOfEntities] - 1) forKey:NSStringFromSelector(@selector(index))];
    }
}

- (void)addTasksObject:(STDTask *)value_
{
    value_.indexValue = [[self primitiveTasks] count];
    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value_ count:1];
    
    [self willChangeValueForKey:@"tasks" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveTasks] addObject:value_];
    [self didChangeValueForKey:@"tasks" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
}

@end
