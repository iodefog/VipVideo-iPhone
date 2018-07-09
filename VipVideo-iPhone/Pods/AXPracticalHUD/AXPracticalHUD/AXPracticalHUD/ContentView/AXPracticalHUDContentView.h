//
//  AXPracticalHUDContentView.h
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

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AXPracticalHUDTranslucentStyle) {
    /// Light translucent style.
    AXPracticalHUDTranslucentStyleLight,
    /// Dark translucent style.
    AXPracticalHUDTranslucentStyleDark
} NS_SWIFT_NAME(PracticalHUDTranslucentStyle);

NS_SWIFT_NAME(PracticalHUDContentView) @interface AXPracticalHUDContentView : UIView
/// Color of the content view. Default is nil.
@property(strong, nonatomic) UIColor *color;
/// End color of the content view. Default is nil.
@property(strong, nonatomic) UIColor *endColor;
/// Translucent. Default is NO.
@property(assign, nonatomic, getter=isTranslucent) BOOL translucent;
/// Translucent style. Default is Dark.
@property(assign, nonatomic) AXPracticalHUDTranslucentStyle translucentStyle;
/// Opacity. Default is 0.8f. If color of the content view is nil, then background color of the content view will
/// be filled with gray color with opacity alpha.
@property(assign, nonatomic) CGFloat opacity;
@end
