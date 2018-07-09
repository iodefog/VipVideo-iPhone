//
//  AppDelegate+DownLoad.m
//  QSPDownLoad_Demo
//
//  Created by 綦 on 17/3/22.
//  Copyright © 2017年 PowesunHolding. All rights reserved.
//

#import "AppDelegate+Download.h"
#import <objc/message.h>

#define CompletionHandlerName       "completionHandler"

@implementation AppDelegate (DownLoad)

- (void (^)(void))completionHandler
{
    return objc_getAssociatedObject(self, CompletionHandlerName);
}
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler
{
    NSLog(@"%s", __FUNCTION__);
    objc_setAssociatedObject(self, CompletionHandlerName, completionHandler, OBJC_ASSOCIATION_COPY);
}

@end
