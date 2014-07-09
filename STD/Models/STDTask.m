#import "STDTask.h"


@interface STDTask ()

// Private interface goes here.

@end


@implementation STDTask

// Custom logic goes here.

- (void)willSave
{
    [super willSave];
    
    if (![self primitiveValueForKey:NSStringFromSelector(@selector(task_id))]) {
        [self setPrimitiveValue:[[NSUUID UUID] UUIDString] forKey:NSStringFromSelector(@selector(task_id))];
    }
    
    if (![self primitiveValueForKey:NSStringFromSelector(@selector(index))]) {
        [self setPrimitiveValue:[self getIndex] forKey:NSStringFromSelector(@selector(index))];
    }
}

- (NSNumber *)getIndex;
{
    return @(self.category.tasks.count);
}

@end
