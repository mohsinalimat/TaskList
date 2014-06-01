// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to STDCategory.h instead.

#import <CoreData/CoreData.h>


extern const struct STDCategoryAttributes {
	__unsafe_unretained NSString *category_id;
	__unsafe_unretained NSString *index;
	__unsafe_unretained NSString *name;
} STDCategoryAttributes;

extern const struct STDCategoryRelationships {
	__unsafe_unretained NSString *tasks;
} STDCategoryRelationships;

extern const struct STDCategoryFetchedProperties {
} STDCategoryFetchedProperties;

@class STDTask;





@interface STDCategoryID : NSManagedObjectID {}
@end

@interface _STDCategory : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (STDCategoryID*)objectID;





@property (nonatomic, strong) NSString* category_id;



//- (BOOL)validateCategory_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* index;



@property int16_t indexValue;
- (int16_t)indexValue;
- (void)setIndexValue:(int16_t)value_;

//- (BOOL)validateIndex:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *tasks;

- (NSMutableSet*)tasksSet;





@end

@interface _STDCategory (CoreDataGeneratedAccessors)

- (void)addTasks:(NSSet*)value_;
- (void)removeTasks:(NSSet*)value_;
- (void)addTasksObject:(STDTask*)value_;
- (void)removeTasksObject:(STDTask*)value_;

@end

@interface _STDCategory (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveCategory_id;
- (void)setPrimitiveCategory_id:(NSString*)value;




- (NSNumber*)primitiveIndex;
- (void)setPrimitiveIndex:(NSNumber*)value;

- (int16_t)primitiveIndexValue;
- (void)setPrimitiveIndexValue:(int16_t)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;





- (NSMutableSet*)primitiveTasks;
- (void)setPrimitiveTasks:(NSMutableSet*)value;


@end
