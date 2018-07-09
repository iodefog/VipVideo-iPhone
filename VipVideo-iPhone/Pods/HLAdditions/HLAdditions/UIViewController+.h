//
//  UIViewController+.h
//  Utility
//
//
//

#import <UIKit/UIKit.h>

@interface UIViewController (HLCategory)

@property(nonatomic, readonly, assign) CGFloat topMargin, bottomMargin;
@property(nonatomic, readonly, assign) CGFloat topBarsHeight, bottomBarsHeight;

- (BOOL)isViewAppeared;

+ (UIViewController *)rootViewController;
+ (UIViewController *)currentViewController;
+ (UIViewController *)topViewController;
+ (UIViewController *)topkeyWindowViewController;

/**
 *  __block UIViewController *rootViewController = [UIViewController gotoRootViewControllerAnimated:YES/NO completion:^{
 *      [rootViewController presentViewController:viewController animated:YES/NO completion:nil];
 *  }];
 */
+ (UIViewController *)gotoRootViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion;
- (void)dismissAllViewControllersAnimated:(BOOL)animated completion:(void (^)(void))completion;

/**
 *  Adding and Removing a Child
 *  @see xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/1048/featuredarticles/ViewControllerPGforiPhoneOS/CreatingCustomContainerViewControllers/CreatingCustomContainerViewControllers.html
 */
- (void)addChildViewController:(UIViewController *)childController superview:(UIView *)superview;
- (void)removeFromParentViewControllerAndSuperiew;
- (void)transitionFromChildViewController:(UIViewController *)fromViewController
                    toChildViewController:(UIViewController *)toViewController
                                 duration:(NSTimeInterval)duration
                                  options:(UIViewAnimationOptions)options
                               animations:(void (^)(void))animations
                               completion:(void (^)(BOOL))completion;

@end
