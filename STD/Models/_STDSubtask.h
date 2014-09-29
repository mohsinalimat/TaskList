// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to STDSubtask.h instead.

#import <CoreData/CoreData.h>
#import "STDTask.h"

extern const struct STDSubtaskRelationships {
	__unsafe_unretained NSString *task;
} STDSubtaskRelationships;

@class STDTask;

@interface STDSubtaskID : STDTaskID {}
@end

@interface _STDSubtask : STDTask {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) STDSubtaskID* objectID;

@property (nonatomic, strong) STDTask *task;

//- (BOOL)validateTask:(id*)value_ error:(NSError**)error_;

@end

@interface _STDSubtask (CoreDataGeneratedPrimitiveAccessors)

- (STDTask*)primitiveTask;
- (void)setPrimitiveTask:(STDTask*)value;

@end
