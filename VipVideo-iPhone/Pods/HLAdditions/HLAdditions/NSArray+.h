//
//  NSArray+.h
//  iM9
//
//

#import <Foundation/Foundation.h>

typedef id (^NSArrayObjectValidator)(id object);

/**
 * Shortcuts for reading value at index
 */
@interface NSArray (HLShortcuts)

- (id)objectOrNilAtIndex:(NSUInteger)index;
- (BOOL)containsIndex:(NSUInteger)index;

@end

/**
 * Shortcuts for writing value at index
 */
@interface NSMutableArray (HLShortcuts)

- (void)addObjectOrNil:(id)anObject;
- (BOOL)insertObjectOrNil:(id)anObject atIndex:(NSUInteger)index;
- (BOOL)replaceObjectAtIndex:(NSUInteger)index withObjectOrNil:(id)anObject;

@end

/**
 * subArray of the receiver array with conditions
 */
@interface NSArray (HLSubArray)

- (NSArray *)subArrayToIndex:(NSUInteger)anIndex;

@end


