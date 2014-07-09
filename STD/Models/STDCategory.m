#import "STDCategory.h"


@interface STDCategory ()

// Private interface goes here.

@end


@implementation STDCategory

// Custom logic goes here.

- (void)willSave
{
    [super willSave];
    
    if (![self primitiveValueForKey:NSStringFromSelector(@selector(category_id))]) {
        [self setPrimitiveValue:[[NSUUID UUID] UUIDString] forKey:NSStringFromSelector(@selector(category_id))];
    }
    
    if (![self primitiveValueForKey:NSStringFromSelector(@selector(index))]) {
        [self setPrimitiveValue:@([STDCategory countOfEntities]) forKey:NSStringFromSelector(@selector(index))];
    }
}

@end
