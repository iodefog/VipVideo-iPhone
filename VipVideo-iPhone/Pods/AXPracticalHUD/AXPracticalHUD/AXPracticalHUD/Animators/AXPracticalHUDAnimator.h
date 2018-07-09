//
//  AXPracticalHUDAnimator.h
//  AXPracticalHUD
//
//  Created by devedbox on 2018/2/4.
//  Copyright © 2018年 AiXing. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AXPracticalHUD;

/// The abstract declaration of the animator of the hud to show or hide
/// on the attached view. Custom classes should conform this protocol to
/// offer the showing and hiding methods.
NS_SWIFT_NAME(PracticalHUDAnimator) @protocol AXPracticalHUDAnimator<NSObject>
@required
/// Should allow layouting subviews during animation.
@property(readonly, nonatomic) BOOL allowsLayoutSubviewsDuringAnimation;
/// The last time duration of the animation.
- (NSTimeInterval)durationForTransition:(BOOL)isHidden;
/// The hud will call this method to show or hide the hud view when the transition
/// begins.
///
/// @param hud: The hud view to be transitioned.
/// @param animated: Wether to run this animator by animation.
/// @param isHidden: Wether the animator is used to begin hidding transition animation.
- (void)hud:(AXPracticalHUD *)hud animate:(BOOL)animated isHidden:(BOOL)isHidden;
@end
