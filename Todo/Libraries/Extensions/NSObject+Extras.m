
#import "NSObject+Extras.h"
#import <objc/runtime.h>

@implementation NSObject (Extras)

@dynamic associatedObject;

- (void)setAssociatedObject:(id)object
{
    [self setAssociatedObject:object forKey:@selector(associatedObject)];
}

- (id)associatedObject
{
    return [self associatedObjectForKey:@selector(associatedObject)];
}

- (void)setAssociatedObject:(id)object forKey:(void *)key;
{
    objc_setAssociatedObject(self, key, object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)associatedObjectForKey:(void *)key;
{
    return objc_getAssociatedObject(self, key);
}

@end
