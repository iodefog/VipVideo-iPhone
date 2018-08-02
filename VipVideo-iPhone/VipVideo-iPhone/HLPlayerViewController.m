//
//  HLPlayerViewController.m
//  VipVideo-iPhone
//
//  Created by LHL on 2018/1/23.
//  Copyright © 2018年 SV. All rights reserved.
//

#import "HLPlayerViewController.h"
#import "WMPlayer.h"
#import "QSPDownloadTool.h"
#import "HTTPServer.h"

@interface HLPlayerViewController ()<WMPlayerDelegate>

@property (nonatomic, strong) WMPlayer *wmPlayer;
@property (nonatomic, strong) HTTPServer *server;

@end

@implementation HLPlayerViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.canDownload = YES;
    }
    return self;
}

- (void)dealloc{
    [self.server stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.wmPlayer pause];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    
    //获取设备旋转方向的通知,即使关闭了自动旋转,一样可以监测到设备的旋转方向
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//    //旋转屏幕通知
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(onDeviceOrientationChange:)
//                                                 name:UIDeviceOrientationDidChangeNotification
//                                               object:nil];
    
    
    WMPlayerModel *playerModel = [[WMPlayerModel alloc]init];
    playerModel.title = self.title?:@"播放中";
    
    if ([self.url.absoluteString hasPrefix:@"http"]) {
        playerModel.videoURL = self.url;
    }else {
        
        if(!self.server){
            self.server = [[HTTPServer alloc] init];
            [self.server setType:@"_http.tcp"];
            [self.server setPort:8890];
            
        }
        
//        if ([self.server isRunning]) {
//            [self.server stop];
//        }
        //设置服务器根路径
        NSString *newurl = [self.url.absoluteString.stringByDeletingLastPathComponent stringByReplacingOccurrencesOfString:@"file:" withString:@""];
        [self.server setDocumentRoot:newurl];

        
        if(![self.server isRunning]){
            NSError *error = nil;
            [self.server start:&error];
            NSLog(@"xxx %@",error);
            NSLog(@"yyy %@",self.server.documentRoot);
        }
        
        NSLog(@"是否启动 %@", @([self.server isRunning]));
        
        playerModel.videoURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:8890/index.m3u8"]];
    }


    self.wmPlayer = [WMPlayer playerWithModel:playerModel];;
    self.wmPlayer.canDownload = self.canDownload;
    [self.view addSubview:self.wmPlayer];
    [self.wmPlayer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.view);
    }];

    self.wmPlayer.delegate = self;
    [self.wmPlayer play];
    
    NSLog(@"current url %@", self.url);
}

//
///**
// *  旋转屏幕通知
// */
//- (void)onDeviceOrientationChange:(NSNotification *)notification{
//    if (self.wmPlayer==nil){
//        return;
//    }
//    if (self.wmPlayer.isLockScreen){
//        return;
//    }
//    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
//    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
//    switch (interfaceOrientation) {
//        case UIInterfaceOrientationPortraitUpsideDown:{
//            NSLog(@"第3个旋转方向---电池栏在下");
//        }
//            break;
//        case UIInterfaceOrientationPortrait:{
//            NSLog(@"第0个旋转方向---电池栏在上");
////            [self toOrientation:UIInterfaceOrientationPortrait];
//        }
//            break;
//        case UIInterfaceOrientationLandscapeLeft:{
//            NSLog(@"第2个旋转方向---电池栏在左");
////            [self toOrientation:UIInterfaceOrientationLandscapeLeft];
//        }
//            break;
//        case UIInterfaceOrientationLandscapeRight:{
//            NSLog(@"第1个旋转方向---电池栏在右");
////            [self toOrientation:UIInterfaceOrientationLandscapeRight];
//        }
//            break;
//        default:
//            break;
//    }
//}
////点击进入,退出全屏,或者监测到屏幕旋转去调用的方法
//-(void)toOrientation:(UIInterfaceOrientation)orientation{
//    //获取到当前状态条的方向
//    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
//    //判断如果当前方向和要旋转的方向一致,那么不做任何操作
//    if (currentOrientation == orientation) {
//        return;
//    }
//    [self.wmPlayer removeFromSuperview];
//    
//    //根据要旋转的方向,使用Masonry重新修改限制
//    if (orientation ==UIInterfaceOrientationPortrait) {
//        [self.view addSubview:self.wmPlayer];
//        self.wmPlayer.isFullscreen = NO;
//        self.wmPlayer.backBtnStyle = BackBtnStyleClose;
//        [self.wmPlayer mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.left.right.top.bottom.equalTo(self.view);
//        }];
//        
//    }else{
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [[UIApplication sharedApplication].keyWindow addSubview:self.wmPlayer];
//            self.wmPlayer.isFullscreen = YES;
//            self.wmPlayer.backBtnStyle = BackBtnStylePop;
//            if(currentOrientation ==UIInterfaceOrientationPortrait){
//                [self.wmPlayer mas_remakeConstraints:^(MASConstraintMaker *make) {
//                    make.width.mas_equalTo([UIScreen mainScreen].bounds.size.height);
//                    make.height.mas_equalTo([UIScreen mainScreen].bounds.size.width);
//                    make.center.equalTo([UIApplication sharedApplication].keyWindow);
//                }];
//            }else{
//                [self.wmPlayer mas_remakeConstraints:^(MASConstraintMaker *make) {
//                    make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width);
//                    make.height.mas_equalTo([UIScreen mainScreen].bounds.size.height);
//                    make.center.equalTo([UIApplication sharedApplication].keyWindow);
//                }];
//            }
//        });
//    }
//    
//    //iOS6.0之后,设置状态条的方法能使用的前提是shouldAutorotate为NO,也就是说这个视图控制器内,旋转要关掉;
//    //也就是说在实现这个方法的时候-(BOOL)shouldAutorotate返回值要为NO
//    [[UIApplication sharedApplication] setStatusBarOrientation:orientation animated:NO];
//    //更改了状态条的方向,但是设备方向UIInterfaceOrientation还是正方向的,这就要设置给你播放视频的视图的方向设置旋转
//    //给你的播放视频的view视图设置旋转
//    [UIView animateWithDuration:0.4 animations:^{
//        self.wmPlayer.transform = CGAffineTransformIdentity;
//        self.wmPlayer.transform = [WMPlayer getCurrentDeviceOrientation];
//        [self.wmPlayer layoutIfNeeded];
//        [self setNeedsStatusBarAppearanceUpdate];
//    }];
//}

- (void)forceInterfaceOrientation:(UIInterfaceOrientation)orientation {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector             = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val                  = orientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}


- (void)setUrl:(NSURL *)url{
    _url = url;
}

- (void)reloadRequest{
    WMPlayerModel *playerModel = [[WMPlayerModel alloc]init];
    playerModel.title = self.title?:@"播放中";
    playerModel.videoURL = self.url;
    self.wmPlayer.playerModel = playerModel;
    [self.wmPlayer play];
}

/** backBtn event */
- (void)zf_playerBackAction{
    if (self.backBlock) {
        self.backBlock(YES);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

/** downloadBtn event */
- (void)zf_playerDownload:(NSString *)url{
    if (url) {
        [[QSPDownloadTool shareInstance] addDownloadToolDelegate:(id)self];
        [[QSPDownloadTool shareInstance] addDownloadTast:url title:self.title?:self.navigationItem.title andOffLine:YES];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"已添加到下载任务" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:action];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}


- (void)downloadSource:(QSPDownloadSource *)source changedStyle:(QSPDownloadSourceStyle)style{
    if (style == QSPDownloadSourceStyleFail) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"下载失败" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:action];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)downloadToolDidFinish:(QSPDownloadTool *)tool downloadSource:(QSPDownloadSource *)source{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"下载成功" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}


/** 控制层即将显示 */
- (void)zf_playerControlViewWillShow:(UIView *)controlView isFullscreen:(BOOL)fullscreen{
    
}

/** 控制层即将隐藏 */
- (void)zf_playerControlViewWillHidden:(UIView *)controlView isFullscreen:(BOOL)fullscreen{
    
}

- (BOOL)shouldAutorotate{
    return YES;
}

// 支持哪些屏幕方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

// 默认的屏幕方向（当前ViewController必须是通过模态出来的UIViewController（模态带导航的无效）方式展现出来的，才会调用这个方法）
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [UIApplication sharedApplication].statusBarOrientation;
}

#pragma mark - WMPlayer Delegate

-(void)wmplayer:(WMPlayer *)wmplayer clickedFullScreenButton:(UIButton *)fullScreenBtn{
    if (!wmplayer.isFullscreen) {
        [self forceInterfaceOrientation:UIInterfaceOrientationLandscapeRight];
    }else {
        [self forceInterfaceOrientation:UIInterfaceOrientationPortrait];
    }
}


-(void)wmplayer:(WMPlayer *)wmplayer clickedCloseButton:(UIButton *)backBtn{
    if (self.backBlock) {
        self.backBlock(YES);
    }
    if (![self.navigationController popViewControllerAnimated:YES]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)wmplayer:(WMPlayer *)wmplayer clickedDownloadButton:(UIButton *)backBtn{
    [self zf_playerDownload:wmplayer.playerModel.videoURL.absoluteString];
//    [self zf_playerDownload:@"http://163.com-www-letv.com/20180604/1403_6de54f23/index.m3u8"];
//    [self zf_playerDownload:@"http://10.2.12.0/movie/SNIS-896.mp4"];
}

-(void)wmplayerFinishedPlay:(WMPlayer *)wmplayer{
    if (![self.navigationController popViewControllerAnimated:YES]) {
        if (self.backBlock) {
            self.backBlock(YES);
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


@end
