#import "STDTask.h"


@interface STDTask ()

// Private interface goes here.

@end


@implementation STDTask

// Custom logic goes here.

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    
    if (![self primitiveValueForKey:NSStringFromSelector(@selector(task_id))]) {
        [self setPrimitiveValue:[[NSUUID UUID] UUIDString] forKey:NSStringFromSelector(@selector(task_id))];
    }
}

- (void)addSubtasksObject:(STDSubtask *)value_
{
    value_.indexValue = [[self primitiveSubtasks] count];
    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value_ count:1];
    
    [self willChangeValueForKey:@"subtasks" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveSubtasks] addObject:value_];
    [self didChangeValueForKey:@"subtasks" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
}

@end
