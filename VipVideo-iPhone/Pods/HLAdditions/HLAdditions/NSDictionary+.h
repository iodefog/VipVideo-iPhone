//
//  NSDictionary+.h
//  iM9
//
//

#import <Foundation/Foundation.h>


typedef id (^NSDictionaryObjectValidator)(id object);


/**
 * Shortcuts for reading value for key
 * @see NSUserDefaults
 */
@interface NSDictionary (HLShortcuts)

/**
 *  Detect CGFloat is float or double:
 *
 *  #if defined(__LP64__) && __LP64__
 *      CGFloat is double
 *  #elif
 #      CGFloat is float
 *  #endif
 */

/* C */
- (float)floatForKey:(id)aKey;
- (float)floatForKey:(id)aKey defaultValue:(float)defaultValue;
- (double)doubleForKey:(id)aKey;
- (double)doubleForKey:(id)aKey defaultValue:(double)defaultValue;
/* C More */
- (long long)longLongForKey:(id)aKey;
- (long long)longLongForKey:(id)aKey defaultValue:(long long)defaultValue;
- (unsigned long long)unsignedLongLongForKey:(id)aKey;
- (unsigned long long)unsignedLongLongForKey:(id)aKey defaultValue:(unsigned long long)defaultValue;

/* OC */
- (BOOL)boolForKey:(id)aKey;
- (BOOL)boolForKey:(id)aKey defaultValue:(BOOL)defaultValue;
- (NSInteger)integerForKey:(id)aKey;
- (NSInteger)integerOrNotFoundForKey:(id)aKey;
- (NSInteger)integerForKey:(id)aKey defaultValue:(NSInteger)defaultValue;

/* OC More */
- (NSUInteger)unsignedIntegerForKey:(id)aKey;
- (NSUInteger)unsignedIntegerOrNotFoundForKey:(id)aKey;
- (NSUInteger)unsignedIntegerForKey:(id)aKey defaultValue:(NSUInteger)defaultValue;

/* OC Object */
- (NSNumber *)numberForKey:(id)aKey;
- (NSNumber *)numberForKey:(id)aKey defaultValue:(NSNumber *)defaultValue;
- (NSString *)stringForKey:(id)aKey;
- (NSString *)stringOrEmptyStringForKey:(id)akey;
- (NSString *)stringForKey:(id)akey defaultValue:(NSString *)defaultValue;
- (NSArray *)arrayForKey:(id)aKey;
- (NSArray *)arrayForKey:(id)aKey defaultValue:(NSArray *)defaultValue;
- (NSDictionary *)dictionaryForKey:(id)aKey;
- (NSDictionary *)dictionaryForKey:(id)aKey defaultValue:(NSDictionary *)defaultValue;
- (NSData *)dataForKey:(id)aKey;
- (NSData *)dataForKey:(id)aKey defaultValue:(NSData *)defaultValue;
- (NSDate *)dateForKey:(id)aKey;
- (NSDate *)dateForKey:(id)aKey defaultValue:(NSDate *)defaultValue;
- (NSURL *)URLForKey:(id)aKey;
- (NSURL *)URLForKey:(id)aKey defaultValue:(NSURL *)defaultValue;

/* OC Object More */
/* !!!:
 *  @param clazz: Be careful when using this method on objects represented by a class cluster...
 *
 *      // DO NOT DO THIS! Use - objectForKey:callback: instead
 *      if ([myArray isKindOfClass:[NSMutableArray class]]) {
 *          // Modify the object
 *      }
 *
 *      @see NSObject - isKindOfClass:
 */
- (id)objectForKey:(id)aKey class:(Class)clazz;
- (id)objectForKey:(id)aKey class:(Class)clazz defaultValue:(id)defaultValue;
- (id)objectForKey:(id)aKey protocol:(Protocol *)protocol;
- (id)objectForKey:(id)aKey protocol:(Protocol *)protocol defaultValue:(id)defaultValue;
- (id)objectForKey:(id)aKey class:(Class)clazz protocol:(Protocol *)protocol;
- (id)objectForKey:(id)aKey class:(Class)clazz protocol:(Protocol *)protocol defaultValue:(id)defaultValue;
- (id)objectForKey:(id)aKey callback:(NSDictionaryObjectValidator)callback;

/* Extended */
+ (instancetype)dictionaryByAddingObjectsFromDictionary:(NSDictionary *)dictionary;

@end


/**
 * Shortcuts for writing value for key
 */
@interface NSMutableDictionary (HLShortcuts)

/* C */
- (void)setFloat:(float)value forKey:(id<NSCopying>)aKey;
- (void)setDouble:(double)value forKey:(id<NSCopying>)aKey;

/* C More */
- (void)setLongLong:(long long)value forKey:(id<NSCopying>)aKey;
- (void)setUnsignedLongLong:(unsigned long long)value forKey:(id<NSCopying>)aKey;

/* OC */
- (void)setBool:(BOOL)value forKey:(id<NSCopying>)aKey;
- (void)setInteger:(NSInteger)value forKey:(id<NSCopying>)aKey;

/* OC More */
- (void)setUnsignedInteger:(NSUInteger)value forKey:(id<NSCopying>)aKey;

/* OC Object */
- (void)setObjectOrNil:(id)anObject forKey:(id<NSCopying>)aKey;

@end

