//
//  HLUtilities.h
//  M9Dev
//
//  Created by iwill on 2013-06-26.
//  Copyright (c) 2013年 M9. All rights reserved.
//

#import <Foundation/Foundation.h>


#define OR          ? :

// for compound statement
#define _RETURN     ; // RETURN is defined in tty.h

// for each with blocks
#define _BREAK      return NO
#define _CONTINUE   return YES


/**
 * NSString
 */

#define NSObjectFromValue(value)                                @(value)
#define NSStringFromValue(value)                                [@(value) description]
#define NSStringFromBOOL(value)                                 (value ? @"YES" : @"NO")
#define NSStringFromVariableName(variableName)                  @(#variableName) // #variableName - variableName to CString

#define NSStringFromLiteral(literal)                            @(#literal)
// !!!: use defaultValue if preprocessor is undefined or its value is same to itself
#define NSStringFromPreprocessor(preprocessor, defaultValue)    ({ \
    NSString *string = NSStringFromLiteral(preprocessor); \
    [string isEqualToString:@#preprocessor] ? defaultValue : string; \
})
// !!!: use defaultValue if preprocessor is undefined or its value is same to itself
#define NSIntegerFromPreprocessor(preprocessor, defaultValue)   ({ \
    NSString *string = NSStringFromLiteral(preprocessor); \
    [string isEqualToString:@#preprocessor] ? defaultValue : [string integerValue]; \
})


/**
 * NSMerge
 */

#define NSMergeString(a, b)     [a OR @"" stringByAppendingString:b OR @""]
#define NSMergeArray(a, b)      [a OR @[] arrayByAddingObjectsFromArray:b OR @[]]
#define NSMergeDictionary(a, b) [a OR @{} dictionaryByAddingObjectsFromDictionary:b OR @{}]


/**
 * va - variable arguments
 */
#define va_each(type, first, block) { \
    va_list args; \
    va_start(args, first); \
    for (type arg = first; !!arg; arg = va_arg(args, type)) { \
        block(arg); \
    } \
    va_end(args); \
}
#define va_each_if_yes(type, first, block) { \
    va_list args; \
    va_start(args, first); \
    for (type arg = first; arg && block(arg); arg = va_arg(args, type)) { \
    } \
    va_end(args); \
}
#define va_to_array(type, first) ({ \
    NSMutableArray *array = [NSMutableArray array]; \
    va_each(type, first, ^(type arg) { \
        if (arg) [array addObject:arg]; \
    }); \
    _RETURN array; \
})
/*
#define va_make(args, first, statements) \
    va_list args; \
    va_start(args, first); \
    @try \
        statements \
    @finally { \
        va_end(args); \
    } */


/**
 * strongify with block
 */

/* strongify var, and call $statements if $var is not nil
 */
#define strongifyAnd($var, $statements) \
    strongify($var); \
    if ($var) { \
        $statements \
    }
/* strongify var, or call $statements if $var is nil
 */
#define strongifyOr($var, $statements) \
    strongify($var); \
    if (!$var) { \
        $statements \
    }


/**
 * NSLocking
 * Allows return everywhere between LOCK and UNLOCK, no need extra unlock
 */

/* LOCKED(id<NSLocking> lock, statements-block) - syntax like @synchronized with NSLocking
 * e.g.
 *  LOCKED(lock, {
 *      // statements
 *  });
 */
#define LOCKED($lock, $statements) \
    [$lock lock]; \
    @try \
        $statements \
    @finally { \
        [$lock unlock]; \
    }

/*  LOCK(id<NSLocking> lock);
 *  // statements
 *  UNLOCK();
 */
#define LOCK($lock) \
    @try { \
        [$lock lock];
        // statements
#define UNLOCK($lock) \
    } \
    @finally { \
        [$lock unlock]; \
    }

/* NOTE: @synchronized without indent
 *  SYNCHRONIZED(object)
 *  // statements
 *  SYNCHRONIZED_END
#define SYNCHRONIZED(object) { \
    @synchronized(object) {
        // statements
#define END \
    }
 */


/**
 * dispatch
 */

static inline dispatch_time_t dispatch_time_in_seconds(NSTimeInterval seconds) {
    return dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC));
}

typedef void (^dispatch_semaphore_wait_callback)(void);

static inline long dispatch_semaphore_wait_for(void (^block)(dispatch_semaphore_wait_callback callback), NSTimeInterval timeout) {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    if (block) block(^{
        dispatch_semaphore_signal(semaphore);
    });
    return dispatch_semaphore_wait(semaphore, dispatch_time_in_seconds(timeout > 0.0 ? timeout : DISPATCH_TIME_FOREVER));
}

static inline long dispatch_semaphore_wait_for_block(void (^block)(dispatch_semaphore_wait_callback callback)) {
    return dispatch_semaphore_wait_for(block, - 1.0);
}

static inline long dispatch_semaphore_wait_for_seconds(NSTimeInterval seconds) {
    return dispatch_semaphore_wait_for(nil, seconds);
}

static inline void dispatch_after_seconds(NSTimeInterval seconds, dispatch_block_t block) {
    dispatch_after(dispatch_time_in_seconds(seconds), dispatch_get_main_queue(), block);
}

static inline void dispatch_sync_main_queue(dispatch_block_t block) {
    if ([NSThread isMainThread]) {
        block();
    }
    else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

static inline void dispatch_async_main_queue(dispatch_block_t block) {
    dispatch_async(dispatch_get_main_queue(), block);
}

static inline void dispatch_async_background_queue(dispatch_block_t block) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), block);
}    


/**
 * if: return self if condition is YES
 * as: return self if self is kind of class
 */

@interface NSObject (ReturnSelfIf)

- (id)if:(BOOL)condition;

- (id)as:(Class)clazz;
- (id)asArray;
- (id)asDictionary;
- (id)asMemberOfClass:(Class)clazz;
- (id)asProtocol:(Protocol *)protocol;
- (id)ifRespondsToSelector:(SEL)selector;

- (id)performIfRespondsToSelector:(SEL)selector;
- (id)performIfRespondsToSelector:(SEL)selector withObject:(id)object;
- (id)performIfRespondsToSelector:(SEL)selector withObject:(id)object1 withObject:(id)object2;

@end


/**
 * M9MakeCopy & @M9MakeCopyWithZone
 */

@protocol HLMakeCopy <NSCopying>

- (void)makeCopy:(id)copy;

@end

#define M9MakeCopyWithZone \
class NSObject; /* for @ */ \
- (instancetype)copyWithZone:(NSZone *)zone { \
    __typeof__(self) copy = [[self class] new]; \
    [self makeCopy:copy]; \
    return copy; \
}


/**
 * NSDirectory
 */
static inline NSString *NSDirectory(NSSearchPathDirectory directory) {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES);
    return [paths count] ? [paths objectAtIndex:0] : nil;
}


/**
 * typedef
 */

// NS instead of CG
// typedef CGFloat NSFloat;

// UIAnimationCompletion
typedef void (^UIAnimationCompletion)();
typedef void (^UIAnimationCompletionWithBOOL)(BOOL finished);


/**
 * NSRange
 */
static inline NSRange NSSafeRangeOfLength(NSRange range, NSUInteger length) {
    if (range.location > length) {
        range.location = length;
    }
    if (range.location + range.length > length) {
        range.length = length - range.location;
    }
    return range;
}


/**
 * CGRectSet
 */
#define CGRectSetX(_rect, _x) ({ \
    CGRect rect = _rect; \
    rect.origin.x = _x; \
    _RETURN rect; \
})
#define CGRectSetY(_rect, _y) ({ \
    CGRect rect = _rect; \
    rect.origin.y = _y; \
    _RETURN rect; \
})
#define CGRectSetWidth(_rect, _width) ({ \
    CGRect rect = _rect; \
    rect.size.width = _width; \
    _RETURN rect; \
})
#define CGRectSetHeight(_rect, _height) ({ \
    CGRect rect = _rect; \
    rect.size.height = _height; \
    _RETURN rect; \
})
#define CGRectSetOrigin(_rect, _origin) ({ \
    CGRect rect = _rect; \
    rect.origin = _origin; \
    _RETURN rect; \
})
#define CGRectSetSize(_rect, _size) ({ \
    CGRect rect = _rect; \
    rect.size = _size; \
    _RETURN rect; \
})
#define CGRectSet(_rect, statements) ({ \
    CGFloat x = _rect.origin.x, y = _rect.origin.y; \
    CGFloat width = _rect.size.width, height = _rect.size.height; \
    statements \
    _RETURN CGRectMake(x, y, width, height); \
})


/**
 * custom NSLog
 */

// #define AT __FILE__ ":" #__LINE__
#define _HERE ({ \
    NSString *file = [[NSString stringWithUTF8String:__FILE__] lastPathComponent]; \
    [NSString stringWithFormat:@"%s (%@:%d)", __PRETTY_FUNCTION__, file, __LINE__]; \
})

// __OPTIMIZE__, @see GCC_OPTIMIZATION_LEVEL
#ifndef __OPTIMIZE__
    #define NSLogHere() { \
        DDLogInfo(@"%@", _HERE); \
    }
#else
    void __NO_NSLog__(NSString *format, ...);
    #define NSLogHere()
    #define DDLogInfo(fmt, ...) { __NO_NSLog__(fmt, ##__VA_ARGS__); }
    #define NSLogv(fmt, ...) { __NO_NSLog__(fmt, ##__VA_ARGS__); }
#endif


/**
 * suppress warning
 *
 * e.g.
 *  SuppressPerformSelectorLeakWarning({
 *      // statements
 *  });
 * suppress warning, @see
 *  http://stackoverflow.com/a/7933931/456536
 * @see also
 *  http://stackoverflow.com/a/20058585/456536
 */

#define SuppressPerformSelectorLeakWarning(statements) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
statements \
_Pragma("clang diagnostic pop")

#define SuppressDeprecatedDeclarationsWarning(statements) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wdeprecated-declarations\"") \
statements \
_Pragma("clang diagnostic pop")

