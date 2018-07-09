//
//  NSArray+.m
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

#import "NSArray+.h"

@implementation NSArray (HLShortcuts)

- (id)objectOrNilAtIndex:(NSUInteger)index {
    return [self containsIndex:index] ? [self objectAtIndex:index] : nil;
}

- (BOOL)containsIndex:(NSUInteger)index {
    return index < [self count];
}

@end

#pragma mark -

@implementation NSMutableArray (HLShortcuts)

- (void)addObjectOrNil:(id)anObject {
    if (anObject) {
        [self addObject:anObject];
    }
}

- (BOOL)insertObjectOrNil:(id)anObject atIndex:(NSUInteger)index {
    if (anObject && index <= [self count]) {
        [self insertObject:anObject atIndex:index];
        return YES;
    }
    return NO;
}

- (BOOL)replaceObjectAtIndex:(NSUInteger)index withObjectOrNil:(id)anObject {
    if (anObject && index < [self count]) {
        [self replaceObjectAtIndex:index withObject:anObject];
        return YES;
    }
    return NO;
}

@end

#pragma mark - SubArray

@implementation NSArray (HLSubArray)

- (NSArray *)subArrayToIndex:(NSUInteger)anIndex {
    if (anIndex > self.count) {
        return self;
    }
    else {
        NSRange range;
        range.location = 0;
        range.length = anIndex;
        return [self subarrayWithRange:range];
    }
}

@end
