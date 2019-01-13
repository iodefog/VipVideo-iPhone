//
//  HLPlayerViewController.h
//  VipVideo-iPhone
//
//  Created by LHL on 2018/1/23.
//  Copyright © 2018年 SV. All rights reserved.
//

#import <UIKit/UIKit.h>

#define HLPlayerViewControllerDealloc @"HLPlayerViewControllerDealloc"

typedef void(^HLPlayerVCBackBlock)(BOOL finish);

@interface HLPlayerViewController : UIViewController

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, assign) BOOL  canDownload; // 默认YES

@property (nonatomic, copy) HLPlayerVCBackBlock backCompleteBlock;

- (void)reloadRequest;

@end
