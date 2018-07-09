//
//  NSStringExtend.m
//  fushihui
//
//

#import <CommonCrypto/CommonDigest.h>
#import <CoreText/CoreText.h>
#import "NSString+Extend.h"
#import "NSData+Additions.h"
#import "HLUtilities.h"

#pragma mark -

@implementation NSString(HLExtendedForUrlComponents)
- (NSString *)stringByAppendingUrlComponent:(NSString *)urlComponent
{	
	if(urlComponent == nil || [urlComponent length] == 0)
		return self;
	
	NSString *url = self;
	NSInteger len = [url length];
	unichar tail = [url characterAtIndex:len-1];
	unichar head = [urlComponent characterAtIndex:0];
	unichar sep = (unichar)'/';
	if(tail != sep && head != sep)
	{
		url = [url stringByAppendingString:@"/"];
	}
	url = [url stringByAppendingString:urlComponent];
	return url;
}

- (NSString *)stringByAppendingUrlParameter:(NSString *)param forKey:(NSString *)key
{
	NSString *url = self;
	NSRange ret = [url rangeOfString:@"?"];
	if(ret.location == NSNotFound)
	{
		url = [url stringByAppendingFormat:@"?%@=%@", key, param];
	}
	else
	{
		url = [url stringByAppendingFormat:@"&%@=%@", key, param];
	}
	
	return url;
}

- (NSString *)urlStringByAppendingUrlParameter:(NSString *)parameter forKey:(NSString *)key {
    NSString *urlString = self;
    
    NSString *keyString = [NSString stringWithFormat:@"%@=", key];
    if ([self rangeOfString:keyString].location == NSNotFound) {
        urlString = [self stringByAppendingUrlParameter:parameter forKey:key];
    }
    
    return urlString;
}

// Copied and pasted from http://www.mail-archive.com/cocoa-dev@lists.apple.com/msg28175.html
- (NSDictionary*)parametersUsingEncoding:(NSStringEncoding)encoding {
    NSCharacterSet* delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&;"];
    NSMutableDictionary* pairs = [NSMutableDictionary dictionary];
    NSScanner* scanner = [[NSScanner alloc] initWithString:self];
    while (![scanner isAtEnd]) {
        NSString* pairString = nil;
        [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
        [scanner scanCharactersFromSet:delimiterSet intoString:NULL];
        NSArray* kvPair = [pairString componentsSeparatedByString:@"="];
        if (kvPair.count == 2) {
            NSString* key = [[kvPair objectAtIndex:0]
                             stringByReplacingPercentEscapesUsingEncoding:encoding];
            NSString* value = [[kvPair objectAtIndex:1]
                               stringByReplacingPercentEscapesUsingEncoding:encoding];
            [pairs setObject:value forKey:key];
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:pairs];
}

- (NSString*)stringByAddingParameters:(NSDictionary*)parameters {
    NSMutableArray* pairs = [NSMutableArray array];
    for (NSString* key in [parameters keyEnumerator]) {
        id aValue = [parameters objectForKey:key];
        NSString *value = nil;
        if (![aValue isKindOfClass:[NSString class]]) {
            
            value = [aValue description];
        } else {
            value = aValue;
        }
        value = [value stringByReplacingOccurrencesOfString:@"?" withString:@"%3F"];
        value = [value stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
        NSString* pair = [NSString stringWithFormat:@"%@=%@", key, value];
        [pairs addObject:pair];
    }
    
    NSString* params = [pairs componentsJoinedByString:@"&"];
    if ([self rangeOfString:@"?"].location == NSNotFound) {
        return [self stringByAppendingFormat:@"?%@", params];
    } else {
        return [self stringByAppendingFormat:@"&%@", params];
    }
}


- (NSString *)stringByAddPrefix:(NSString *)prefix
{
	NSString *url = self;
	if (![url hasPrefix:prefix]) 
	{
		//NSAssert(0, (@"url missing the prefix:%@",url)); 
		url = [NSString stringWithFormat:@"%@%@",prefix,url];
		
	}
	return url;
}

- (BOOL)isNmuberString
{
    BOOL isNmuberString = NO;
    long long int n = [self longLongValue];
    if (n < 18999999999 && n > 13000000000) {
        isNmuberString = YES;
    }
    return isNmuberString;
} 

- (BOOL)isEmailString 
{
    BOOL isEmailString = NO;
    NSRange range = [self rangeOfString:@"@"];
    if (range.length > 0) {
        isEmailString = YES;
    }
    return isEmailString;
}

@end

#pragma mark -	
@implementation NSString(HLMD5Extended)
+ (NSString *)stringWithUUIDGenerated
{
	CFUUIDRef uuid = CFUUIDCreate(NULL);
	CFStringRef uuidStr = CFUUIDCreateString(NULL, uuid);
	NSString *finalStr = [NSString stringWithString:(__bridge NSString *)uuidStr];
	CFRelease(uuid);
	CFRelease(uuidStr);
	
	return finalStr;
}


+(NSString*)generatingMD5:(NSArray *)array
{
    if(array==nil ) 
		return @"ERROR GETTING MD5";
	
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
	
	for(NSString *string in array)
	{
		const char* data = [string UTF8String];
        CC_MD5_Update(&md5, data, (unsigned int)strlen(data));
	}
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5);
	NSString* md5String = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
						   digest[0], digest[1], 
						   digest[2], digest[3],
						   digest[4], digest[5],
						   digest[6], digest[7],
						   digest[8], digest[9],
						   digest[10], digest[11],
						   digest[12], digest[13],
						   digest[14], digest[15]];
	
	
    return md5String;
}

- (NSString*)md5Hash
{
    return [[self dataUsingEncoding:NSUTF8StringEncoding] md5Hash];
}
@end

#pragma mark - NSString+Base64

static char base64EncodingTable[64] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

@implementation NSString (Base64)

+ (instancetype)stringWithBase64Data:(NSData *)base64Data {
    return [self stringWithBase64Data:base64Data lineLength:0];
}

+ (instancetype)stringWithBase64Data:(NSData *)base64Data lineLength:(int)lineLength {
    return [self stringWithBase64Data:base64Data lineLength:lineLength lineFeed:@"\n"];
}

+ (instancetype)stringWithBase64Data:(NSData *)base64Data lineLength:(int)lineLength lineFeed:(NSString *)lineFeed {
    unsigned long ixtext, lentext;
    long ctremaining;
    unsigned char input[3], output[4];
    short i, charsonline = 0, ctcopy;
    const unsigned char *raw;
    NSMutableString *result;
    
    lentext = [base64Data length];
    
    if (lentext < 1) {
        return @"";
    }
    
    result = [NSMutableString stringWithCapacity:lentext];
    
    raw = [base64Data bytes];
    
    ixtext = 0;
    
    while (true) {
        ctremaining = lentext - ixtext;
        
        if (ctremaining <= 0) {
            break;
        }
        
        for (i = 0; i < 3; i++) {
            unsigned long ix = ixtext + i;
            
            if (ix < lentext) {
                input[i] = raw[ix];
            }
            else {
                input[i] = 0;
            }
        }
        
        output[0] = (input[0] & 0xFC) >> 2;
        output[1] = ((input[0] & 0x03) << 4) | ((input[1] & 0xF0) >> 4);
        output[2] = ((input[1] & 0x0F) << 2) | ((input[2] & 0xC0) >> 6);
        output[3] = input[2] & 0x3F;
        
        ctcopy = 4;
        
        switch (ctremaining) {
            case 1:
                ctcopy = 2;
                break;
            case 2:
                ctcopy = 3;
                break;
        }
        
        for (i = 0; i < ctcopy; i++) {
            [result appendString:[NSString stringWithFormat:@"%c", base64EncodingTable[output[i]]]];
        }
        
        for (i = ctcopy; i < 4; i++) {
            [result appendString:@"="];
        }
        
        ixtext += 3;
        charsonline += 4;
        
        if (lineLength > 0 && charsonline >= lineLength && lineFeed.length) {
            charsonline = 0;
            [result appendString:lineFeed];
        }
    }
    
    return [self stringWithString:result];
}

@end

#pragma mark -
@implementation NSString (HLCoreTextExtention)

- (NSArray *)splitStringWithFont:(UIFont *)font constrainedToWidth:(CGFloat)lineWidth {
	CGRect box = CGRectMake(0,0, lineWidth, CGFLOAT_MAX);
	
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathAddRect(path, NULL, box);
	
	CFMutableAttributedStringRef _attributedString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
	NSInteger length = CFAttributedStringGetLength(_attributedString);
	CFAttributedStringReplaceString(_attributedString, CFRangeMake(0, length), (CFStringRef)self);
	CGFloat pointSize = [font pointSize];
	CTFontRef myFont = CTFontCreateWithName((CFStringRef)[font fontName], pointSize, NULL); 
	NSInteger newLength = CFStringGetLength((CFStringRef)self);
	CFAttributedStringSetAttribute(_attributedString, CFRangeMake(0, newLength), kCTFontAttributeName, myFont);
	CFRelease(myFont);
	CTFramesetterRef _framesetter = CTFramesetterCreateWithAttributedString(_attributedString);
	CFRelease(_attributedString);
	
	// Create a frame for this column and draw it.
	CTFrameRef _frame = CTFramesetterCreateFrame(_framesetter, CFRangeMake(0, 0), path, NULL);
	
    CFRelease(path);
    //{ added cxt 2011-12-31
    CFRelease(_framesetter);
    
	CFArrayRef _lineArray = CTFrameGetLines(_frame);
	NSMutableArray *returnedArray = [NSMutableArray array];
	CTLineRef oneLine = NULL;
	CFRange oneRange;
	NSString *oneSubString = NULL;
    @autoreleasepool {
        for (int i = 0; i < CFArrayGetCount(_lineArray); i++) {
            oneLine = CFArrayGetValueAtIndex(_lineArray, i);
            oneRange = CTLineGetStringRange(oneLine);
            oneSubString = [self substringWithRange:NSMakeRange(oneRange.location, oneRange.length)];
            [returnedArray addObject:oneSubString];
        }
        CFRelease(_frame);
    }
	return returnedArray;
}

@end


#pragma mark -
@implementation NSString (HLWhitespaceExtention)

- (NSString *) trimmedString {
    NSString *trimmedString = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	return [trimmedString length] ? trimmedString : nil;
}

- (BOOL)isWhitespaceAndNewlines {
    NSCharacterSet* whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    for (NSInteger i = 0; i < self.length; ++i) {
        unichar c = [self characterAtIndex:i];
        if (![whitespace characterIsMember:c]) {
            return NO;
        }
    }
    return YES;
}


- (BOOL)isEmptyOrWhitespace {
    // A nil or NULL string is not the same as an empty string
    return 0 == self.length ||
    ![self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length;
}

@end

#pragma mark -
@implementation NSString (HLHexString2Data)
- (NSData*)hexString2Data
{
    if(self.length)
    {
        int j=0;
        Byte bytes[self.length];
        for(int i = 0; i < [self length]; i++)
        {
            int int_ch;  /// 两位16进制数转化后的10进制数
            unichar hex_char1 = [self characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
            int int_ch1;
            if(hex_char1 >= '0' && hex_char1 <='9')
                int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
            else if(hex_char1 >= 'A' && hex_char1 <='F')
                int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
            else
                int_ch1 = (hex_char1-87)*16; //// a 的Ascll - 97
            i++;
            unichar hex_char2 = [self characterAtIndex:i]; ///两位16进制数中的第二位(低位)
            int int_ch2;
            if(hex_char2 >= '0' && hex_char2 <='9')
                int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
            else if(hex_char2 >= 'A' && hex_char1 <='F')
                int_ch2 = hex_char2-55; //// A 的Ascll - 65
            else
                int_ch2 = hex_char2-87; //// a 的Ascll - 97
            
            int_ch = int_ch1+int_ch2;
            bytes[j] = int_ch;  ///将转化后的数放入Byte数组里
            j++;
        }
        NSData *newData = [[NSData alloc] initWithBytes:bytes length:self.length / 2];
        return newData;
    }
    return nil;
}
@end


#pragma mark -
@implementation NSString (HLStringSizeExtention)


- (CGSize)stringSizeWithFont:(UIFont *)font {
    if ([self respondsToSelector:@selector(sizeWithAttributes:)]) {
        return [self sizeWithAttributes:@{ NSFontAttributeName: font }];
    }
    else {
        return [self sizeWithFont:font];
    }
}

- (CGSize)sizeWithFont:(UIFont *)font{
    return [self sizeWithAttributes:@{ NSFontAttributeName: font }];
}

- (CGSize)sizeWithFont:(UIFont *)font
     constrainedToSize:(CGSize)size{
    CGSize reSize = CGSizeZero;
    NSAttributedString *attributeText = [[NSAttributedString alloc] initWithString:self
                                                                        attributes:@{NSFontAttributeName:font OR [UIFont boldSystemFontOfSize:15.0f]}];
    CGSize labelsize = [attributeText boundingRectWithSize:size
                                                   options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    reSize = CGSizeMake(ceilf(labelsize.width), ceilf(labelsize.height));
    return reSize;
    
}

- (CGSize)sizeWithFont:(UIFont *)font
     constrainedToSize:(CGSize)size
         lineBreakMode:(NSLineBreakMode)lineBreakMode
             alignment:(NSTextAlignment)alignment {
    CGSize reSize = CGSizeZero;
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = lineBreakMode;
    paragraph.alignment = alignment;
    
    NSAttributedString *attributeText = [[NSAttributedString alloc] initWithString:self
                                                                        attributes:@{NSFontAttributeName:font,NSParagraphStyleAttributeName:paragraph}];
    CGSize labelsize = [attributeText boundingRectWithSize:size
                                                   options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    reSize = CGSizeMake(ceilf(labelsize.width), ceilf(labelsize.height));
    
    return reSize;
}

- (CGSize)sizeWithFont:(UIFont *)font
              forWidth:(CGFloat)width
         lineBreakMode:(NSLineBreakMode)lineBreakMode{
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = lineBreakMode;
    NSAttributedString *attributeText = [[NSAttributedString alloc] initWithString:self
                                                                        attributes:@{NSFontAttributeName:font,NSParagraphStyleAttributeName:paragraph}];
    CGSize size = CGSizeMake(width, MAXFLOAT);
    CGSize labelsize = [attributeText boundingRectWithSize:size
                                                   options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    CGSize reSize = CGSizeMake(ceilf(labelsize.width), ceilf(labelsize.height));
    return reSize;
}


- (void)drawInRect:(CGRect)rect withFont:(UIFont *)font color:(UIColor *)color lineBreakMode:(NSLineBreakMode)lineBreakMode alignment:(NSTextAlignment)alignment{
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = lineBreakMode;
    paragraph.alignment = alignment;
    if (font && color && paragraph) {
        [self drawInRect:rect withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:color, NSParagraphStyleAttributeName:paragraph}];
    }
}

@end
@implementation NSString (HLContains)

- (BOOL)containString:(NSString *)str {
    if (nil == str) return NO;
    
    BOOL contains = NO;
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.) {
        contains = [self containsString:str];
    }
    else {
        NSRange range = [self rangeOfString:str];
        if (range.location != NSNotFound) {
            contains = YES;
        }
    }
    
    return contains;
}

@end


