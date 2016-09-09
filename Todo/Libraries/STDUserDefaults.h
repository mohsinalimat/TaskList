
@interface STDUserDefaults : NSObject

+ (id)objectForKey:(NSString *)key;
+ (id)objectForKey:(NSString *)key defaultObject:(id)fallback;
+ (void)setObject:(id)object forKey:(NSString *)key;
+ (void)removeObjectForKey:(NSString *)key;

+ (BOOL)boolForKey:(NSString *)key;
+ (BOOL)boolForKey:(NSString *)key defaultBool:(BOOL)fallback;
+ (void)setBool:(BOOL)boolean forKey:(NSString *)key;

+ (NSInteger)integerForKey:(NSString *)key;
+ (NSInteger)integerForKey:(NSString *)key defaultInteger:(int)fallback;
+ (void)setInteger:(NSInteger)integer forKey:(NSString *)key;

+ (NSDictionary *)dictionaryForKey:(NSString *)key;

+ (NSArray *)arrayForKey:(NSString *)key;

+ (NSData *)dataForKey:(NSString *)key;

+ (BOOL)hasValueForKey:(NSString *)key;

+ (BOOL)save;

@end