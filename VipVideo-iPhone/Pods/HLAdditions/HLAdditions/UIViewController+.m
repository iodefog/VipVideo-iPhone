//
//  UIViewController+.m
//  Utility
//
//

#if ! __has_feature(objc_arc)
// set -fobjc-arc flag: - Target > Build Phases > Compile Sources > implementation.m + -fobjc-arc
#error This file must be compiled with ARC. Use -fobjc-arc flag or convert project to ARC.
#endif

#if ! __has_feature(objc_arc_weak)
#error ARCWeakRef requires iOS 5 and higher.
#endif

#import "UIViewController+.h"
#import "HLUtilities.h"

@implementation UIViewController (HLCategory)

@dynamic topMargin, bottomMargin;

- (CGFloat)topMargin {
    if ([self respondsToSelector:@selector(topLayoutGuide)]) {
        if (self.edgesForExtendedLayout & UIRectEdgeTop) {
            if (self.topLayoutGuide.length) {
                return self.topLayoutGuide.length;
            }
            else {
                return [self topBarsHeight];
            }
        }
    }
    
    return 0;
}

- (CGFloat)bottomMargin {
    if ([self respondsToSelector:@selector(bottomLayoutGuide)]) {
        if (self.bottomLayoutGuide.length) {
            return self.bottomLayoutGuide.length;
        }
        else {
            return [self bottomBarsHeight];
        }
    }
    
    return 0;
}

- (CGFloat)topBarsHeight {
    CGFloat topBarsHeight = 0;
    if (![UIApplication sharedApplication].statusBarHidden) {
        // topBarsHeight += CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
        topBarsHeight += 20; // !!!: it maybe 40, but 20 is expected
    }
    if (self.navigationController && !self.navigationController.navigationBarHidden) {
        topBarsHeight += CGRectGetHeight(self.navigationController.navigationBar.frame);
    }
    return topBarsHeight;
}

- (CGFloat)bottomBarsHeight {
    CGFloat bottomBarsHeight = 0;
    if (self.tabBarController.tabBar && !self.tabBarController.tabBar.hidden) {
        bottomBarsHeight += CGRectGetHeight(self.tabBarController.tabBar.frame);
    }
    if (self.navigationController.toolbar && !self.navigationController.toolbarHidden) {
        bottomBarsHeight += CGRectGetHeight(self.navigationController.toolbar.frame);
    }
    return bottomBarsHeight;
}

#pragma mark -

- (BOOL)isViewAppeared {
    return self.isViewLoaded && self.view.window;
}

#pragma mark -

+ (UIViewController *)rootViewController {
    UIViewController *rootVC = [[[UIApplication sharedApplication].windows firstObject] rootViewController];
    if ([rootVC isKindOfClass:[UIAlertController class]]) {
        rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    }
    return rootVC;
}

+ (UIViewController *)currentViewController {
    UIViewController *topViewController = [UIViewController topViewController];
    if ([topViewController isKindOfClass:NSClassFromString(@"SNNavigationController")]) {
        if ([topViewController respondsToSelector:@selector(currentViewController)]) {
           return [topViewController performSelector:@selector(currentViewController)];
        }
    }else if ([topViewController isKindOfClass:[UINavigationController class]]){
       return ((UINavigationController *)topViewController).topViewController;
    }else {
        return topViewController;
    }
    return nil;
}

+ (UIViewController *)topViewController {
    UIViewController *topViewController = [UIViewController rootViewController];
    
    UITabBarController *tabBarController = [topViewController as:[UITabBarController class]];
    if (tabBarController.selectedViewController) {
        topViewController = tabBarController.selectedViewController;
    }
    while (topViewController.presentedViewController && ![topViewController.presentedViewController isKindOfClass:[UIAlertController class]]) {
        topViewController = topViewController.presentedViewController;
    }
    UINavigationController *navigationController = [topViewController as:[UINavigationController class]];
    if ([navigationController.viewControllers count]) {
        topViewController = navigationController.viewControllers.lastObject;
    }
    return topViewController;
}

+ (UIViewController *)topkeyWindowViewController {
    UIViewController *topViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    UITabBarController *tabBarController = [topViewController as:[UITabBarController class]];
    if (tabBarController.selectedViewController) {
        topViewController = tabBarController.selectedViewController;
    }
    while (topViewController.presentedViewController) {
        topViewController = topViewController.presentedViewController;
    }
    UINavigationController *navigationController = [topViewController as:[UINavigationController class]];
    if ([navigationController.viewControllers count]) {
        topViewController = navigationController.viewControllers.lastObject;
    }
    return topViewController;
}

+ (UIViewController *)gotoRootViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion {
    __block UIViewController *rootViewController = nil;
    dispatch_sync(dispatch_get_main_queue(), ^{
        rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    });
    
    UITabBarController *tabBarController = [rootViewController as:[UITabBarController class]];
    [rootViewController dismissAllViewControllersAnimated:animated completion:^{
        UINavigationController *navigationController = [tabBarController.selectedViewController OR rootViewController as:[UINavigationController class]];
        if (navigationController) {
            [navigationController popToRootViewControllerAnimated:animated ];
            if (completion) completion();
        }
        else {
            if (completion) completion();
        }
    }];
    return rootViewController;
}

- (void)dismissAllViewControllersAnimated:(BOOL)animated completion:(void (^)(void))completion {
    if (!self.presentedViewController) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (completion) completion();
        });
        return;
    }
    
    [self dismissViewControllerAnimated:animated completion:^{
        [self dismissAllViewControllersAnimated:NO completion:completion];
    }];
}

#pragma mark -

- (void)addChildViewController:(UIViewController *)childViewController superview:(UIView *)superview {
    /* The addChildViewController: method automatically calls the willMoveToParentViewController: method
     * of the view controller to be added as a child before adding it.
     */
    [self addChildViewController:childViewController]; // 1
    [superview addSubview:childViewController.view]; // 2
    [childViewController didMoveToParentViewController:self]; // 3
}

- (void)removeFromParentViewControllerAndSuperiew {
    [self willMoveToParentViewController:nil]; // 1
    /* The removeFromParentViewController method automatically calls the didMoveToParentViewController: method
     * of the child view controller after it removes the child.
     */
    [self.view removeFromSuperview]; // 2
    [self removeFromParentViewController]; // 3
}

- (void)transitionFromChildViewController:(UIViewController *)fromViewController
                    toChildViewController:(UIViewController *)toViewController
                                 duration:(NSTimeInterval)duration
                                  options:(UIViewAnimationOptions)options
                               animations:(void (^)(void))animations
                               completion:(void (^)(BOOL))completion {
    // 1
    [fromViewController willMoveToParentViewController:nil];
    [self addChildViewController:toViewController];
    
    // 2
    /* This method automatically adds the new view, performs the animation, and then removes the old view.
     */
    [self transitionFromViewController:fromViewController
                      toViewController:toViewController
                              duration:duration
                               options:options
                            animations:animations
                            completion:^(BOOL finished) {
                                // 3
                                [fromViewController removeFromParentViewController];
                                [toViewController didMoveToParentViewController:self];
                                // end
                                if (completion) completion(finished);
                            }];
}

@end
