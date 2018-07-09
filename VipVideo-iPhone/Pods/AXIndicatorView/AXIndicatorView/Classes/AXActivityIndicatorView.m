//
//  AXActivityIndicatorView.m
//  AXIndicatorView
//
//  Created by devedbox on 2016/10/7.
//  Copyright © 2016年 devedbox. All rights reserved.
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

#import "AXActivityIndicatorView.h"
@class _AXActivityIndicatorLayerView;
@interface AXActivityIndicatorView ()
/// Color index layer.
@property(strong, nonatomic) _AXActivityIndicatorLayerView *colorIndexLayerView;
@end
IB_DESIGNABLE
@interface _AXActivityIndicatorLayerView : UIView
/// Line width.
@property(assign, nonatomic) CGFloat lineWidth;
/// Drawing percent of the components.
@property(assign, nonatomic) int64_t drawingComponents;
/// Animating.
@property(assign, nonatomic) BOOL animating;
/// Should gradient color index.
@property(assign, nonatomic) BOOL shouldGradientColorIndex;
/// Begin angle offset.
@property(assign, nonatomic) CGFloat angleOffset;
- (void)drawComponents;
- (void)drawLineWithAngle:(CGFloat)angle context:(CGContextRef)context tintColor:(UIColor *)tintColor;
@end
@implementation AXActivityIndicatorView
@synthesize animating = _animating;
#pragma mark - Initializer
- (instancetype)init {
    if (self = [super init]) {
        [self initializer];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
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

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initializer];
}

- (void)initializer {
    self.lineWidth = 3.0;
    self.drawingComponents = 12;
    self.angleOffset = -(M_PI * 2 / _drawingComponents)*2;
    self.shouldGradientColorIndex = YES;
    
    [self addSubview:self.colorIndexLayerView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _colorIndexLayerView.frame = [self bounds];
}

#pragma mark - Getters
- (_AXActivityIndicatorLayerView *)colorIndexLayerView {
    if (_colorIndexLayerView) return _colorIndexLayerView;
    _colorIndexLayerView = [_AXActivityIndicatorLayerView new];
    _colorIndexLayerView.backgroundColor = [UIColor clearColor];
    _colorIndexLayerView.lineWidth = _lineWidth;
    _colorIndexLayerView.drawingComponents = _drawingComponents;
    _colorIndexLayerView.animating = _animating;
    _colorIndexLayerView.shouldGradientColorIndex = _shouldGradientColorIndex;
    _colorIndexLayerView.angleOffset = _angleOffset;
    return _colorIndexLayerView;
}

- (BOOL)isAnimating {
    return _animating;
}

#pragma mark - Setters
- (void)setLineWidth:(CGFloat)lineWidth {
    _lineWidth = lineWidth;
    self.colorIndexLayerView.lineWidth = _lineWidth;
    if (_animating) {
        [_colorIndexLayerView.layer removeAnimationForKey:@"transform.rotation"];
        [self addColorIndexAnimation];
    }
}

- (void)setDrawingComponents:(int64_t)drawingComponents {
    _drawingComponents = MIN(12, drawingComponents);
    self.colorIndexLayerView.drawingComponents = _drawingComponents;
    if (_animating) {
        [_colorIndexLayerView.layer removeAnimationForKey:@"transform.rotation"];
        [self addColorIndexAnimation];
    }
}

- (void)setShouldGradientColorIndex:(BOOL)shouldGradientColorIndex {
    _shouldGradientColorIndex = shouldGradientColorIndex;
    [self.colorIndexLayerView setShouldGradientColorIndex:_shouldGradientColorIndex];
    if (_animating) {
        [_colorIndexLayerView.layer removeAnimationForKey:@"transform.rotation"];
        [self addColorIndexAnimation];
    }
}

- (void)setAngleOffset:(CGFloat)angleOffset {
    _angleOffset = angleOffset;
    [self.colorIndexLayerView setAngleOffset:_angleOffset];
    if (_animating) {
        [_colorIndexLayerView.layer removeAnimationForKey:@"transform.rotation"];
        [self addColorIndexAnimation];
    }
}

- (void)setAnimating:(BOOL)animating {
    _animating = animating;
    self.colorIndexLayerView.animating = _animating;
    if (animating) {
        [self addColorIndexAnimation];
    } else {
        [_colorIndexLayerView.layer removeAnimationForKey:@"transform.rotation"];
    }
}

#pragma mark - Helper
- (void)didBecomActive:(id)noti {
    if (_animating) [self setAnimating:_animating];
}

- (void)addColorIndexAnimation {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    NSMutableArray *values = [@[] mutableCopy];
    for (int i = 0; i < _drawingComponents; i++) {
        [values addObject:@((i*M_PI/6)-M_PI_2+_angleOffset)];
    }
    animation.values = values;
    animation.duration = 1.0;
    animation.repeatCount = CGFLOAT_MAX;
    animation.calculationMode = kCAAnimationDiscrete;
    animation.removedOnCompletion = NO;
    [_colorIndexLayerView.layer addAnimation:animation forKey:@"transform.rotation"];
}
@end

@implementation _AXActivityIndicatorLayerView
- (void)setAnimating:(BOOL)animating {
    _animating = animating;
    [self setNeedsDisplay];
}

- (void)setDrawingComponents:(int64_t)drawingComponents {
    _drawingComponents = MIN(12, drawingComponents);
    [self setNeedsDisplay];
}

- (void)setShouldGradientColorIndex:(BOOL)shouldGradientColorIndex {
    _shouldGradientColorIndex = shouldGradientColorIndex;
    [self setNeedsDisplay];
}

- (void)setAngleOffset:(CGFloat)angleOffset {
    _angleOffset = angleOffset;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [self drawComponents];
}

- (void)drawComponents {
    // Get the 12 components of the bounds.
    CGFloat angle = M_PI*2/12;
    CGContextRef cxt = UIGraphicsGetCurrentContext();
    UIColor *tintColor = self.tintColor?:[UIColor blackColor];
    // Draw all the possilbe line using the proper tint color.
    for (int64_t i = 0; i < _drawingComponents; i++) [self drawLineWithAngle:angle*i-M_PI_2+_angleOffset context:cxt tintColor:/*_animating&&*/_shouldGradientColorIndex?[tintColor colorWithAlphaComponent:MAX(0.3, ((float)i)/_drawingComponents)]:tintColor];
}
#pragma mark - Helper
- (void)drawLineWithAngle:(CGFloat)angle context:(CGContextRef)context tintColor:(UIColor *)tintColor {
    CGContextSetStrokeColorWithColor(context, tintColor.CGColor);
    CGContextSetLineWidth(context, _lineWidth);
    CGContextSetLineCap(context, kCGLineCapRound);
    
    CGRect box = CGRectInset(self.bounds, _lineWidth/2, _lineWidth/2);
    CGFloat deatla = MIN(box.size.width, box.size.height);
    box.origin.x += fabs(box.size.width-deatla)*.5;
    box.origin.y += fabs(box.size.height-deatla)*.5;
    box.size.width = deatla;
    box.size.height = deatla;
    
    // Get the begin point of the bounds.
    CGFloat radius = CGRectGetWidth(box)/2;
    CGFloat inner = radius * 0.5+_lineWidth/2;
    CGPoint beginPoint = CGPointMake(self.center.x-self.frame.origin.x+inner*cos(angle), self.center.y-self.frame.origin.y+inner*sin(angle));
    CGPoint endPoint = CGPointMake(self.center.x-self.frame.origin.x+radius*cos(angle), self.center.y-self.frame.origin.y+radius*sin(angle));
    
    CGContextMoveToPoint(context, beginPoint.x, beginPoint.y);
    CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
    
    CGContextStrokePath(context);
}
@end
