//
//  HLHomeViewController.m
//  VipVideo-iPhone
//
//  Created by LHL on 2017/10/26.
//  Copyright © 2017年 SV. All rights reserved.
//

#import "HLHomeViewController.h"
#import "DownloadViewController.h"
#import "HLPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "FTPopOverMenu.h"
#import "VipURLManager.h"
#import "Masonry.h"
#import "HybridNSURLProtocol.h"

#define HLUserAgent @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Safari/537.36"
#define HLiPhoneUA @"Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25"

@interface HLHomeViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSMutableArray *modelsArray;

@property (nonatomic, strong) VipUrlItem     *currentModel;
@property (nonatomic, strong) NSString       *currentUrl;

@property (nonatomic, copy)   NSURL          *currentVideoUrl;

@property (nonatomic, strong) UIButton       *leftButton;
@property (nonatomic, strong) UIButton       *rightButton;
//@property (nonatomic, strong) UIButton       *downloadButton;

@end

@implementation HLHomeViewController

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (!_leftButton) {
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftButton setTitle:@"平台" forState:UIControlStateNormal];
        leftButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [leftButton setTitleColor:self.view.tintColor forState:UIControlStateNormal];
        leftButton.frame = CGRectMake(0, 0, 30, 44);
        [leftButton addTarget:self action:@selector(videosClicked:) forControlEvents:UIControlEventTouchUpInside];
        self.leftButton = leftButton;
    }
    
    if (!self.rightButton) {
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightButton setTitle:@"转换" forState:UIControlStateNormal];
        rightButton.titleLabel.font = [UIFont systemFontOfSize:14];
        rightButton.frame = CGRectMake(0, 0, 30, 44);
        [rightButton setTitleColor:self.view.tintColor forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(apiClicked:) forControlEvents:UIControlEventTouchUpInside];
        self.rightButton = rightButton;
    }
    
//    if (!self.downloadButton) {
//        UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [downloadButton setTitle:@"下载" forState:UIControlStateNormal];
//        downloadButton.titleLabel.font = [UIFont systemFontOfSize:14];
//        downloadButton.frame = CGRectMake(0, 0, 30, 44);
//        [downloadButton setTitleColor:self.view.tintColor forState:UIControlStateNormal];
//        [downloadButton addTarget:self action:@selector(downloadClicked:) forControlEvents:UIControlEventTouchUpInside];
//        self.downloadButton = downloadButton;
//    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.navigationItem.leftBarButtonItems = @[
                                                   [[UIBarButtonItem alloc] initWithCustomView:self.leftButton],
                                                   [[UIBarButtonItem alloc] initWithCustomView:self.rightButton]];
    }
    else {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftButton];
        self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:self.rightButton],];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:self action:@selector(back)];

    [NSURLProtocol registerClass:[HybridNSURLProtocol class]];

    [[ UIApplication sharedApplication] setIdleTimerDisabled:YES];
//    self.navigationButtonsHidden = NO;
    if (@available(iOS 11.0, *)) {
//        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    self.modelsArray = [NSMutableArray array];
    [self configurationWebVC];
    [self resignNotifacation];
    
    [self.modelsArray addObjectsFromArray: [[VipURLManager sharedInstance] platformItemsArray]];
    [self refreshVideoModel:[self.modelsArray firstObject]];
    
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGesture:)];
    longGesture.delegate = self;
    [self.webView addGestureRecognizer:longGesture];
    
}


- (void)back{
    if (![self.navigationController popViewControllerAnimated:YES]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)configurationWebVC{
    
    self.showsToolBar = YES;
    self.navigationType = AXWebViewControllerNavigationToolItem;
    self.maxAllowedTitleLength = 999;
    

    
    FTPopOverMenuConfiguration *configuration = [FTPopOverMenuConfiguration defaultConfiguration];
    configuration.textAlignment = NSTextAlignmentCenter;
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        configuration.menuWidth = 200;
//        [[NSUserDefaults standardUserDefaults] registerDefaults:@{ @"UserAgent": HLUserAgent}];
        self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:self.rightButton]];
        [self.webView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    else {
        
        self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:self.rightButton]];
        [self.webView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    
}

- (void)resignNotifacation{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(vipVideoCurrentApiWillChange:) name:KHLVipVideoCurrentApiWillChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(vipVideoCurrentApiDidChange:) name:KHLVipVideoCurrentApiDidChange object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(vipVideoRequestSueccess:) name:KHLVipVideoRequestSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemBecameCurrent:)
                                                 name:@"AVPlayerItemBecameCurrentNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowVisible:)
                                                 name:UIWindowDidBecomeVisibleNotification
                                               object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowHidden:)
                                                 name:UIWindowDidBecomeHiddenNotification
                                               object:self.view.window];
}

static bool isShow = NO;

- (void)longGesture:(UIGestureRecognizer *)gesture{
    if (self.currentVideoUrl) {
        if (isShow) {
            return;
        }
        
        isShow = YES;
        [self delayOpreation];
    }
}

- (void)delayOpreation{

    HLPlayerViewController *playerVC = [[HLPlayerViewController alloc] init];
    playerVC.backBlock = ^(BOOL success){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            isShow = NO;
        });
    };
    NSLog(@"Real Video Url %@", self.currentVideoUrl);
    playerVC.url = self.currentVideoUrl;
    [self presentViewController:playerVC animated:YES completion:nil];
}

- (void)refreshVideoModel:(VipUrlItem *)model{
    self.currentModel = model;
    
    [self loadURL:[NSURL URLWithString:model.url]];
}

// 视频平台点击
- (void)videosClicked:(id)sender {
    NSMutableArray *titlesArray = [NSMutableArray array];
    for (VipUrlItem *item in self.modelsArray) {
        [titlesArray addObject:item.title?:@""];
    }
    
    if (titlesArray.count ==0) {
        return;
    }
    FTPopOverMenuConfiguration *configuration = [FTPopOverMenuConfiguration defaultConfiguration];
    configuration.menuWidth = 100;

    __weak typeof(self) mySelf = self;
    [FTPopOverMenu showForSender:sender withMenuArray:titlesArray doneBlock:^(NSInteger selectedIndex) {
        [mySelf refreshVideoModel:self.modelsArray[selectedIndex]];
    } dismissBlock:^{
        NSLog(@"user canceled. do nothing.");
    }];
}

// 接口切换点击
- (void)apiClicked:(id)sender {
    NSMutableArray *titlesArray = [NSMutableArray array];
    for (VipUrlItem *item in [VipURLManager sharedInstance].itemsArray) {
        [titlesArray addObject:item.title?:@""];
    }
    if (titlesArray.count ==0) {
        return;
    }
    
    FTPopOverMenuConfiguration *configuration = [FTPopOverMenuConfiguration defaultConfiguration];
    configuration.menuWidth = 150;
    
    [FTPopOverMenu showForSender:sender withMenuArray:titlesArray doneBlock:^(NSInteger selectedIndex) {
        VipURLManager *manager = [VipURLManager sharedInstance];
        [manager changeVideoItem:manager.itemsArray[selectedIndex]];
    } dismissBlock:^{
        NSLog(@"user canceled. do nothing.");
    }];
}

//- (void)downloadClicked:(UIButton *)sender{
//    DownloadViewController *downloadVC = [[DownloadViewController alloc] init];
//    [self.navigationController pushViewController:downloadVC animated:YES];
//}

- (void)vipVideoCurrentApiWillChange:(NSNotification *)notification{
    NSString *url = [[_currentUrl componentsSeparatedByString:@"url="] lastObject];
    if ([url hasPrefix:@"http"]) {
        _currentUrl = url;
    }
}

- (void)vipVideoCurrentApiDidChange:(NSNotification *)notification{
    
#if AX_WEB_VIEW_CONTROLLER_USING_WEBKIT
    [self.webView evaluateJavaScript:@"document.location.href" completionHandler:^(NSString *url, NSError * _Nullable error) {
        
        NSString *originUrl = [[url componentsSeparatedByString:@"url="] lastObject];

        if (![url hasPrefix:@"http"]) {
            return ;
        }

        NSString *finalUrl = [NSString stringWithFormat:@"%@%@", [[VipURLManager sharedInstance] currentVipApi]?:@"",originUrl?:@""];
        NSLog(@"finalUrl = %@", finalUrl);
        [self loadURL:[NSURL URLWithString:finalUrl]];
    }];
#else
    NSString *url =  [self.webView stringByEvaluatingJavaScriptFromString:@"document.location.href"];
    NSString *originUrl = [[url componentsSeparatedByString:@"url="] lastObject];
    
    if (![url hasPrefix:@"http"]) {
        return ;
    }
    
    NSString *finalUrl = [NSString stringWithFormat:@"%@%@", [[VipURLManager sharedInstance] currentVipApi]?:@"",originUrl?:@""];
    NSLog(@"finalUrl = %@", finalUrl);
    [self loadURL:[NSURL URLWithString:finalUrl]];
#endif
    
    
}

- (void)vipVideoRequestSueccess:(NSNotification *)notificaiton{
    NSArray *platformArray = [[VipURLManager sharedInstance] platformItemsArray];
    if (platformArray.count > 0) {
        
        [self.modelsArray removeAllObjects];
        [self.modelsArray addObjectsFromArray:platformArray];
        [self refreshVideoModel:[self.modelsArray firstObject]];
    }
}

- (void)playerItemBecameCurrent:(NSNotification *)notification{
    AVPlayerItem *playerItem = [notification object];
    if(playerItem == nil) return;
    if ([playerItem isKindOfClass:[AVPlayerItem class]])
    {
        // Break down the AVPlayerItem to get to the path
        AVURLAsset *asset = (AVURLAsset*)[playerItem asset];
        NSURL *url = [asset URL];
        NSString *path = [url absoluteString];
        NSLog(@"bbbbbbb %@", path);
        
        self.currentVideoUrl = url;
        
//        [self longGesture:nil];
    }
}

- (void)windowVisible:(NSNotification *)notification
{
//    UIViewController *viewController = [notification.object rootViewController];
//    [viewController dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"-windowVisible");
}

- (void)windowHidden:(NSNotification *)notification
{
    NSLog(@"-windowHidden");
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
