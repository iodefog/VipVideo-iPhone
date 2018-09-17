//
//  HLTabBarController.m
//  VipVideo-iPhone
//
//  Created by LiHongli on 2018/6/26.
//  Copyright © 2018年 SV. All rights reserved.
//

#import "HLTabBarController.h"
#import "UIViewController+.h"

#import "HLHomeViewController.h"
#import "HLTVListViewController.h"
#import "DownloadViewController.h"
#import "HLMineViewController.h"

@interface HLTabBarController ()

@end

@implementation HLTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoIphoneUAChange) name:HLVideoIphoneUAChange object:nil];

    UINavigationController *home = [self createVCWithTitle:@"首页" icon:@"home" className:@"HLHomeViewController"];
    UINavigationController *live = [self createVCWithTitle:@"直播" icon:@"live" className:@"HLTVListViewController"];
    UINavigationController *download = [self createVCWithTitle:@"下载" icon:@"download" className:@"DownloadViewController"];
    UINavigationController *mine = [self createVCWithTitle:@"首页" icon:@"mine" className:@"HLMineViewController"];

    self.viewControllers = @[home, live, download, mine];
}

- (UINavigationController *)createVCWithTitle:(NSString *)title
                                         icon:(NSString *)icon
                                    className:(NSString *)className
{
    if (!className) {
        return nil;
    }
    UIViewController *vc = [[NSClassFromString(className) alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.tabBarItem.title = title;
    nav.tabBarItem.image = [UIImage imageNamed:icon];
    
    return nav;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)videoIphoneUAChange{
    
    BOOL isOn = [[NSUserDefaults standardUserDefaults] boolForKey:HLVideoIphoneUAisOn];
    if (isOn) {
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{ @"UserAgent": HLPCUserAgent}];
    }
    else {
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{ @"UserAgent": HLiPhoneUA}];
    }
    
    UINavigationController *home = [self createVCWithTitle:@"首页" icon:@"home" className:@"HLHomeViewController"];
    
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.viewControllers];
    
    [viewControllers replaceObjectAtIndex:0 withObject:home];
    self.viewControllers = viewControllers;
}

- (BOOL)shouldAutorotate {
    return NO;
}
//返回支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
//这个是返回优先方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

@end
