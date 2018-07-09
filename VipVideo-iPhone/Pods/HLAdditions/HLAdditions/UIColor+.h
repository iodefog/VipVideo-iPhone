//
//  UIColor+.h
//  iMSC
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIColor (HLCategory)

- (UIColor *)inverseColor;

+ (UIColor *)colorWithName:(NSString *)name;
+ (UIColor *)colorWithHexString:(NSString *)hexString;

+ (UIColor *)colorWithName:(NSString *)name alpha:(CGFloat)alpha;
+ (UIColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha;

@end
