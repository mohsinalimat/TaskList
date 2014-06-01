// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to STDTask.h instead.

#import <CoreData/CoreData.h>


extern const struct STDTaskAttributes {
	__unsafe_unretained NSString *completed;
	__unsafe_unretained NSString *completion_date;
	__unsafe_unretained NSString *index;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *task_id;
} STDTaskAttributes;

extern const struct STDTaskRelationships {
	__unsafe_unretained NSString *category;
	__unsafe_unretained NSString *note;
	__unsafe_unretained NSString *subtasks;
} STDTaskRelationships;

extern const struct STDTaskFetchedProperties {
} STDTaskFetchedProperties;

@class STDCategory;
@class STDNote;
@class STDSubtask;







@interface STDTaskID : NSManagedObjectID {}
@end

@interface _STDTask : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (STDTaskID*)objectID;





@property (nonatomic, strong) NSNumber* completed;



@property BOOL completedValue;
- (BOOL)completedValue;
- (void)setCompletedValue:(BOOL)value_;

//- (BOOL)validateCompleted:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* completion_date;



//- (BOOL)validateCompletion_date:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* index;



@property int16_t indexValue;
- (int16_t)indexValue;
- (void)setIndexValue:(int16_t)value_;

//- (BOOL)validateIndex:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* task_id;



//- (BOOL)validateTask_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) STDCategory *category;

//- (BOOL)validateCategory:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) STDNote *note;

//- (BOOL)validateNote:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *subtasks;

- (NSMutableSet*)subtasksSet;





@end

@interface _STDTask (CoreDataGeneratedAccessors)

- (void)addSubtasks:(NSSet*)value_;
- (void)removeSubtasks:(NSSet*)value_;
- (void)addSubtasksObject:(STDSubtask*)value_;
- (void)removeSubtasksObject:(STDSubtask*)value_;

@end

@interface _STDTask (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveCompleted;
- (void)setPrimitiveCompleted:(NSNumber*)value;

- (BOOL)primitiveCompletedValue;
- (void)setPrimitiveCompletedValue:(BOOL)value_;




- (NSDate*)primitiveCompletion_date;
- (void)setPrimitiveCompletion_date:(NSDate*)value;




- (NSNumber*)primitiveIndex;
- (void)setPrimitiveIndex:(NSNumber*)value;

- (int16_t)primitiveIndexValue;
- (void)setPrimitiveIndexValue:(int16_t)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitiveTask_id;
- (void)setPrimitiveTask_id:(NSString*)value;





- (STDCategory*)primitiveCategory;
- (void)setPrimitiveCategory:(STDCategory*)value;



- (STDNote*)primitiveNote;
- (void)setPrimitiveNote:(STDNote*)value;



- (NSMutableSet*)primitiveSubtasks;
- (void)setPrimitiveSubtasks:(NSMutableSet*)value;


@end
