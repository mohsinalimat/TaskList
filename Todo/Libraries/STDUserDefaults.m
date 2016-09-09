
#import "STDUserDefaults.h"

@implementation STDUserDefaults

#pragma mark - object

+ (id)objectForKey:(NSString *)key;
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+ (id)objectForKey:(NSString *)key defaultObject:(id)fallback;
{
    NSObject *object = [self objectForKey:key];
    if (!object) return fallback;
    return object;
}

+ (void)setObject:(id)object forKey:(NSString *)key;
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:object forKey:key];
}

+ (void)removeObjectForKey:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
}

#pragma mark - bool

+ (BOOL)boolForKey:(NSString *)key;
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}

+ (BOOL)boolForKey:(NSString *)key defaultBool:(BOOL)fallback;
{
    return [self hasValueForKey:key] ? [self boolForKey:key] : fallback;
}

+ (void)setBool:(BOOL)boolean forKey:(NSString *)key;
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:boolean forKey:key];
}

#pragma mark - integer

+ (NSInteger)integerForKey:(NSString *)key;
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:key];
}

+ (NSInteger)integerForKey:(NSString *)key defaultInteger:(int)fallback;
{
    return [self hasValueForKey:key] ? [self integerForKey:key] : fallback;
}

+ (void)setInteger:(NSInteger)integer forKey:(NSString *)key;
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:integer forKey:key];
}

#pragma mark - dictionary

+ (NSDictionary *)dictionaryForKey:(NSString *)key;
{
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:key];
}

#pragma mark - array

+ (NSArray *)arrayForKey:(NSString *)key;
{
    return [[NSUserDefaults standardUserDefaults] arrayForKey:key];
}

#pragma mark - array

+ (NSData *)dataForKey:(NSString *)key;
{
    return [[NSUserDefaults standardUserDefaults] dataForKey:key];
}

#pragma mark - value

+ (BOOL)hasValueForKey:(NSString *)key
{
    return [[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] indexOfObject:key] != NSNotFound;
}

#pragma mark - save

+ (BOOL)save;
{
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
