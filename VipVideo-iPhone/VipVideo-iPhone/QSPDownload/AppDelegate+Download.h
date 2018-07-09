//
//  AppDelegate+DownLoad.h
//  QSPDownLoad_Demo
//
//  Created by 綦 on 17/3/22.
//  Copyright © 2017年 PowesunHolding. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (DownLoad)

@property (copy, nonatomic, readonly) void (^completionHandler)(void);

@end
