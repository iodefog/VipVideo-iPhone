//
//  FinishedViewController.m
//  QSPDownLoad_Demo
//
//  Created by 綦 on 17/3/29.
//  Copyright © 2017年 PowesunHolding. All rights reserved.
//

#import "FinishedViewController.h"
#import "QSPDownloadTool.h"
#import "HLPlayerViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "DownloadViewController.h"

@interface FinishedViewController ()<UITableViewDataSource, UITableViewDelegate, QSPDownloadToolDelegate>

@property (weak, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *dataArr;
@property (strong, nonatomic) UILabel *emptyLabel;

@end

@implementation FinishedViewController

- (NSMutableArray *)dataArr
{
    if (_dataArr == nil) {
        _dataArr = [NSMutableArray arrayWithArray:[QSPDownloadTool getFinishTasks]];
    }
    
    return _dataArr;
}

- (void)dealloc
{
    NSLog(@"%@ 销毁啦！", NSStringFromClass([self class]));
    [[QSPDownloadTool shareInstance] removeDownloadToolDelegate:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"已下载";
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"下载中" forState:UIControlStateNormal];
    [button setTitleColor:self.view.tintColor forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button addTarget:self action:@selector(pushFinishedVC:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setRightBarButtonItem:item];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    [self.view addSubview:tableView];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView = tableView;
    
    [[QSPDownloadTool shareInstance] addDownloadToolDelegate:self];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStyleDone target:self action:@selector(back)];
}

- (void)pushFinishedVC:(UIButton *)sender{
    DownloadViewController *finishVC = [[DownloadViewController alloc] init];
    finishVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:finishVC animated:YES];
}

- (void)back{}

#pragma mark - <UITableViewDataSource, UITableViewDelegate>代理方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   if (self.dataArr.count > 0) {
        [_emptyLabel removeFromSuperview];
    }
    else {
        [self.view addSubview:self.emptyLabel];
    }
    return self.dataArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"DownLoadCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    QSPDownloadSource *source = self.dataArr[indexPath.row];
    cell.textLabel.text = source.fileName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@",[QSPDownloadTool calculationDataWithBytes:source.totalBytesExpectedToWrite], source.createDate];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    QSPDownloadSource *source = self.dataArr[indexPath.row];
    NSLog(@"%@", source.location);
    HLPlayerViewController *playerVC = [[HLPlayerViewController alloc] init];
    playerVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [VipURLManager sharedInstance].currentPlayer = playerVC;
    if (source.location) {
        playerVC.url = [NSURL fileURLWithPath:source.location];        
    }
    playerVC.canDownload = NO;
    [self presentViewController:playerVC animated:YES completion:nil];
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[QSPDownloadTool shareInstance] stopDownload:self.dataArr[indexPath.row]];
        [self.dataArr removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];        
        NSMutableArray *mArr = [NSMutableArray arrayWithCapacity:1];
        for (QSPDownloadSource *source in self.dataArr) {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:source];
            [mArr addObject:data];
        }
        [mArr writeToFile:QSPDownloadTool_DownloadFinishedSources_Path atomically:YES];
    }
}

#pragma mark - <QSPDownloadToolDelegate>代理方法
- (void)downloadToolDidFinish:(QSPDownloadTool *)tool downloadSource:(QSPDownloadSource *)source
{
    [self.dataArr addObject:source];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.dataArr.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationMiddle];
}


#pragma mark -

- (UILabel *)emptyLabel{
    if (!_emptyLabel) {
        _emptyLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
        _emptyLabel.text = @"暂无数据";
        _emptyLabel.textAlignment = NSTextAlignmentCenter;
        _emptyLabel.textColor = [UIColor grayColor];
    }
    return _emptyLabel;
}

@end
