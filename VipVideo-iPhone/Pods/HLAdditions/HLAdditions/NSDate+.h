//
//  NSDate+.h
//  iM9
//
//  Created by sohu on 2013-02-01.
//
//

#import <Foundation/Foundation.h>

typedef long long NSMilliseconds;

extern NSMilliseconds NSMillisecondsFromTimeInterval(NSTimeInterval timeInterval);
extern NSTimeInterval NSTimeIntervalFromMilliseconds(NSMilliseconds milliseconds);

#define NSMillisecondsSince1970 NSMillisecondsFromTimeInterval(NSTimeIntervalSince1970)

@interface NSDate (NSMilliseconds)

+ (NSMilliseconds)millisecondsSinceReferenceDate;

- (NSMilliseconds)millisecondsSince1970;
- (NSMilliseconds)millisecondsSinceReferenceDate;

@end

@interface NSDate (NSDateCreationViaMilliseconds)

+ (instancetype)dateWithMillisecondsSinceNow:(NSMilliseconds)milliseconds;
+ (instancetype)dateWithMillisecondsSinceReferenceDate:(NSMilliseconds)milliseconds;
+ (instancetype)dateWithMillisecondsSince1970:(NSMilliseconds)milliseconds;
+ (instancetype)dateWithMilliseconds:(NSMilliseconds)millisecondsToBeAdded sinceDate:(NSDate *)date;

- (instancetype)initWithMillisecondsSinceReferenceDate:(NSMilliseconds)milliseconds;

- (instancetype)initWithMillisecondsSinceNow:(NSMilliseconds)milliseconds;
- (instancetype)initWithMillisecondsSince1970:(NSMilliseconds)milliseconds;
- (instancetype)initWithMilliseconds:(NSMilliseconds)millisecondsToBeAdded sinceDate:(NSDate *)date;

@end

#pragma mark -

@interface NSDate (M9Category)

+ (NSTimeInterval)timeIntervalSinceDate:(NSDate *)date;

@end

#pragma mark - NSDateFormat

#define NSDateFormat_yyyy_MM_dd_HH_mm_ss_SSS @"yyyy-MM-dd HH:mm:ss:SSS"
#define NSDateFormat_yyyy_MM_dd_HH_mm_ss     @"yyyy-MM-dd HH:mm:ss"
#define NSDateFormat_yyyy_MM_dd              @"yyyy-MM-dd"
#define NSDateFormat_HH_mm_ss                           @"HH:mm:ss"
#define NSDateFormat_yyyyMMddHHmmssSSS       @"yyyyMMddHHmmssSSS"
#define NSDateFormat_yyyyMMddHHmmss          @"yyyyMMddHHmmss"

@interface NSDate (NSDateFormatter)

- (NSString *)stringWithFormat:(NSString *)format;

@end

