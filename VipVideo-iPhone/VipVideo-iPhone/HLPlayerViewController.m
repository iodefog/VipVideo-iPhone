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

- (void)forceInterfaceOrientation:(UIInterfaceOrientation)orientation {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector             = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = (int)orientation;
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
    if (self.backCompleteBlock) {
        self.backCompleteBlock(YES);
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
    wmplayer.isFullscreen = !wmplayer.isFullscreen;
}


-(void)wmplayer:(WMPlayer *)wmplayer clickedCloseButton:(UIButton *)backBtn{
    if (self.backCompleteBlock) {
        self.backCompleteBlock(YES);
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
        if (self.backCompleteBlock) {
            self.backCompleteBlock(YES);
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


@end
