//
//  UIImage+.h
//  iM9
//
//  Created by iwill on 2011-06-20.
//  Copyright 2011 M9. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (M9Category)

- (UIImage *)resizableImage;
- (UIImage *)resizableImageOff:(CGFloat)off;

- (UIImage *)imageByResizing:(CGSize)size;
- (UIImage *)imageByZooming:(CGFloat)zoom;
+ (UIImage *)imageWithImage:(UIImage *)image size:(CGSize)size;
+ (UIImage *)imageWithImage:(UIImage *)image zoom:(CGFloat)zoom;
/**
 *  按比例裁剪
 *
 *  @param scale 宽：高
 *
 *  return
 */
- (UIImage *)imageCropByScale:(CGFloat)scale;
- (UIImage *)imageByApplyingAlpha:(CGFloat)alpha;

- (UIImage *)imageByRotateRadians:(CGFloat)radians;
- (UIImage *)imageByRotateRadians:(CGFloat)radians size:(CGSize)size;
- (UIImage *)imageByRotateDegrees:(CGFloat)degrees;
- (UIImage *)imageByRotateDegrees:(CGFloat)degrees size:(CGSize)size;
+ (UIImage *)imageWithImage:(UIImage *)image rotateRadians:(CGFloat)radians;
+ (UIImage *)imageWithImage:(UIImage *)image rotateRadians:(CGFloat)radians size:(CGSize)size;
+ (UIImage *)imageWithImage:(UIImage *)image rotateDegrees:(CGFloat)degrees;
+ (UIImage *)imageWithImage:(UIImage *)image rotateDegrees:(CGFloat)degrees size:(CGSize)size;

+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

//切割图片
+ (UIImage *)clipImage:(UIImage *)image inRect:(CGRect)rect;

#if !APP_EXTENSION
+ (UIImage *)screenshot;
#endif

@end

#pragma mark - UIImage+Base64

@interface UIImage (Base64)

+ (instancetype)imageWithBase64String:(NSString *)base64String;

@end

#pragma mark - UIImageView+M9Category

@interface UIImageView (M9Category)

+ (instancetype)imageViewWithImageNamed:(NSString *)imageName;

@end
