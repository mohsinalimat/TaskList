// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to STDSubtask.m instead.

#import "_STDSubtask.h"

const struct STDSubtaskRelationships STDSubtaskRelationships = {
	.task = @"task",
};

@implementation STDSubtaskID
@end

@implementation _STDSubtask

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"STDSubtask" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"STDSubtask";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"STDSubtask" inManagedObjectContext:moc_];
}

- (STDSubtaskID*)objectID {
	return (STDSubtaskID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic task;

@end

