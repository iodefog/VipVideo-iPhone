//
//  AXGradientProgressView.m
//  AXPracticalHUD
//
//  Created by ai on 9/7/15.
//  Copyright © 2015 ai. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "AXGradientProgressView.h"

@interface AXGradientProgressView()<CAAnimationDelegate>
@property(strong, nonatomic) CAGradientLayer *gradientLayer;
@property(strong, nonatomic) CADisplayLink *displayLink;
@end

@implementation AXGradientProgressView
#pragma mark - Life cycle
- (instancetype)init {
    if (self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 1.0)]) {
        [self initializer];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initializer];
    }
    return self;
}

- (void)initializer {
    _progress = 0.0;
    _progressHeight = 1.0;
    _colors = [[[self class] defaultColors] mutableCopy];
    _duration = 0.08;
    
    [self.layer addSublayer:self.gradientLayer];
}

- (void)dealloc {
    [_displayLink invalidate];
    _displayLink = nil;
}
#pragma mark - Override
- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    if (self.superview) {
        [self beginAnimating];
    } else {
        [self endAnimating];
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize aSize = [super sizeThatFits:size];
    aSize.height = _progressHeight;
    return aSize;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self sizeToFit];
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
    
    CGRect rect = _gradientLayer.frame;
    rect.size.width = self.bounds.size.width * MIN(_progress, 1.0);
    rect.size.height = self.bounds.size.height;
    _gradientLayer.frame = rect;
}

#pragma mark - Public
- (void)beginAnimating {
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)endAnimating {
    [_displayLink invalidate];
    _displayLink = nil;
}

#pragma mark - Getters & Setters
- (CAGradientLayer *)gradientLayer {
    if (_gradientLayer) return _gradientLayer;
    _gradientLayer = [CAGradientLayer layer];
    _gradientLayer.startPoint = CGPointMake(0.0, 0);
    _gradientLayer.endPoint = CGPointMake(1.0, 0);
    _gradientLayer.colors = [_colors copy];
    _gradientLayer.type = kCAGradientLayerAxial;
    return _gradientLayer;
}

- (CADisplayLink *)displayLink {
    if (_displayLink) return _displayLink;
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplayLink:)];
    if (@available(iOS 10.0, *)) {
        self.displayLink.preferredFramesPerSecond = 60;
    } else {
        self.displayLink.frameInterval = 1;
    }
    return _displayLink;
}

- (void)setColors:(NSMutableArray *)colors {
    _colors = colors;
    _gradientLayer.colors = _colors;
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:YES];
}

- (void)setProgressHeight:(CGFloat)progressHeight {
    _progressHeight = progressHeight;
}
#pragma mark - Private helper
- (void)handleDisplayLink:(CADisplayLink *)sender {
    NSMutableArray *colors = [_gradientLayer.colors mutableCopy];
    CGColorRef color = (__bridge CGColorRef)([colors lastObject]);
    [colors removeLastObject];
    [colors insertObject:(__bridge id)(color) atIndex:0];
    _gradientLayer.colors = [colors copy];
}

+ (NSMutableArray *)defaultColors {
    NSMutableArray *colors = [NSMutableArray array];
    NSInteger hue = 1;
    while (hue <= 360) {
        UIColor *color = [[UIColor alloc] initWithHue:1.0 * hue / 360.0 saturation:1.0 brightness:1.0 alpha:1.0];
        [colors addObject:(__bridge id)(color.CGColor)];
        hue += 5;
    }
    return colors;
}
@end
