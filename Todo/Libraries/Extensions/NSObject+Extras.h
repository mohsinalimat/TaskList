
@interface NSObject (Extras)

@property (nonatomic, strong) id associatedObject;

- (void)setAssociatedObject:(id)object forKey:(void *)key;
- (id)associatedObjectForKey:(void *)key;

@end
