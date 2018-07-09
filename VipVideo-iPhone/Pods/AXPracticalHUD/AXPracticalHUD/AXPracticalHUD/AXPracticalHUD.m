//
//  AXPracticalHUD.m
//  AXSwift2OC
//
//  Created by ai on 9/7/15.
//  Copyright © 2015 ai. All rights reserved.
//

#import "AXPracticalHUD.h"
#import "AXBarProgressView.h"
#import "AXCircleProgressView.h"
#import "AXGradientProgressView.h"
#import "AXPracticalHUDAnimator.h"
#import <AXIndicatorView/AXIndicatorView.h>

#ifndef kCFCoreFoundationVersionNumber_iOS_8_0
#define kCFCoreFoundationVersionNumber_iOS_8_0 1140.1
#endif
#ifndef EXECUTE_ON_MAIN_THREAD
#define EXECUTE_ON_MAIN_THREAD(block) \
if ([NSThread isMainThread]) {\
    block();\
} else {\
    dispatch_async(dispatch_get_main_queue(), block);\
}
#endif

#ifndef kAXPracticalHUDPadding
#define kAXPracticalHUDPadding 4.0f
#endif
#ifndef kAXPracticalHUDMaxMovement
#define kAXPracticalHUDMaxMovement 14.0f
#endif
#ifndef kAXPracticalHUDFontSize
#define kAXPracticalHUDFontSize 14.0f
#endif
#ifndef kAXPracticalHUDDetailFontSize
#define kAXPracticalHUDDetailFontSize 12.0f
#endif
#ifndef kAXPracticalHUDDefaultMargin
#define kAXPracticalHUDDefaultMargin 15.0f
#endif

@interface AXPracticalHUD()
{
    /// Title label.
    UILabel *_label;
    /// Detail text label.
    UILabel *_detailLabel;
    /// Content view of HUD.
    AXPracticalHUDContentView *_contentView;
    /// Indicate is animating or not of the HUD view.
    BOOL _animated;
    
    BOOL _isFinished;
    SEL _executedMethod;
    id _executedTarget;
    id _executedObject;
    CGAffineTransform _rotationTransform;
}
/// Grace planned timer.
@property(strong, nonatomic) NSTimer *graceTimer;
/// Min show planned timer.
@property(strong, nonatomic) NSTimer *minShowTimer;
/// Date of show's starting.
@property(strong, nonatomic) NSDate *showStarted;
/// Frame of content field.
@property(readonly, nonatomic) CGRect contentFrame;
/// Indocator view.
@property(strong, nonatomic) UIView *indicator;
// Motions:
@property(strong, nonatomic) UIInterpolatingMotionEffect *xMotionEffect;
@property(strong, nonatomic) UIInterpolatingMotionEffect *yMotionEffect;
/// Is the hud is animating.
@property(assign, nonatomic) BOOL forbidsLayoutSubviews;
@end

@implementation AXPracticalHUD
#pragma mark - Life cycle
- (instancetype)init {
    if (self = [super initWithFrame:CGRectZero]) {
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

- (instancetype)initWithView:(UIView *)view {
    return [self initWithFrame:view.bounds];
}

- (instancetype)initWithWindow:(UIWindow *)window {
    return [self initWithView:window];
}

- (void)initializer {
    _restoreEnabled = NO;
    _lockBackground = NO;
    _size = CGSizeZero;
    _square = NO;
    _margin = kAXPracticalHUDDefaultMargin;
    _offsets = CGPointZero;
    _minimumSize = CGSizeZero;
    _grace = 0.0f;
    _threshold = 0.5f;
    _dimBackground = NO;
    _contentInsets = UIEdgeInsetsMake(15.0f, 15.0f, 15.0f, 15.0f);
    _progressing = NO;
    
    _mode = AXPracticalHUDModeNormal;
    _position = AXPracticalHUDPositionCenter;
    _progress = 0.0f;
    _removeFromSuperViewOnHide = YES;
    
    _animated = NO;
    _isFinished = NO;
    _rotationTransform = CGAffineTransformIdentity;
    
    self.tintColor = [UIColor whiteColor];
    self.alpha = 0.0f;
    self.opaque = NO;
    self.contentMode = UIViewContentModeCenter;
    self.backgroundColor = [UIColor clearColor];
    
    self.autoresizingMask =
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleBottomMargin |
    UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleRightMargin;
    
    [self addSubview:self.contentView];
    [_contentView addSubview:self.label];
    [_contentView addSubview:self.detailLabel];
    [self setupIndicators];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(statusBarOrientationDidChange:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
}

#pragma mark - Override

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    if (self.superview) {
        // Layout subviews.
        [self setNeedsLayout];
        [self layoutIfNeeded];
        
        if ([_indicator isKindOfClass:[AXGradientProgressView class]] &&
            [_indicator respondsToSelector:@selector(beginAnimating)])
        {
            [_indicator performSelector:@selector(beginAnimating)];
        }
        
        if (_position == AXPracticalHUDPositionCenter) {
            _contentView.motionEffects = @[self.xMotionEffect, self.yMotionEffect];
        } else {
            [_contentView removeMotionEffect:_xMotionEffect];
            [_contentView removeMotionEffect:_yMotionEffect];
        }
        [self updateForCurrentOrientationAnimated:NO];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (_lockBackground) {
        return hitView;
    } else {
        if (CGRectContainsPoint(self.contentFrame, point)) {
            return hitView;
        } else {
            return nil;
        }
    }
    return nil;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    
    if (_dimBackground) {
        //Gradient colours
        size_t gradLocNum = 2;
        CGFloat gradLocs[2] = {0.0, 1.0};
        CGFloat gradColors[8] = {0.0, 0.0, 0.0, 0.3, 0.0, 0.0, 0.0, 0.3};
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, gradColors, gradLocs, gradLocNum);
        //Gradient center
        CGPoint gradCenter = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        //Gradient radius
        CGFloat gradRadius = MIN(self.bounds.size.width, self.bounds.size.height);
        //Gradient draw
        CGContextDrawRadialGradient (context, gradient, gradCenter, 0, gradCenter, gradRadius, kCGGradientDrawsAfterEndLocation);
        
        CGColorSpaceRelease(colorSpace);
        CGGradientRelease(gradient);
    }
    
    UIGraphicsPopContext();
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (_forbidsLayoutSubviews) {
        return;
    }
    
    if (self.superview) {
        self.frame = self.superview.bounds;
    }
    // Get bounds
    CGRect bounds = self.bounds;
    
    CGFloat maxWidth = CGRectGetWidth(bounds) - _contentInsets.left - _contentInsets.right - 2 * _margin;
    
    CGRect rect_indicator = CGRectZero;
    if (_indicator) {
        rect_indicator = _indicator.frame;
    }
    
    CGSize size = [_label.text boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                            options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                         attributes:@{NSFontAttributeName : _label.font}
                                            context:nil].size;
    CGRect rect_label = CGRectMake(0, 0, ceil(size.width), ceil(size.height));
    
    size = [_detailLabel.text boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                           options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                        attributes:@{NSFontAttributeName : _detailLabel.font}
                                           context:nil].size;
    CGRect rect_detail = CGRectMake(0, 0, ceil(size.width), ceil(size.height));
    
    CGFloat height_content = rect_indicator.size.height + rect_label.size.height + rect_detail.size.height;
    height_content += _contentInsets.top + _contentInsets.bottom;
    if (rect_label.size.height > 0) {
        height_content += kAXPracticalHUDPadding;
    }
    if (rect_detail.size.height > 0) {
        height_content += kAXPracticalHUDPadding;
    }
    
    CGFloat width_content = 0.0;
    if (_position == AXPracticalHUDPositionTop || _position == AXPracticalHUDPositionBottom) {
        width_content = maxWidth + _contentInsets.left + _contentInsets.right;
    } else {
        width_content = MIN(maxWidth, MAX(rect_indicator.size.width, MAX(rect_label.size.width, rect_detail.size.width))) + _contentInsets.left + _contentInsets.right;
    }
    
    CGSize size_content = CGSizeMake(width_content, height_content);
    
    CGFloat height_diff = 0.0;
    
    if (_square) {
        CGFloat maxValue = MAX(width_content, height_content);
        height_diff = (maxValue-height_content)*.5;
        if (maxValue <= (bounds.size.width - 2 * _margin)) {
            size_content.width = maxValue;
        }
        if (maxValue <= (bounds.size.height - 2 * _margin)) {
            size_content.height = maxValue;
        }
    }
    
    if (size_content.width < _minimumSize.width) {
        size_content.width = _minimumSize.width;
    }
    if (size_content.height < _minimumSize.height) {
        height_diff = (_minimumSize.height - size_content.height)*.5;
        size_content.height = _minimumSize.height;
    }
    
    _size = size_content;
    
    rect_indicator.origin.y = _contentInsets.top + height_diff;
    rect_indicator.origin.x = round(_size.width - rect_indicator.size.width) / 2;
    _indicator.frame = rect_indicator;
    
    rect_label.origin.y = rect_label.size.height > 0.0 ? CGRectGetMaxY(rect_indicator) + kAXPracticalHUDPadding : CGRectGetMaxY(rect_indicator);
    rect_label.origin.x = round((_size.width - rect_label.size.width) / 2) + _contentInsets.left - _contentInsets.right;
    _label.frame = rect_label;
    
    rect_detail.origin.y = rect_detail.size.height > 0.0 ? CGRectGetMaxY(rect_label) + kAXPracticalHUDPadding : CGRectGetMaxY(rect_label);
    rect_detail.origin.x = round((_size.width - rect_detail.size.width) / 2) + _contentInsets.left - _contentInsets.right;
    _detailLabel.frame = rect_detail;
    
    // Set the frame by applying the transform of the contview.
    _contentView.frame = self.contentFrame;
}

#pragma mark - Public
- (void)show:(BOOL)animated {
    [self show:animated executingBlock:nil onQueue:nil completion:nil];
}

- (void)hide:(BOOL)animated {
    [self hide:animated afterDelay:0.0 completion:nil];
}

- (void)show:(BOOL)animated executingBlockOnGQ:(dispatch_block_t)executing completion:(AXPracticalHUDCompletionBlock)completion
{
    [self show:animated executingBlock:executing onQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0) completion:completion];
}

- (void)show:(BOOL)animated executingBlock:(dispatch_block_t)executing onQueue:(dispatch_queue_t)queue completion:(AXPracticalHUDCompletionBlock)completion
{
    _animated = animated;
    _completion = [completion copy];
    
    if (executing) {
        _progressing = YES;
        dispatch_async(queue, ^{
            executing();
            dispatch_async(dispatch_get_main_queue(), ^{
                [self clear];
            });
        });
    }
    
    // If the grace time is set postpone the HUD display
    if (_grace > 0.0) {
        /*
        NSTimer *newGraceTimer = [NSTimer timerWithTimeInterval:_grace target:self selector:@selector(handleGraceTimer:) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:newGraceTimer forMode:NSRunLoopCommonModes];
        _graceTimer = newGraceTimer;
         */
        [self performSelector:animated?@selector(_showingByAnimated):@selector(_showingWithoutAnimated) withObject:nil afterDelay:_grace];
    } else {
        // ... otherwise show the HUD imediately
        [self showingAnimated:animated];
    }
}

- (void)show:(BOOL)animated executingMethod:(SEL)method toTarget:(id)target withObject:(id)object
{
    _executedMethod = method;
    _executedTarget = target;
    _executedObject = object;
    // Launch execution in new thread
    _progressing = YES;
    [NSThread detachNewThreadSelector:@selector(executing) toTarget:self withObject:nil];
    // Show HUD view
    [self show:YES];
}

- (void)hide:(BOOL)animated afterDelay:(NSTimeInterval)delay completion:(void (^)(void))completion
{
    _animated = animated;
    _completion = [completion copy];
    
    NSTimeInterval timeInterval = delay;
    
    // If the minShow time is set, calculate how long the hud was shown,
    // and pospone the hiding operation if necessary
    if (_threshold > 0.0 && _showStarted) {
        NSTimeInterval interv = [[NSDate date] timeIntervalSinceDate:_showStarted];
        if (interv < _threshold) {
            /*
            _minShowTimer = [NSTimer scheduledTimerWithTimeInterval:_threshold - interv target:self selector:@selector(handleMinShowTimer:) userInfo:nil repeats:NO];
             */
            timeInterval = MAX(_threshold - interv, delay);
        }
    }
    
    // ... otherwise hide the HUD after the delay.
    [self performSelector:animated?@selector(_hidingByAnimated):@selector(_hidingWithoutAnimated) withObject:nil afterDelay:timeInterval];
}

#pragma mark - Setters

- (void)setMode:(AXPracticalHUDMode)mode {
    _mode = mode;
    [self performSelectorOnMainThread:@selector(setupIndicators) withObject:nil waitUntilDone:YES];
    [self performSelectorOnMainThread:@selector(setNeedsLayout) withObject:nil waitUntilDone:YES];
    [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:YES];
}

- (void)setPosition:(AXPracticalHUDPosition)position {
    _position = position;
    if (_position == AXPracticalHUDPositionCenter) {
        _contentView.motionEffects = @[self.xMotionEffect, self.yMotionEffect];
    } else {
        [_contentView removeMotionEffect:_xMotionEffect];
        [_contentView removeMotionEffect:_yMotionEffect];
    }
    [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:YES];
    [self performSelectorOnMainThread:@selector(setNeedsLayout) withObject:nil waitUntilDone:YES];
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    if ([_indicator isKindOfClass:[AXBarProgressView class]] ||
        [_indicator isKindOfClass:[AXCircleProgressView class]] ||
        [_indicator isKindOfClass:[AXGradientProgressView class]])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_indicator setValue:@(_progress) forKey:@"progress"];
        });
    }
}

- (void)setCustomView:(UIView *)customView {
    _customView = customView;
    [self performSelectorOnMainThread:@selector(setupIndicators) withObject:nil waitUntilDone:YES];
    [self performSelectorOnMainThread:@selector(setNeedsLayout) withObject:nil waitUntilDone:YES];
    [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:YES];
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    
    [self performSelectorOnMainThread:@selector(setupIndicators) withObject:nil waitUntilDone:YES];
    [self performSelectorOnMainThread:@selector(setNeedsLayout) withObject:nil waitUntilDone:YES];
    [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:YES];
}
#pragma mark - Getters
- (CGRect)contentFrame {
    CGSize size = _size;
    switch (_position) {
        case AXPracticalHUDPositionTop: {
            CGPoint origin = CGPointMake(round((self.bounds.size.width - size.width) / 2) + _offsets.x, 0 + _offsets.y);
            return CGRectMake(origin.x, origin.y, size.width, size.height);
        }
        case AXPracticalHUDPositionCenter: {
            CGPoint origin = CGPointMake(round((self.bounds.size.width - size.width) / 2) + _offsets.x, round((self.bounds.size.height - size.height) / 2) + _offsets.y);
            return  CGRectMake(origin.x, origin.y, size.width, size.height);
        }
        case AXPracticalHUDPositionBottom: {
            CGPoint origin;
            if (self.superview) {
                origin = CGPointMake(round((self.bounds.size.width - size.width) / 2) + _offsets.x, self.superview.bounds.size.height - size.height + _offsets.y);
            } else {
                origin = CGPointMake(round((self.bounds.size.width - size.width) / 2) + _offsets.x, round((self.bounds.size.height - size.height) / 2) + _offsets.y);
            }
            return CGRectMake(origin.x, origin.y, size.width, size.height);
        }
        default:
            return CGRectZero;
    }
}

- (UILabel *)label {
    if (_label) return _label;
    _label = [[UILabel alloc] initWithFrame:self.bounds];
    _label.adjustsFontSizeToFitWidth = NO;
    _label.textAlignment = NSTextAlignmentCenter;
    _label.opaque = NO;
    _label.backgroundColor = [UIColor clearColor];
    _label.textColor = [UIColor whiteColor];
    _label.font = [UIFont boldSystemFontOfSize:kAXPracticalHUDFontSize];
    return _label;
}

- (UILabel *)detailLabel {
    if (_detailLabel) return _detailLabel;
    _detailLabel = [[UILabel alloc] initWithFrame:self.bounds];
    _detailLabel.adjustsFontSizeToFitWidth = NO;
    _detailLabel.textAlignment = NSTextAlignmentCenter;
    _detailLabel.opaque = NO;
    _detailLabel.backgroundColor = [UIColor clearColor];
    _detailLabel.numberOfLines = 0;
    _detailLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.75];
    _detailLabel.font = [UIFont boldSystemFontOfSize:kAXPracticalHUDDetailFontSize];
    return _detailLabel;
}

- (UIInterpolatingMotionEffect *)xMotionEffect {
    if (_xMotionEffect) return _xMotionEffect;
    _xMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    _xMotionEffect.minimumRelativeValue = @(-kAXPracticalHUDMaxMovement);
    _xMotionEffect.maximumRelativeValue = @(kAXPracticalHUDMaxMovement);
    return _xMotionEffect;
}

- (UIInterpolatingMotionEffect *)yMotionEffect {
    if (_yMotionEffect) return _yMotionEffect;
    _yMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    _yMotionEffect.minimumRelativeValue = @(-kAXPracticalHUDMaxMovement);
    _yMotionEffect.maximumRelativeValue = @(kAXPracticalHUDMaxMovement);
    return _yMotionEffect;
}

- (AXPracticalHUDContentView *)contentView {
    if (_contentView) return _contentView;
    _contentView = [[AXPracticalHUDContentView alloc] initWithFrame:CGRectZero];
    _contentView.layer.cornerRadius = 4.0;
    _contentView.layer.masksToBounds = true;
    return _contentView;
}

#pragma mark - Private helper
- (void)showingAnimated:(BOOL)animated {
    if (_delegate && [_delegate respondsToSelector:@selector(HUDWillShow:)]) {
        [_delegate HUDWillShow:self];
    }
    // Cancel any scheduled hideDelayed: calls
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelectorOnMainThread:@selector(setNeedsDisplay)
                           withObject:nil
                        waitUntilDone:YES];
    [self performSelectorOnMainThread:@selector(setNeedsLayout)
                           withObject:nil
                        waitUntilDone:YES];
    [self performSelectorOnMainThread:@selector(layoutIfNeeded)
                           withObject:nil
                        waitUntilDone:YES];
    
    id<AXPracticalHUDAnimator> animator = _animator?:AXPracticalHUDFadeAnimator();
    _showStarted = [NSDate date];
    [self setForbidsLayoutSubviews:!animator.allowsLayoutSubviewsDuringAnimation];
    // Animating
    [animator hud:self animate:animated isHidden:NO];
    if (animated) {
        [self performSelector:@selector(setForbidsLayoutSubviews:)
                   withObject:@(NO)
                   afterDelay:[animator durationForTransition:NO]];
    } else {
        [self setForbidsLayoutSubviews:NO];
    }
}

- (void)_showingByAnimated {
    [self showingAnimated:YES];
}

- (void)_showingWithoutAnimated {
    [self showingAnimated:NO];
}

- (void)hidingAnimated:(BOOL)animated {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    id<AXPracticalHUDAnimator> animator = _animator?:AXPracticalHUDFadeAnimator();
    [self setForbidsLayoutSubviews:YES];
    [animator hud:self
          animate:animated
         isHidden:YES];
    
    if (animated) {
        [self performSelector:@selector(setForbidsLayoutSubviews:)
                   withObject:@(NO)
                   afterDelay:[animator durationForTransition:YES]];
        [self performSelector:@selector(completed)
                   withObject:nil
                   afterDelay:[animator durationForTransition:YES]];
    } else {
        [self setForbidsLayoutSubviews:NO];
        [self completed];
    }
}

- (void)_hidingByAnimated {
    [self hidingAnimated:YES];
}

- (void)_hidingWithoutAnimated {
    [self hidingAnimated:NO];
}

- (void)setupIndicators {
    switch (_mode) {
        case AXPracticalHUDModeNormal:
            if (![_indicator isKindOfClass:[AXActivityIndicatorView class]]) {
                [_indicator removeFromSuperview];
                _indicator = [[AXActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 37, 37)];
                _indicator.backgroundColor = [UIColor clearColor];
            }
            [(AXActivityIndicatorView *)_indicator setLineWidth:3];
            [(AXActivityIndicatorView *)_indicator setDrawingComponents:12];
            [(AXActivityIndicatorView *)_indicator setShouldGradientColorIndex:YES];
            [(AXActivityIndicatorView *)_indicator setTintColor:self.tintColor];
            [(AXActivityIndicatorView *)_indicator setAnimating:YES];
            [_contentView addSubview:_indicator];
            break;
        case AXPracticalHUDModeBreachedRing: {
            if (![_indicator isKindOfClass:[AXBreachedAnnulusIndicatorView class]]) {
                [_indicator removeFromSuperview];
                _indicator = [[AXBreachedAnnulusIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 37, 37)];
                _indicator.backgroundColor = [UIColor clearColor];
                [_contentView addSubview:_indicator];
            }
            [(AXBreachedAnnulusIndicatorView *)_indicator setTintColor:self.tintColor];
            [(AXBreachedAnnulusIndicatorView *)_indicator setAnimating:YES];
        }
            break;
        case AXPracticalHUDModeProgressBar:
            [_indicator removeFromSuperview];
            _indicator = [[AXBarProgressView alloc] init];
            [_indicator setValue:self.tintColor forKey:@"lineColor"];
            [_indicator setValue:self.tintColor forKey:@"progressColor"];
            [_contentView addSubview:_indicator];
            break;
        case AXPracticalHUDModeProgress:
        case AXPracticalHUDModeProgressRing:
            if (![_indicator isKindOfClass:[AXCircleProgressView class]]) {
                [_indicator removeFromSuperview];
                _indicator = [[AXCircleProgressView alloc] init];
                [_indicator setValue:self.tintColor forKey:@"progressColor"];
                [_contentView addSubview:_indicator];
            }
            if (_mode == AXPracticalHUDModeProgressRing) {
                [_indicator setValue:@(YES) forKey:@"annularEnabled"];
            }
            break;
        case AXPracticalHUDModeCustomView:
            [_indicator removeFromSuperview];
            _indicator = _customView;
            if (_indicator) [_contentView addSubview:_indicator];
            break;
        case AXPracticalHUDModeColourfulProgressBar:
            [_indicator removeFromSuperview];
            _indicator = [[AXGradientProgressView alloc] init];
            [_indicator setValue:@(2.0) forKey:@"progressHeight"];
            [_contentView addSubview:_indicator];
            break;
        default:
            [_indicator removeFromSuperview];
            _indicator = nil;
            break;
    }
}

- (void)completed {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    _isFinished = YES;
    self.alpha = .0;
    if ([_indicator isKindOfClass:[AXGradientProgressView class]] && [_indicator respondsToSelector:@selector(endAnimating)]) {
        [_indicator performSelector:@selector(endAnimating)];
    }
    if (_removeFromSuperViewOnHide) {
        [self removeFromSuperview];
    }
    if (_restoreEnabled) {
        [self restore];
    }
    self.transform = CGAffineTransformIdentity;
    _contentView.transform = CGAffineTransformIdentity;
    if (_completion) {
        EXECUTE_ON_MAIN_THREAD(^{
            _completion();
        });
    }
    if (_delegate && [_delegate respondsToSelector:@selector(HUDDidHidden:)]) {
        [_delegate HUDDidHidden:self];
    }
}

- (void)statusBarOrientationDidChange:(NSNotification *)aNotification {
    
}

- (void)handleGraceTimer:(NSTimer *)sender {
    if (_progressing) {
        [self showingAnimated:_animated];
    }
}

- (void)handleMinShowTimer:(NSTimer *)sender {
    [self hidingAnimated:_animated];
}

- (void)executing {
    @autoreleasepool {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        // Start executing the requested task
        [_executedTarget performSelector:_executedMethod withObject:_executedObject];
#pragma clang diagnostic pop
        // Task completed, update view in main thread (note: view operations should
        // be done only in the main thread
        [self performSelectorOnMainThread:@selector(clear) withObject:nil waitUntilDone:NO];
    }
}

- (void)clear {
    _progressing = NO;
    _executedMethod = nil;
    _executedObject = nil;
    _executedTarget = nil;

    [self hide:YES];
}

- (void)restore {
    self.label.text = nil;
    self.detailLabel.text = nil;
    [self initializer];
}

- (void)updateForCurrentOrientationAnimated:(BOOL)animated {
    // Stay in sync with the superview in any case
    if (self.superview) {
        self.bounds = self.superview.bounds;
        [self performSelectorOnMainThread:@selector(setNeedsDisplay)
                               withObject:nil
                            waitUntilDone:YES];
    }
    
    // Not needed on iOS 8+, compile out when the deployment target allows,
    // to avoid sharedApplication problems on extension targets
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 80000
    // Only needed pre iOS 7 when added to a window
    BOOL iOS8OrLater = kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0;
    if (iOS8OrLater || ![self.superview isKindOfClass:[UIWindow class]]) return;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGFloat radians = 0;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        if (orientation == UIInterfaceOrientationLandscapeLeft) { radians = -(CGFloat)M_PI_2; }
        else { radians = (CGFloat)M_PI_2; }
        // Window coordinates differ!
        self.bounds = CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.width);
    } else {
        if (orientation == UIInterfaceOrientationPortraitUpsideDown) { radians = (CGFloat)M_PI; }
        else { radians = 0; }
    }
    _rotationTransform = CGAffineTransformMakeRotation(radians);
    
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
    }
    [self setTransform:_rotationTransform];
    if (animated) {
        [UIView commitAnimations];
    }
#endif
}
@end

@implementation AXPracticalHUD(Shared)
+ (instancetype)sharedHUD {
    static id _sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (void)showProgressInView:(UIView *)view {
    [self showProgressInView:view
                        text:nil
                      detail:nil
               configuration:nil];
}
- (void)showProgressBarInView:(UIView *)view {
    [self showProgressInView:view
                        text:nil
                      detail:nil
               configuration:nil];
}
- (void)showColorfulProgressBarInView:(UIView *)view; {
    [self showColorfulProgressBarInView:view
                                   text:nil
                                 detail:nil
                          configuration:nil];
}
- (void)showTextInView:(UIView *)view {
    [self showTextInView:view
                    text:nil
                  detail:nil
           configuration:nil];
}
- (void)showNormalInView:(UIView *)view {
    [self showNormalInView:view
                      text:nil
                    detail:nil
             configuration:nil];
}
- (void)showErrorInView:(UIView *)view {
    [self showErrorInView:view
                     text:nil
                   detail:nil
            configuration:nil];
}
- (void)showSuccessInView:(UIView *)view {
    [self showSuccessInView:view
                       text:nil
                     detail:nil
              configuration:nil];
}

- (void)showProgressInView:(UIView *)view text:(NSString *)text detail:(NSString *)detail configuration:(void(^)(AXPracticalHUD *HUD))configuration
{
    [self _showInView:view
             animated:YES
                 mode:AXPracticalHUDModeProgress
                 text:text
               detail:detail customView:nil configuration:configuration];
}
- (void)showProgressBarInView:(UIView *)view text:(NSString *)text detail:(NSString *)detail configuration:(void(^)(AXPracticalHUD *HUD))configuration
{
    [self _showInView:view
             animated:YES
                 mode:AXPracticalHUDModeProgressBar
                 text:text
               detail:detail
           customView:nil
        configuration:configuration];
}
- (void)showColorfulProgressBarInView:(UIView *)view text:(NSString *)text detail:(NSString *)detail configuration:(void(^)(AXPracticalHUD *HUD))configuration
{
    [self _showInView:view
             animated:YES
                 mode:AXPracticalHUDModeColourfulProgressBar
                 text:text
               detail:detail
           customView:nil
        configuration:configuration];
}
- (void)showTextInView:(UIView *)view text:(NSString *)text detail:(NSString *)detail configuration:(void(^)(AXPracticalHUD *HUD))configuration
{
    [self _showInView:view
             animated:YES
                 mode:AXPracticalHUDModeText
                 text:text
               detail:detail
           customView:nil
        configuration:configuration];
}
- (void)showNormalInView:(UIView *)view text:(NSString *)text detail:(NSString *)detail configuration:(void(^)(AXPracticalHUD *HUD))configuration
{
    [self _showInView:view
             animated:YES
                 mode:AXPracticalHUDModeNormal
                 text:text
               detail:detail
           customView:nil
        configuration:configuration];
}
- (void)showErrorInView:(UIView *)view text:(NSString *)text detail:(NSString *)detail configuration:(void(^)(AXPracticalHUD *HUD))configuration
{
    UIImage *image;
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_8_0
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AXPracticalHUD.bundle/ax_hud_error"]];
    image = [UIImage imageNamed:@"AXPracticalHUD.bundle/ax_hud_error"];
#else
    image = [UIImage imageNamed:@"AXPracticalHUD.bundle/ax_hud_error" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
#endif
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGContextClipToMask(context, rect, image.CGImage);
    [self.tintColor?:[UIColor whiteColor] setFill];
    CGContextFillRect(context, rect);
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [imageView setFrame:CGRectMake(0, 0, 37, 37)];
    [self _showInView:view animated:YES mode:AXPracticalHUDModeCustomView text:text detail:detail customView:imageView configuration:configuration];
}
- (void)showSuccessInView:(UIView *)view text:(NSString *)text detail:(NSString *)detail configuration:(void(^)(AXPracticalHUD *HUD))configuration
{
    UIImage *image;
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_8_0
    image = [UIImage imageNamed:@"AXPracticalHUD.bundle/ax_hud_success"];
#else
    image = [UIImage imageNamed:@"AXPracticalHUD.bundle/ax_hud_success" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
#endif
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGContextClipToMask(context, rect, image.CGImage);
    [self.tintColor?:[UIColor whiteColor] setFill];
    CGContextFillRect(context, rect);
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [imageView setFrame:CGRectMake(0, 0, 37, 37)];
    [self _showInView:view animated:YES mode:AXPracticalHUDModeCustomView text:text detail:detail customView:imageView configuration:configuration];
}

#pragma mark - Private
- (void)_showInView:(UIView *)view animated:(BOOL)animated mode:(AXPracticalHUDMode)mode text:(NSString *)text detail:(NSString *)detail customView:(UIView *)customView configuration:(void(^)(AXPracticalHUD *HUD))configuration
{
    self.mode = mode;
    self.label.text = text;
    self.customView = customView;
    self.detailLabel.text = detail;
    [view addSubview:self];
    if (configuration) {
        configuration(self);
    }
    [self show:animated];
}
@end

@implementation AXPracticalHUD(Convenence)
+ (instancetype)showHUDInView:(UIView *)view animated:(BOOL)animated {
    AXPracticalHUD *hud = [[AXPracticalHUD alloc] initWithView:view];
    hud.removeFromSuperViewOnHide = YES;
    [view addSubview:hud];
    [hud show:YES];
    return hud;
}
+ (BOOL)hideHUDInView:(UIView *)view animated:(BOOL)animated {
    AXPracticalHUD *hud = [self HUDInView:view];
    if (hud) {
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES];
        return YES;
    }
    return NO;
}
+ (NSInteger)hideAllHUDsInView:(UIView *)view animated:(BOOL)animated {
    NSArray *HUDs = [self HUDsInView:view];
    for (AXPracticalHUD *hud in HUDs) {
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:animated];
    }
    return HUDs.count;
}
+ (instancetype)HUDInView:(UIView *)view {
    NSEnumerator *subviewEnum = [view.subviews reverseObjectEnumerator];
    for (UIView *hud in subviewEnum) {
        if ([hud isKindOfClass:[AXPracticalHUD class]]) {
            return (AXPracticalHUD *)hud;
        }
    }
    return nil;
}
+ (NSArray *)HUDsInView:(UIView *)view {
    NSMutableArray *HUDs = [NSMutableArray array];
    for (UIView *hud in view.subviews) {
        if ([hud isKindOfClass:[AXPracticalHUD class]]) {
            [HUDs addObject:hud];
        }
    }
    return HUDs;
}
@end
