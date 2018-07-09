//
//  NSStringExtend.h
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#pragma mark -
@interface NSString(HLExtendedForUrlComponents)
- (NSString *)stringByAppendingUrlComponent:(NSString *)urlComponent;
- (NSString *)stringByAppendingUrlParameter:(NSString *)param forKey:(NSString *)key;
- (NSString *)urlStringByAppendingUrlParameter:(NSString *)parameter forKey:(NSString *)key;
- (NSDictionary*)parametersUsingEncoding:(NSStringEncoding)encoding;
- (NSString*)stringByAddingParameters:(NSDictionary*)parameters;

- (NSString *)stringByAddPrefix:(NSString *)prefix;

- (BOOL)isNmuberString;
- (BOOL)isEmailString;
@end

#pragma mark - MD5
@interface NSString(HLMD5Extended)
+ (NSString *)stringWithUUIDGenerated;
+ (NSString *)generatingMD5:(NSArray *)array;

////added ypc
- (NSString*)md5Hash;
@end


#pragma mark - NSString+Base64

@interface NSString (Base64)

+ (instancetype)stringWithBase64Data:(NSData *)base64Data;
+ (instancetype)stringWithBase64Data:(NSData *)base64Data lineLength:(int)lineLength;
+ (instancetype)stringWithBase64Data:(NSData *)base64Data lineLength:(int)lineLength lineFeed:(NSString *)lineFeed;

@end


#pragma mark -
@interface NSString (HLCoreTextExtention)
- (NSArray *)splitStringWithFont:(UIFont *)font constrainedToWidth:(CGFloat)lineWidth;
@end


#pragma mark -
@interface NSString (HLWhitespaceExtention)
- (id) trimmedString;
- (BOOL)isWhitespaceAndNewlines;
- (BOOL)isEmptyOrWhitespace;
@end

#pragma mark -
@interface NSString (HLHexString2Data)
- (NSData*)hexString2Data;
@end

#pragma mark -
@interface NSString (HLStringSizeExtention)

- (CGSize)stringSizeWithFont:(UIFont *)font;

- (CGSize)sizeWithFont:(UIFont *)font;

- (CGSize)sizeWithFont:(UIFont *)font
     constrainedToSize:(CGSize)size;

- (CGSize)sizeWithFont:(UIFont *)font
     constrainedToSize:(CGSize)size
         lineBreakMode:(NSLineBreakMode)lineBreakMode
             alignment:(NSTextAlignment)alignment;

- (CGSize)sizeWithFont:(UIFont *)font
              forWidth:(CGFloat)width
         lineBreakMode:(NSLineBreakMode)lineBreakMode;

- (void)drawInRect:(CGRect)rect withFont:(UIFont *)font color:(UIColor *)color lineBreakMode:(NSLineBreakMode)lineBreakMode alignment:(NSTextAlignment)alignment;

@end

#pragma mark -
@interface NSString (HLContains)

- (BOOL)containString:(NSString *)str;

@end

