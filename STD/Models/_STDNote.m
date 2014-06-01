// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to STDNote.m instead.

#import "_STDNote.h"

const struct STDNoteAttributes STDNoteAttributes = {
	.body = @"body",
	.note_id = @"note_id",
};

const struct STDNoteRelationships STDNoteRelationships = {
	.task = @"task",
};

const struct STDNoteFetchedProperties STDNoteFetchedProperties = {
};

@implementation STDNoteID
@end

@implementation _STDNote

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"STDNote" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"STDNote";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"STDNote" inManagedObjectContext:moc_];
}

- (STDNoteID*)objectID {
	return (STDNoteID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic body;






@dynamic note_id;






@dynamic task;

	






@end
