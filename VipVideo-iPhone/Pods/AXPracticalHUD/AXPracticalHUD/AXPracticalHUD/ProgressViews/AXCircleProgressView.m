//
//  AXCircleProgressView.m
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

#import "AXCircleProgressView.h"

@implementation AXCircleProgressView
#pragma mark - Life cycle
- (instancetype)init {
    if (self = [super initWithFrame:CGRectMake(0, 0, 37, 37)]) {
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
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    
    _progress = 0.0;
    _progressBgnColor = [UIColor colorWithWhite:1 alpha:.1];
    _progressColor = [UIColor whiteColor];
    _annularEnabled = NO;
}

#pragma mark - Override
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    // Get a rect
    CGRect allRect = self.bounds;
    CGRect circleRect = CGRectInset(allRect, 2.0, 2.0);
    // Get current context
    CGContextRef context = UIGraphicsGetCurrentContext();
    // Draw
    if (_annularEnabled) {
        // draw background
        BOOL isPre_iOS_7_0 = kCFCoreFoundationVersionNumber <= kCFCoreFoundationVersionNumber_iOS_7_0;
        CGFloat lineWidth = isPre_iOS_7_0 ? 5.0 : 2.0;
        UIBezierPath *backgroundPath = [UIBezierPath bezierPath];
        backgroundPath.lineCapStyle = kCGLineCapButt;
        CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        CGFloat radius = (self.bounds.size.width - lineWidth) / 2;
        // 90degree
        CGFloat startAngle = -(M_PI) / 2;
        CGFloat endAngle = startAngle + (2.0 * M_PI);
        [backgroundPath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
        [_progressBgnColor set];
        [backgroundPath stroke];
        // draw progress
        UIBezierPath *progressPath = [UIBezierPath bezierPath];
        progressPath.lineCapStyle = isPre_iOS_7_0 ? kCGLineCapRound : kCGLineCapSquare;
        progressPath.lineWidth = lineWidth;
        endAngle = _progress * 2.0 * M_PI + startAngle;
        [progressPath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
        [_progressColor set];
        [progressPath stroke];
    } else {
        // draw background
        [_progressColor setStroke];
        [_progressBgnColor setFill];
        CGContextSetLineWidth(context, 2.0);
        CGContextFillEllipseInRect(context, circleRect);
        CGContextStrokeEllipseInRect(context, circleRect);
        // draw progress
        CGPoint center = CGPointMake(allRect.size.width / 2, allRect.size.height / 2);
        CGFloat radius = (allRect.size.width - 4.0) / 2;
        CGFloat startAngle = -(M_PI / 2);
        CGFloat endAngle = _progress * 2.0 * M_PI + startAngle;
        [_progressColor setFill];
        CGContextMoveToPoint(context, center.x, center.y);
        CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
        CGContextClosePath(context);
        CGContextFillPath(context);
    }
}
#pragma mark - Setters
- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:YES];
}

- (void)setProgressBgnColor:(UIColor *)progressBgnColor {
    _progressBgnColor = progressBgnColor;
    [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:YES];
}

- (void)setProgressColor:(UIColor *)progressColor {
    _progressColor = progressColor;
    [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:YES];
}

- (void)setAnnularEnabled:(BOOL)annularEnabled {
    _annularEnabled = annularEnabled;
    [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:YES];
}
@end
