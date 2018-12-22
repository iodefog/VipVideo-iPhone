//
//  UIButton+Addition.h
//  VipVideo-iPhone
//
//  Created by LiHongli on 2018/12/22.
//  Copyright © 2018 SV. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (Addition)

/**
 *  同时向按钮的四个方向延伸响应面积
 *
 *  @param size 间距
 */
- (void)setEnlargeEdge:(CGFloat) size;

/**
 *  向按钮的四个方向延伸响应面积
 *
 *  @param top    上间距
 *  @param left   左间距
 *  @param bottom 下间距
 *  @param right  右间距
 */
- (void)setEnlargeEdgeWithTop:(CGFloat) top left:(CGFloat) left bottom:(CGFloat) bottom right:(CGFloat) right;

@end

NS_ASSUME_NONNULL_END
