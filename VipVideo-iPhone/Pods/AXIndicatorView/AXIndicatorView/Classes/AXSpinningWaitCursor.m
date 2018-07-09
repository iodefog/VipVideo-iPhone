//
//  AXSpinningWaitCursor.m
//  AXIndicatorView
//
//  Created by devedbox on 2017/5/14.
//  Copyright © 2017年 devedbox. All rights reserved.
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

#import "AXSpinningWaitCursor.h"

@interface AXSpinningWaitCursor ()
/// Image view.
@property(strong, nonatomic) UIImageView *imageView;
@end

@implementation AXSpinningWaitCursor
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
    _duration = 1.0;
    [self addSubview:self.imageView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Override.
- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_imageView setFrame:self.bounds];
}

#pragma mark - Getters.
- (UIImageView *)imageView {
    if (_imageView) return _imageView;
    UIImage *image;
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_8_0
    image = [UIImage imageNamed:@"AXIndicatorView.bundle/SpinningWaitCursor"];
#else
    image = [UIImage imageNamed:@"AXIndicatorView.bundle/SpinningWaitCursor" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
#endif
    _imageView = [[UIImageView alloc] initWithImage:image];
    _imageView.contentMode = UIViewContentModeCenter;
    return _imageView;
}

#pragma mark - Setters.
- (void)setAnimating:(BOOL)animating {
    _animating = animating;
    
    if (_animating) {
        [self _addAnimation];
    } else {
        [self.imageView.layer removeAnimationForKey:@"rotate"];
    }
}

- (void)setDuration:(NSTimeInterval)duration {
    _duration = duration;
    
    if (_animating) {
        [self.imageView.layer removeAnimationForKey:@"rotate"];
        [self _addAnimation];
    }
}

- (void)_didBecomeActive:(id)arg {
    if (_animating) [self setAnimating:_animating];
}

- (void)_addAnimation {
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotate.toValue = @(M_PI*2);
    rotate.duration = _duration;
    rotate.repeatCount = CGFLOAT_MAX;
    rotate.removedOnCompletion = NO;
    [self.imageView.layer addAnimation:rotate forKey:@"rotate"];
}
@end
