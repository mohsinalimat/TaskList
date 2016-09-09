// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to STDNote.h instead.

#import <CoreData/CoreData.h>

extern const struct STDNoteAttributes {
	__unsafe_unretained NSString *body;
	__unsafe_unretained NSString *note_id;
} STDNoteAttributes;

extern const struct STDNoteRelationships {
	__unsafe_unretained NSString *task;
} STDNoteRelationships;

@class STDTask;

@interface STDNoteID : NSManagedObjectID {}
@end

@interface _STDNote : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) STDNoteID* objectID;

@property (nonatomic, strong) NSString* body;

//- (BOOL)validateBody:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* note_id;

//- (BOOL)validateNote_id:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) STDTask *task;

//- (BOOL)validateTask:(id*)value_ error:(NSError**)error_;

@end

@interface _STDNote (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveBody;
- (void)setPrimitiveBody:(NSString*)value;

- (NSString*)primitiveNote_id;
- (void)setPrimitiveNote_id:(NSString*)value;

- (STDTask*)primitiveTask;
- (void)setPrimitiveTask:(STDTask*)value;

@end
