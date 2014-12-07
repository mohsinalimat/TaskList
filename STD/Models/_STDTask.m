// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to STDTask.m instead.

#import "_STDTask.h"

const struct STDTaskAttributes STDTaskAttributes = {
	.completed = @"completed",
	.completion_date = @"completion_date",
	.index = @"index",
	.name = @"name",
	.task_id = @"task_id",
};

const struct STDTaskRelationships STDTaskRelationships = {
	.category = @"category",
	.note = @"note",
	.parent_task = @"parent_task",
	.subtasks = @"subtasks",
};

@implementation STDTaskID
@end

@implementation _STDTask

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"STDTask" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"STDTask";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"STDTask" inManagedObjectContext:moc_];
}

- (STDTaskID*)objectID {
	return (STDTaskID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"completedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"completed"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"indexValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"index"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic completed;

- (BOOL)completedValue {
	NSNumber *result = [self completed];
	return [result boolValue];
}

- (void)setCompletedValue:(BOOL)value_ {
	[self setCompleted:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveCompletedValue {
	NSNumber *result = [self primitiveCompleted];
	return [result boolValue];
}

- (void)setPrimitiveCompletedValue:(BOOL)value_ {
	[self setPrimitiveCompleted:[NSNumber numberWithBool:value_]];
}

@dynamic completion_date;

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

@dynamic task_id;

@dynamic category;

@dynamic note;

@dynamic parent_task;

@dynamic subtasks;

- (NSMutableSet*)subtasksSet {
	[self willAccessValueForKey:@"subtasks"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"subtasks"];

	[self didAccessValueForKey:@"subtasks"];
	return result;
}

@end

