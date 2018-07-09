//
//  DownloadViewController.m
//  QSPDownLoad_Demo
//
//  Created by 綦 on 17/3/21.
//  Copyright © 2017年 PowesunHolding. All rights reserved.
//

#import "DownloadViewController.h"
#import "DownLoadCell.h"
#import "FinishedViewController.h"
#import "UIViewController+.h"
#import "HLPlayerViewController.h"

@interface DownloadViewController ()<UITableViewDataSource, UITableViewDelegate, QSPDownloadToolDelegate>

@property (strong, nonatomic) NSMutableArray *dataArr;
@property (strong, nonatomic) UILabel *emptyLabel;

@end

@implementation DownloadViewController

- (NSMutableArray *)dataArr
{
    if (_dataArr == nil) {
        _dataArr = [NSMutableArray array];
    }
    
    return _dataArr;
}

- (void)dealloc
{
    NSLog(@"%@ 销毁啦！", NSStringFromClass([self class]));
    [[QSPDownloadTool shareInstance] removeDownloadToolDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [_dataArr removeAllObjects];
    [_dataArr addObjectsFromArray:[QSPDownloadTool shareInstance].downloadSources];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"下载任务管理";
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"已完成" forState:UIControlStateNormal];
    [button setTitleColor:self.view.tintColor forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button addTarget:self action:@selector(pushFinishedVC:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setRightBarButtonItem:item];
    
    [[QSPDownloadTool shareInstance] addDownloadToolDelegate:self];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStyleDone target:self action:@selector(back)];
}

- (void)back{}

- (void)pushFinishedVC:(UIButton *)sender{
    FinishedViewController *finishVC = [[FinishedViewController alloc] init];
    finishVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:finishVC animated:YES];
}

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
    DownLoadCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[DownLoadCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.source = self.dataArr[indexPath.row];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (![[UIViewController topViewController] isKindOfClass:[HLPlayerViewController class]]) {
        QSPDownloadSource *source = self.dataArr[indexPath.row];
        
        HLPlayerViewController *playerVC = [[HLPlayerViewController alloc] init];
        playerVC.url = [NSURL fileURLWithPath:source.location];
        playerVC.canDownload = NO;
        [self presentViewController:playerVC animated:YES completion:nil];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return DownLoadCell_Height;
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
    }
}

#pragma mark - <QSPDownloadToolDelegate>代理方法
- (void)downloadToolDidFinish:(QSPDownloadTool *)tool downloadSource:(QSPDownloadSource *)source
{
    for (int index = 0; index < self.dataArr.count; index++) {
        QSPDownloadSource *currentSource = self.dataArr[index];
        if (currentSource.task == source.task) {
            [self.dataArr removeObject:currentSource];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationMiddle];
        }
    }
    
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
