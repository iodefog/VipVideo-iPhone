//
//  UIImage+.m
//  iM9
//
//  Created by iwill on 2011-06-20.
//  Copyright 2011 M9. All rights reserved.
//

#if ! __has_feature(objc_arc)
// set -fobjc-arc flag: - Target > Build Phases > Compile Sources > implementation.m + -fobjc-arc
#error This file must be compiled with ARC. Use -fobjc-arc flag or convert project to ARC.
#endif

#if ! __has_feature(objc_arc_weak)
#error ARCWeakRef requires iOS 5 and higher.
#endif

#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import "UIImage+.h"
#import "NSData+Additions.h"

static inline CGFloat DegreesToRadians(CGFloat degrees) {
    return degrees * M_PI / 180;
}

static inline CGFloat RadiansToDegrees(CGFloat radians) {
    return radians * 180 / M_PI;
}

@implementation UIImage (M9Category)

#pragma mark resizable image
#if TARGET_VERSION_UIView
+ (void)load {
    Method otherMehtod = class_getClassMethod(self, @selector(imageWithName:));
    Method originMehtod = class_getClassMethod(self, @selector(imageNamed:));
    // 交换2个方法的实现
    method_exchangeImplementations(otherMehtod, originMehtod);
    
}
+ (UIImage *)imageWithName:(NSString *)name{
    UIImage *image = nil;
    image = [UIImage imageWithName:name];//这里实际调用的时系统方法imageNamed:
    image.accessibilityIdentifier = name;
    return image;
}
#endif

- (UIImage *)resizableImage {
    CGFloat x = MAX(self.size.width / 2 , 0), y = MAX(self.size.height / 2 , 0);
    
    if (![self respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
        return [self stretchableImageWithLeftCapWidth:x topCapHeight:y];
    }
    
    return [self resizableImageWithCapInsets:UIEdgeInsetsMake(y, x, y, x)];
}

- (UIImage *)resizableImageOff:(CGFloat)off {
    CGFloat x = MAX(self.size.width / 2-off , 0), y = MAX(self.size.height / 2-off , 0);
    
    if (![self respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
        return [self stretchableImageWithLeftCapWidth:x topCapHeight:y];
    }
    
    return [self resizableImageWithCapInsets:UIEdgeInsetsMake(y, x, y, x)];
}

#pragma mark resize and zoom image

- (UIImage *)imageByResizing:(CGSize)size {
    return [UIImage imageWithImage:self size:size];
}

- (UIImage *)imageByZooming:(CGFloat)zoom {
    return [UIImage imageWithImage:self zoom:zoom];
}

+ (UIImage *)imageWithImage:(UIImage *)image size:(CGSize)size {
    if (!image) {
        return nil;
    }
    if (CGSizeEqualToSize(size, image.size)) {
        return [image copy];
    }
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)imageWithImage:(UIImage *)image zoom:(CGFloat)zoom {
    return [self imageWithImage:image size:CGSizeMake(image.size.width * zoom, image.size.height * zoom)];
}

- (UIImage *)imageCropByScale:(CGFloat)scale
{
    if ([NSStringFromClass([self class]) isEqualToString:@"_UIAnimatedImage"]) {
        // Gif 不进行裁剪，目的也是为了能够正常播放gif
        return self;
    }
    
    CGFloat width = self.size.width;
    CGFloat height = self.size.height;
    
    CGSize size = CGSizeZero;
    CGPoint origin = CGPointZero;
    
    //宽了
    if(width/height > scale){
        size = CGSizeMake(height*scale, height);
        origin = CGPointMake(-(width-height*scale)/2, 0);
        
    }else{
        //高了
        size = CGSizeMake(width, width/scale);
        origin = CGPointMake(0, -(height-width/scale)/2);
    }
    
    //zk 创建size大小画布，self从顶点画在画布里
    UIGraphicsBeginImageContextWithOptions(size, NO, self.scale);
    [self drawAtPoint:origin];
    UIImage* cropImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return cropImage;
}

- (UIImage *)imageByApplyingAlpha:(CGFloat)alpha {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, self.size.width, self.size.height);
    
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    
    CGContextSetAlpha(ctx, alpha);
    
    CGContextDrawImage(ctx, area, self.CGImage);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark rotate image

- (UIImage *)imageByRotateRadians:(CGFloat)radians {
    return [self imageByRotateDegrees:RadiansToDegrees(radians)];
}

- (UIImage *)imageByRotateRadians:(CGFloat)radians size:(CGSize)size {
    return [self imageByRotateDegrees:RadiansToDegrees(radians) size:size];
}

- (UIImage *)imageByRotateDegrees:(CGFloat)degrees {
    return [self imageByRotateDegrees:degrees size:CGSizeZero];
}

- (UIImage *)imageByRotateDegrees:(CGFloat)degrees size:(CGSize)size {
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        UIView *rotatedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.size.width, self.size.height)];
        CGAffineTransform transform = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
        rotatedView.transform = transform;
        size = rotatedView.frame.size;
    }
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 先上移一个图像高度，图像对y轴反转=>恢复成原图。
    CGContextTranslateCTM(context, 0, size.height);
    CGContextScaleCTM(context, 1, -1);
    // 再设定坐标系原点到图片中心，进行旋转操作。
    CGContextTranslateCTM(context, size.width / 2, size.height / 2);
    CGContextRotateCTM(context, -DegreesToRadians(degrees)); // 这里也需要反向一次。
    CGContextDrawImage(context,
                       CGRectMake(- size.width / 2,
                                  - size.height / 2,
                                  size.width,
                                  size.height),
                       self.CGImage);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)imageWithImage:(UIImage *)image rotateRadians:(CGFloat)radians {
    return [image imageByRotateRadians:radians];
}

+ (UIImage *)imageWithImage:(UIImage *)image rotateRadians:(CGFloat)radians size:(CGSize)size {
    return [image imageByRotateRadians:radians size:size];
}

+ (UIImage *)imageWithImage:(UIImage *)image rotateDegrees:(CGFloat)degrees {
    return [image imageByRotateDegrees:degrees];
}

+ (UIImage *)imageWithImage:(UIImage *)image rotateDegrees:(CGFloat)degrees size:(CGSize)size {
    return [image imageByRotateDegrees:degrees size:size];
}

#pragma mark image with color

+ (UIImage *)imageWithColor:(UIColor *)color {
    return [[self imageWithColor:color size:CGSizeMake(1, 1)] resizableImage];
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    color = color ? color : [UIColor clearColor];
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

//切割图片
+ (UIImage *)clipImage:(UIImage *)image inRect:(CGRect)rect
{
    //获取父图片要切的位置
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, rect);
    //用子图片来接收切割出来的图片
    UIImage *subImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return subImage;
}


#pragma mark screenshot image

#if !APP_EXTENSION
+ (UIImage *)screenshot {
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    CGSize imageSize = [UIScreen mainScreen].bounds.size;
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Iterate over every window from back to front
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        if (![window respondsToSelector:@selector(screen)] || window.screen == [UIScreen mainScreen]) {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, window.center.x, window.center.y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                                  - window.bounds.size.width * [window.layer anchorPoint].x,
                                  - window.bounds.size.height * [window.layer anchorPoint].y);
            
            // Render the layer hierarchy to the current context
            [window.layer renderInContext:context];
            
            // Restore the context
            CGContextRestoreGState(context);
        }
    }
    
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}
#endif

@end

#pragma mark - UIImage+Base64

@implementation UIImage (Base64)

+ (instancetype)imageWithBase64String:(NSString *)base64String {
    return [self imageWithData:[NSData base64DecodedData:base64String]];
}

@end


