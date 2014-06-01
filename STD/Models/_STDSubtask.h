// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to STDSubtask.h instead.

#import <CoreData/CoreData.h>
#import "STDTask.h"

extern const struct STDSubtaskAttributes {
} STDSubtaskAttributes;

extern const struct STDSubtaskRelationships {
	__unsafe_unretained NSString *task;
} STDSubtaskRelationships;

extern const struct STDSubtaskFetchedProperties {
} STDSubtaskFetchedProperties;

@class STDTask;


@interface STDSubtaskID : NSManagedObjectID {}
@end

@interface _STDSubtask : STDTask {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (STDSubtaskID*)objectID;





@property (nonatomic, strong) STDTask *task;

//- (BOOL)validateTask:(id*)value_ error:(NSError**)error_;





@end

@interface _STDSubtask (CoreDataGeneratedAccessors)

@end

@interface _STDSubtask (CoreDataGeneratedPrimitiveAccessors)



- (STDTask*)primitiveTask;
- (void)setPrimitiveTask:(STDTask*)value;


@end
