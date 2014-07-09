#import "STDSubtask.h"


@interface STDSubtask ()

// Private interface goes here.

@end


@implementation STDSubtask

// Custom logic goes here.

- (NSNumber *)getIndex;
{
    return @(self.task.subtasks.count);
}

@end
