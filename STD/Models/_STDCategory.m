// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to STDCategory.m instead.

#import "_STDCategory.h"

const struct STDCategoryAttributes STDCategoryAttributes = {
	.category_id = @"category_id",
	.index = @"index",
	.name = @"name",
};

const struct STDCategoryRelationships STDCategoryRelationships = {
	.tasks = @"tasks",
};

const struct STDCategoryFetchedProperties STDCategoryFetchedProperties = {
};

@implementation STDCategoryID
@end

@implementation _STDCategory

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"STDCategory" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"STDCategory";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"STDCategory" inManagedObjectContext:moc_];
}

- (STDCategoryID*)objectID {
	return (STDCategoryID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"indexValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"index"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic category_id;






@dynamic index;



- (int16_t)indexValue {
	NSNumber *result = [self index];
	return [result shortValue];
}

- (void)setIndexValue:(int16_t)value_ {
	[self setIndex:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveIndexValue {
	NSNumber *result = [self primitiveIndex];
	return [result shortValue];
}

- (void)setPrimitiveIndexValue:(int16_t)value_ {
	[self setPrimitiveIndex:[NSNumber numberWithShort:value_]];
}





@dynamic name;






@dynamic tasks;

	
- (NSMutableSet*)tasksSet {
	[self willAccessValueForKey:@"tasks"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"tasks"];
  
	[self didAccessValueForKey:@"tasks"];
	return result;
}
	






@end
