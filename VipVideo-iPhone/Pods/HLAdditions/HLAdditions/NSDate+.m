//
//  NSDate+.m
//  iM9
//
//  Created by iwill on 2013-02-01.
//
//

#if ! __has_feature(objc_arc)
// set -fobjc-arc flag: - Target > Build Phases > Compile Sources > implementation.m + -fobjc-arc
#error This file must be compiled with ARC. Use -fobjc-arc flag or convert project to ARC.
#endif

#if ! __has_feature(objc_arc_weak)
#error ARCWeakRef requires iOS 5 and higher.
#endif

#import "NSDate+.h"

extern NSMilliseconds NSMillisecondsFromTimeInterval(NSTimeInterval timeInterval) {
    return (NSMilliseconds)(timeInterval * 1000);
}

extern NSTimeInterval NSTimeIntervalFromMilliseconds(NSMilliseconds milliseconds) {
    return (NSTimeInterval)milliseconds / 1000;
}

#pragma mark -

@implementation NSDate (NSMilliseconds)

/* DEPRECATED */

+ (NSTimeInterval)timeIntervalSince1970 {
    return [self timeIntervalSinceReferenceDate] + NSTimeIntervalSince1970;
}

+ (NSMilliseconds)millisecondsSince1970 {
    return NSMillisecondsFromTimeInterval([self timeIntervalSince1970]);
}

/* public */

+ (NSMilliseconds)millisecondsSinceReferenceDate {
    return NSMillisecondsFromTimeInterval([self timeIntervalSinceReferenceDate]);
}

- (NSMilliseconds)millisecondsSince1970 {
    return NSMillisecondsFromTimeInterval([self timeIntervalSince1970]);
}

- (NSMilliseconds)millisecondsSinceReferenceDate {
    return NSMillisecondsFromTimeInterval([self timeIntervalSinceReferenceDate]);
}

@end

#pragma mark -

@implementation NSDate (NSDateCreationViaMilliseconds)

+ (instancetype)dateWithMillisecondsSinceNow:(NSMilliseconds)milliseconds {
    return [self dateWithTimeIntervalSinceNow:NSTimeIntervalFromMilliseconds(milliseconds)];
}

+ (instancetype)dateWithMillisecondsSinceReferenceDate:(NSMilliseconds)milliseconds {
    return [self dateWithTimeIntervalSinceReferenceDate:NSTimeIntervalFromMilliseconds(milliseconds)];
}

+ (instancetype)dateWithMillisecondsSince1970:(NSMilliseconds)milliseconds {
    return [self dateWithTimeIntervalSince1970:NSTimeIntervalFromMilliseconds(milliseconds)];
}

+ (instancetype)dateWithMilliseconds:(NSMilliseconds)millisecondsToBeAdded sinceDate:(NSDate *)date {
    return [self dateWithTimeInterval:NSTimeIntervalFromMilliseconds(millisecondsToBeAdded) sinceDate:date];
}

- (instancetype)initWithMillisecondsSinceReferenceDate:(NSMilliseconds)milliseconds {
    return [self initWithMillisecondsSinceReferenceDate:NSTimeIntervalFromMilliseconds(milliseconds)];
}

- (instancetype)initWithMillisecondsSinceNow:(NSMilliseconds)milliseconds {
    return [self initWithTimeIntervalSinceNow:NSTimeIntervalFromMilliseconds(milliseconds)];
}

- (instancetype)initWithMillisecondsSince1970:(NSMilliseconds)milliseconds {
    return [self initWithTimeIntervalSince1970:NSTimeIntervalFromMilliseconds(milliseconds)];
}

- (instancetype)initWithMilliseconds:(NSMilliseconds)millisecondsToBeAdded sinceDate:(NSDate *)date {
    return [self initWithTimeInterval:NSTimeIntervalFromMilliseconds(millisecondsToBeAdded) sinceDate:date];
}

@end

#pragma mark -

@implementation NSDate (M9Category)

+ (NSTimeInterval)timeIntervalSinceDate:(NSDate *)date {
    return - [date timeIntervalSinceNow];
}

@end

#pragma mark -

@implementation NSDate (NSDateFormatter)

- (NSString *)stringWithFormat:(NSString *)format {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:self];
}

@end

