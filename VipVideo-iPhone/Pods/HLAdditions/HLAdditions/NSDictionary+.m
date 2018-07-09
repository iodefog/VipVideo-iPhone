//
//  NSDictionary+.m
//  iM9
//
//

#if ! __has_feature(objc_arc)
// set -fobjc-arc flag: - Target > Build Phases > Compile Sources > implementation.m + -fobjc-arc
#error This file must be compiled with ARC. Use -fobjc-arc flag or convert project to ARC.
#endif

#if ! __has_feature(objc_arc_weak)
#error ARCWeakRef requires iOS 5 and higher.
#endif

#import "NSDictionary+.h"

@implementation NSDictionary (HLShortcuts)

- (float)floatForKey:(id)aKey {
    return [self floatForKey:aKey defaultValue:0.0f];
}
- (float)floatForKey:(id)aKey defaultValue:(float)defaultValue {
    id object = [self objectForKey:aKey];
    if ([object respondsToSelector:@selector(floatValue)]) {
        return [object floatValue];
    }
    return defaultValue;
}

- (double)doubleForKey:(id)aKey {
    return [self doubleForKey:aKey defaultValue:0.0];
}
- (double)doubleForKey:(id)aKey defaultValue:(double)defaultValue {
    id object = [self objectForKey:aKey];
    if ([object respondsToSelector:@selector(doubleValue)]) {
        return [object doubleValue];
    }
    return defaultValue;
}

- (long long)longLongForKey:(id)aKey {
    return [self longLongForKey:aKey defaultValue:0];
}
- (long long)longLongForKey:(id)aKey defaultValue:(long long)defaultValue {
    id object = [self objectForKey:aKey];
    if ([object respondsToSelector:@selector(longLongValue)]) {
        return [object longLongValue];
    }
    return defaultValue;
}

- (unsigned long long)unsignedLongLongForKey:(id)aKey {
    return [self unsignedLongLongForKey:aKey defaultValue:0];
}
- (unsigned long long)unsignedLongLongForKey:(id)aKey defaultValue:(unsigned long long)defaultValue {
    id object = [self objectForKey:aKey];
    if ([object respondsToSelector:@selector(unsignedLongLongValue)]) {
        return [object unsignedLongLongValue];
    }
    return defaultValue;
}

- (BOOL)boolForKey:(id)aKey {
    return [self boolForKey:aKey defaultValue:NO];
}

- (BOOL)boolForKey:(id)aKey defaultValue:(BOOL)defaultValue {
    id object = [self objectForKey:aKey];
    if ([object respondsToSelector:@selector(boolValue)]) {
        return [object boolValue];
    }
    return defaultValue;
}

- (NSInteger)integerForKey:(id)aKey {
    return [self integerForKey:aKey defaultValue:0];
}
- (NSInteger)integerOrNotFoundForKey:(id)aKey {
    return [self integerForKey:aKey defaultValue:NSNotFound];
}
- (NSInteger)integerForKey:(id)aKey defaultValue:(NSInteger)defaultValue {
    id object = [self objectForKey:aKey];
    if ([object respondsToSelector:@selector(integerValue)]) {
        return [object integerValue];
    }
    return defaultValue;
}

- (NSUInteger)unsignedIntegerForKey:(id)aKey {
    return [self unsignedIntegerForKey:aKey defaultValue:0];
}
- (NSUInteger)unsignedIntegerOrNotFoundForKey:(id)aKey {
    return [self unsignedIntegerForKey:aKey defaultValue:NSNotFound];
}
- (NSUInteger)unsignedIntegerForKey:(id)aKey defaultValue:(NSUInteger)defaultValue {
    id object = [self objectForKey:aKey];
    if ([object respondsToSelector:@selector(unsignedIntegerValue)]) {
        return [object unsignedIntegerValue];
    }
    return defaultValue;
}

- (NSNumber *)numberForKey:(id)aKey {
    return [self numberForKey:aKey defaultValue:nil];
}
- (NSNumber *)numberForKey:(id)aKey defaultValue:(NSNumber *)defaultValue {
    return (NSNumber *)[self objectForKey:aKey class:[NSNumber class] defaultValue:defaultValue];
}

- (NSString *)stringForKey:(id)aKey {
    return [self stringForKey:aKey defaultValue:nil];
}
- (NSString *)stringOrEmptyStringForKey:(id)akey {
    return [self stringForKey:akey defaultValue:@""];
}
- (NSString *)stringForKey:(id)aKey defaultValue:(NSString *)defaultValue {
    id object = [self objectForKey:aKey];
    if (!object || object == [NSNull null]) {
        return defaultValue;
    }
    if ([object isKindOfClass:[NSString class]]) {
        return (NSString *)object;
    }
    return [object description];
}

- (NSArray *)arrayForKey:(id)aKey {
    return [self arrayForKey:aKey defaultValue:nil];
}
- (NSArray *)arrayForKey:(id)aKey defaultValue:(NSArray *)defaultValue {
    return (NSArray *)[self objectForKey:aKey class:[NSArray class] defaultValue:defaultValue];
}

- (NSDictionary *)dictionaryForKey:(id)aKey {
    return [self dictionaryForKey:aKey defaultValue:nil];
}
- (NSDictionary *)dictionaryForKey:(id)aKey defaultValue:(NSDictionary *)defaultValue {
    return (NSDictionary *)[self objectForKey:aKey class:[NSDictionary class] defaultValue:defaultValue];
}

- (NSData *)dataForKey:(id)aKey {
    return [self dataForKey:aKey defaultValue:nil];
}
- (NSData *)dataForKey:(id)aKey defaultValue:(NSData *)defaultValue {
    return (NSData *)[self objectForKey:aKey class:[NSData class] defaultValue:defaultValue];
}

- (NSDate *)dateForKey:(id)aKey {
    return [self dateForKey:aKey defaultValue:nil];
}
- (NSDate *)dateForKey:(id)aKey defaultValue:(NSDate *)defaultValue {
    return (NSDate *)[self objectForKey:aKey class:[NSDate class] defaultValue:defaultValue];
}

- (NSURL *)URLForKey:(id)aKey {
    return [self URLForKey:aKey defaultValue:nil];
}
- (NSURL *)URLForKey:(id)aKey defaultValue:(NSURL *)defaultValue {
    return (NSURL *)[self objectForKey:aKey class:[NSURL class] defaultValue:defaultValue];
}

- (id)objectForKey:(id)aKey class:(Class)clazz {
    return [self objectForKey:aKey class:clazz defaultValue:nil];
}
- (id)objectForKey:(id)aKey class:(Class)clazz defaultValue:(id)defaultValue {
    return [self objectForKey:aKey class:clazz protocol:nil defaultValue:defaultValue];
}

- (id)objectForKey:(id)aKey protocol:(Protocol *)protocol {
    return [self objectForKey:aKey protocol:protocol defaultValue:nil];
}
- (id)objectForKey:(id)aKey protocol:(Protocol *)protocol defaultValue:(id)defaultValue {
    return [self objectForKey:aKey class:nil protocol:protocol defaultValue:defaultValue];
}

- (id)objectForKey:(id)aKey class:(Class)clazz protocol:(Protocol *)protocol {
    return [self objectForKey:aKey class:clazz protocol:protocol defaultValue:nil];
}
- (id)objectForKey:(id)aKey class:(Class)clazz protocol:(Protocol *)protocol defaultValue:(id)defaultValue {
    id object = [self objectForKey:aKey];
    if ((!clazz || [object isKindOfClass:clazz])
        && (!protocol || [object conformsToProtocol:protocol])) {
        return object;
    }
    return defaultValue;
    
    /* DEMO: use block
    return [self objectForKey:aKey callback:^id(id object) {
        if ((!clazz || [object isKindOfClass:clazz])
            && (!protocol || [object conformsToProtocol:protocol])) {
            return object;
        }
        return defaultValue;
    }]; */
}

- (id)objectForKey:(id)aKey callback:(NSDictionaryObjectValidator)callback {
    id object = [self objectForKey:aKey];
    return callback ? callback(object) : object;
}

+ (instancetype)dictionaryByAddingObjectsFromDictionary:(NSDictionary *)dictionary {
    NSMutableDictionary *mutableSelf = [self mutableCopy];
    [mutableSelf addEntriesFromDictionary:dictionary];
    return [mutableSelf copy];
}

@end

#pragma mark -

@implementation NSMutableDictionary (HLShortcuts)

- (void)setFloat:(float)value forKey:(id<NSCopying>)aKey {
    [self setObject:@(value) forKey:aKey];
}

- (void)setDouble:(double)value forKey:(id<NSCopying>)aKey {
    [self setObject:@(value) forKey:aKey];
}

- (void)setLongLong:(long long)value forKey:(id<NSCopying>)aKey {
    [self setObject:@(value) forKey:aKey];
}

- (void)setUnsignedLongLong:(unsigned long long)value forKey:(id<NSCopying>)aKey {
    [self setObject:@(value) forKey:aKey];
}

- (void)setBool:(BOOL)value forKey:(id<NSCopying>)aKey {
    [self setObject:@(value) forKey:aKey];
}

- (void)setInteger:(NSInteger)value forKey:(id<NSCopying>)aKey {
    [self setObject:@(value) forKey:aKey];
}

- (void)setUnsignedInteger:(NSUInteger)value forKey:(id<NSCopying>)aKey {
    [self setObject:@(value) forKey:aKey];
}

- (void)setObjectOrNil:(id)anObject forKey:(id<NSCopying>)aKey {
    if (!aKey) {
        return;
    }
    
    if (!anObject) {
        [self removeObjectForKey:aKey];
        return;
    }
    
    [self setObject:anObject forKey:aKey];
}

+ (instancetype)dictionaryByAddingObjectsFromDictionary:(NSDictionary *)dictionary {
    NSMutableDictionary *mutableSelf = [self mutableCopy];
    [mutableSelf addEntriesFromDictionary:dictionary];
    return mutableSelf;
}

@end

