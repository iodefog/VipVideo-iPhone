//
//  AXPracticalHUD.h
//  AXSwift2OC
//
//  Created by ai on 9/7/15.
//  Copyright © 2015 ai. All rights reserved.
//

#import "AXPracticalHUDContentView.h"

@protocol AXPracticalHUDAnimator;

extern id<AXPracticalHUDAnimator> _Nullable AXPracticalHUDFadeAnimator(void) NS_SWIFT_NAME(PracticalHUDFadeAnimator());
extern id<AXPracticalHUDAnimator> _Nullable AXPracticalHUDFlipUpAnimator(void) NS_SWIFT_NAME(PracticalHUDFlipUpAnimator());
extern id<AXPracticalHUDAnimator> _Nullable AXPracticalHUDZoomAnimator(void) NS_SWIFT_NAME(PracticalHUDZoomAnimator());
extern id<AXPracticalHUDAnimator> _Nullable AXPracticalHUDDropDownAnimator(void) NS_SWIFT_NAME(PracticalHUDDropDownAnimator());

/// Mode of hud view
typedef NS_ENUM(NSInteger, AXPracticalHUDMode) {
    /// Progress is shown using an UIActivityIndicatorView. This is the default.
    AXPracticalHUDModeNormal,
    /// Progress is shown using a round, pie-chart like, progress view.
    AXPracticalHUDModeProgress,
    /// Progress is shown using a horizontal progress bar
    AXPracticalHUDModeProgressBar,
    /// Progress is shown using a horizontal colorful progress bar
    AXPracticalHUDModeColourfulProgressBar,
    /// Progress is shown using a ring-shaped progress view.
    AXPracticalHUDModeProgressRing,
    /// Shows a custom view
    AXPracticalHUDModeCustomView,
    /// Shows only labels
    AXPracticalHUDModeText,
    /// Progress is shown using an breach annular indicator.
    AXPracticalHUDModeBreachedRing
} NS_SWIFT_NAME(PracticalHUDMode);
/// Position of hud view.
typedef NS_ENUM(NSInteger, AXPracticalHUDPosition) {
    /// Top position.
    AXPracticalHUDPositionTop,
    /// Center position.
    AXPracticalHUDPositionCenter,
    /// Bottom position
    AXPracticalHUDPositionBottom
} NS_SWIFT_NAME(PracticalHUDPosition);
/// Completion block when task finished.
typedef void(^AXPracticalHUDCompletionBlock)(void);
/// HUD delegate
@protocol AXPracticalHUDDelegate;

NS_SWIFT_NAME(PracticalHUD) @interface AXPracticalHUD : UIView
/// Delegate of HUD view,
@property(assign, nonatomic, nullable) id<AXPracticalHUDDelegate>delegate;
#pragma mark - Boolean
/// Restore the hud view when hud hided if YES, setting the properties of hud view to the initial state. Default is NO.
@property(assign, nonatomic, getter=isRestoreEnabled) BOOL restoreEnabled;
/// Lock the background to avoid the touch events if YES. Default is NO.
@property(assign, nonatomic, getter=shouldLockBackground) BOOL lockBackground;
/// Using dim background if YES. Default is NO.
@property(assign, nonatomic, getter=shouldDimBackground) BOOL dimBackground;
/// Remove the hud from super view if hud is hidden. Default is YES.
@property(assign, nonatomic, getter=shouldRemoveFromSuperViewOnHide) BOOL removeFromSuperViewOnHide;
/// Using the square content view if YES. Default is NO.
@property(assign, nonatomic, getter=isSquare) BOOL square;
#pragma mark - Frame.
/// Total size of hud container view. Read only.
@property(readonly, nonatomic) CGSize size;
/// Margin of content views. Default is 15.0f.
@property(assign, nonatomic) CGFloat margin;
/// Offset of cotent view. Default is zero.
@property(assign, nonatomic) CGPoint offsets;
/// Minimum size of container view. Default is CGSizeZero.
@property(assign, nonatomic) CGSize minimumSize;
/// The insets of views in content view bounds. Default is {15.0f, 15.0f, 15.0f, 15.0f}
@property(assign, nonatomic) UIEdgeInsets contentInsets;
#pragma mark - Time interval.
/// Grace time showing hud view. Default is 0.0f.
@property(assign, nonatomic) NSTimeInterval grace;
/// Minimum showing time interval of hud view. Default is 0.5f.
@property(assign, nonatomic) NSTimeInterval threshold;
#pragma mark - Mode and ENUM.
/// Mode of the hud view..
@property(assign, nonatomic) AXPracticalHUDMode mode;
/// Animator to show or hide the hud view. Default using the fade animator.
@property(strong, nonatomic, nonnull) id<AXPracticalHUDAnimator> animator;
/// Position of the hud view.
@property(assign, nonatomic) AXPracticalHUDPosition position;
/// Completion block when hud view has hidden.
@property(copy, nonatomic, nullable) AXPracticalHUDCompletionBlock completion;
#pragma mark - Tasks.
/// Is tasks progressing.
@property(readonly, nonatomic, getter=isProgressing) BOOL progressing;
#pragma mark - Progress.
/// Progress of the progerss indicator.
@property(assign, nonatomic) CGFloat progress;
#pragma mark - Custom view.
/// Custom view. Readwrite.
@property(strong, nonatomic, nullable) UIView *customView;
#pragma mark - Content view
/// Content view.
@property(readonly, strong, nonatomic, nonnull) AXPracticalHUDContentView *contentView;
#pragma mark - Label
/// Title label.
@property(readonly, strong, nonatomic, nonnull) UILabel *label;
#pragma mark - Detail label.
/// Detail label.
@property(readonly, strong, nonatomic, nonnull) UILabel *detailLabel;
#pragma mark - Initializer
- (nullable instancetype)initWithView:(nullable UIView *)view;
- (nullable instancetype)initWithWindow:(nullable UIWindow *)window;
#pragma mark - Show & Hide.
- (void)show:(BOOL)animated;
- (void)hide:(BOOL)animated;

- (void)show:(BOOL)animated executingBlock:(nullable dispatch_block_t)executing onQueue:(nullable dispatch_queue_t)queue completion:(nullable AXPracticalHUDCompletionBlock)completion;
- (void)show:(BOOL)animated executingBlockOnGQ:(nullable dispatch_block_t)executing completion:(nullable AXPracticalHUDCompletionBlock)completion;
- (void)show:(BOOL)animated executingMethod:(nullable SEL)method toTarget:(nullable id)target withObject:(nullable id)object;

- (void)hide:(BOOL)animated afterDelay:(NSTimeInterval)delay completion:(nullable AXPracticalHUDCompletionBlock)completion;
@end

@interface AXPracticalHUD(Shared)
#if UIKIT_DEFINE_AS_PROPERTIES
@property(class, readonly, nonatomic, nullable) AXPracticalHUD *sharedHUD NS_SWIFT_NAME(shared);
#else
+ (nullable instancetype)sharedHUD NS_SWIFT_NAME(shared());
#endif

- (void)showProgressInView:(nullable UIView *)view NS_SWIFT_NAME(showProgress(in:));
- (void)showProgressBarInView:(nullable UIView *)view NS_SWIFT_NAME(showProgressBar(in:));
- (void)showColorfulProgressBarInView:(nullable UIView *)view NS_SWIFT_NAME(showColorfulProgressBar(in:));
- (void)showTextInView:(nullable UIView *)view NS_SWIFT_NAME(showText(in:));
- (void)showNormalInView:(nullable UIView *)view NS_SWIFT_NAME(showNormal(in:));
- (void)showErrorInView:(nullable UIView *)view NS_SWIFT_NAME(showError(in:));
- (void)showSuccessInView:(nullable UIView *)view NS_SWIFT_NAME(showSuccess(in:));

- (void)showProgressInView:(nullable UIView *)view
                      text:(nullable NSString *)text
                    detail:(nullable NSString *)detail
             configuration:(nullable void(^)(AXPracticalHUD * _Nullable HUD))configuration
NS_SWIFT_NAME(showProgress(in:text:detail:configuration:));
- (void)showProgressBarInView:(nullable UIView *)view
                         text:(nullable NSString *)text
                       detail:(nullable NSString *)detail
                configuration:(nullable void(^)(AXPracticalHUD * _Nullable HUD))configuration
NS_SWIFT_NAME(showProgressBar(in:text:detail:configuration:));
- (void)showColorfulProgressBarInView:(nullable UIView *)view
                                 text:(nullable NSString *)text
                               detail:(nullable NSString *)detail
                        configuration:(nullable void(^)(AXPracticalHUD * _Nullable HUD))configuration
NS_SWIFT_NAME(showColorfulProgressBar(in:text:detail:configuration:));
- (void)showTextInView:(nullable UIView *)view
                  text:(nullable NSString *)text
                detail:(nullable NSString *)detail
         configuration:(nullable void(^)(AXPracticalHUD * _Nullable HUD))configuration
NS_SWIFT_NAME(showText(in:text:detail:configuration:));
- (void)showNormalInView:(nullable UIView *)view
                    text:(nullable NSString *)text
                  detail:(nullable NSString *)detail
           configuration:(nullable void(^)(AXPracticalHUD * _Nullable HUD))configuration
NS_SWIFT_NAME(showNormal(in:text:detail:configuration:));
- (void)showErrorInView:(nullable UIView *)view
                   text:(nullable NSString *)text
                 detail:(nullable NSString *)detail
          configuration:(nullable void(^)(AXPracticalHUD * _Nullable HUD))configuration
NS_SWIFT_NAME(showError(in:text:detail:configuration:));
- (void)showSuccessInView:(nullable UIView *)view
                     text:(nullable NSString *)text
                   detail:(nullable NSString *)detail
            configuration:(nullable void(^)(AXPracticalHUD * _Nullable HUD))configuration
NS_SWIFT_NAME(showSuccess(in:text:detail:configuration:));
@end

@interface AXPracticalHUD(Convenence)
+ (nullable instancetype)showHUDInView:(nullable UIView *)view animated:(BOOL)animated NS_SWIFT_NAME(showHud(in:animated:));
+ (BOOL)hideHUDInView:(nullable UIView *)view animated:(BOOL)animated NS_SWIFT_NAME(hideHud(in:animated:));
+ (NSInteger)hideAllHUDsInView:(nullable UIView *)view animated:(BOOL)animated NS_SWIFT_NAME(hideAllHuds(in:animated:));
+ (nullable instancetype)HUDInView:(nullable UIView *)view NS_SWIFT_NAME(hud(in:));
+ (nonnull NSArray *)HUDsInView:(nullable UIView *)view NS_SWIFT_NAME(huds(in:));
@end

NS_SWIFT_NAME(PracticalHUDDelegate) @protocol AXPracticalHUDDelegate <NSObject>
@optional
- (void)HUDWillShow:(nonnull AXPracticalHUD *)HUD;
- (void)HUDDidHidden:(nonnull AXPracticalHUD *)HUD;
@end
