#import "STDNote.h"


@interface STDNote ()

// Private interface goes here.

@end


@implementation STDNote

// Custom logic goes here.

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    
    if (![self primitiveValueForKey:NSStringFromSelector(@selector(note_id))]) {
        [self setPrimitiveValue:[[NSUUID UUID] UUIDString] forKey:NSStringFromSelector(@selector(note_id))];
    }
}

@end
