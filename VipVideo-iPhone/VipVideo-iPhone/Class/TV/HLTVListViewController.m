//
//  HLTVListViewController.m
//  MVideo
//
//  Created by LiHongli on 16/6/18.
//  Copyright © 2016年 LHL. All rights reserved.
//

#import "HLTVListViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>
#import "ListTableViewCell.h"
//#import "KxMovieViewController.h"
#import "HLPlayerViewController.h"
#import "MMovieModel.h"
#import "Masonry.h"

#define CanPlayResult   @"CanPlayResult"

@interface HLTVListViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, strong) UITableView       *liveListTableView;
@property (nonatomic, strong) UISwitch          *autoPlaySwitch;
@property (nonatomic, strong) UIViewController  *playerController;
@property (nonatomic, strong) NSMutableArray    *originalSource;
@property (nonatomic, strong) NSMutableArray    *dataSource;
@property (nonatomic, assign) BOOL              kxResetPop;

@property (nonatomic, strong) UISearchBar       *searchBar;

@end

@implementation HLTVListViewController

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.dataSource = [NSMutableArray array];
        self.originalSource = [NSMutableArray array];
    }
    return self;
}

- (void)setNeedsStatusBarAppearanceUpdate{
    self.searchBar.frame = CGRectMake(0, kNavgationBarHeight, self.view.bounds.size.width, 44);
    self.liveListTableView.frame = CGRectMake(0, self.searchBar.frame.size.height + kNavgationBarHeight, self.view.bounds.size.width, self.view.bounds.size.height-self.searchBar.frame.size.height);
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationPortrait;
    self.searchBar.frame = CGRectMake(0, kNavgationBarHeight, self.view.bounds.size.width, 44);
    self.liveListTableView.frame = CGRectMake(0, self.searchBar.frame.size.height + kNavgationBarHeight, self.view.bounds.size.width, self.view.bounds.size.height-self.searchBar.frame.size.height - kNavgationBarHeight);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = self.dict[@"title"] ?: @"电台直播";

    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.liveListTableView];
    
    [self addBackgroundMethod];
    [self requestNetWorkData];
    [self registerObserver];
//    [self setNavgationRightItem];
    [self addMasonry];
}

/**
 *  添加约束
 */
- (void)addMasonry{
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(@(kNavgationBarHeight));
        make.height.mas_equalTo(44);
    }];
    
    [self.liveListTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.searchBar.mas_bottom);
    }];
}

/**
 *  导航条右边添加自动返回开关
 */
- (void)setNavgationRightItem{
    self.autoPlaySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(100-30, 0, 30, 20)];
    [self.autoPlaySwitch addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
    NSNumber *oldValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"kAutoPlaySwitch"];
    self.autoPlaySwitch.on = oldValue ? oldValue.boolValue : YES;
    
    UILabel *tipLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    tipLable.userInteractionEnabled = YES;
    tipLable.text = @"自动返回";
    tipLable.font = [UIFont systemFontOfSize:14];
    [tipLable addSubview:self.autoPlaySwitch];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:tipLable];
}


/**
 *  Switch 开关值改变方法回调
 *
 *  @param sender switch
 */
- (void)valueChange:(UISwitch *)sender{
    [[NSUserDefaults standardUserDefaults] setObject:@(sender.on) forKey:@"kAutoPlaySwitch"];
}

/**
 *  添加后台方法
 */
- (void)addBackgroundMethod{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
}

/**
 *  处理文件，如果是本地文件，读取文件字符串，转换
    如果是网络文件，则下载文件。然后转换。
 */
- (void)operationStr{
    NSString *filePath = self.dict[@"filePath"];
    __block NSError *error = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        // 去除路径下的某个txt文件
        NSString *videosText = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
        [self transformVideoUrlFromString:videosText error:error];
        [self.liveListTableView reloadData];
    }
    // 网络请求文件
    else if([filePath hasPrefix:@"http"]){
        
        NSString *result = nil;
        if (filePath) {
           result =  [[NSUserDefaults standardUserDefaults] objectForKey:filePath];
        }
        [self transformVideoUrlFromString:result error:error];
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSString *videosText = [NSString stringWithContentsOfURL:[NSURL URLWithString:filePath] encoding:NSUTF8StringEncoding error:&error];
            [self transformVideoUrlFromString:videosText error:error];
            if (filePath && videosText) {
                [[NSUserDefaults standardUserDefaults] setObject:videosText forKey:filePath];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.liveListTableView reloadData];
            });
        });
    }
}

/**
 *  转换字符串变成视频url+name
 *
 *  @param videosText 视频播放的url
 *  @param error      是否有错误
 */
- (void)transformVideoUrlFromString:(NSString *)videosText error:(NSError *)error
{
    [self.originalSource removeAllObjects];
    [self.dataSource removeAllObjects];
    
    // 过滤掉特殊字符 "\r"。有些url带有"\r",导致转换失败
    videosText = [videosText stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    if (!error && (videosText.length > 0)) {
        NSMutableArray *itemArray = [NSMutableArray array];
        // 依据换行符截取一行字符串
        NSArray *videosArray = [videosText componentsSeparatedByString:@"\n"];
        
        for (NSString *subStr in videosArray) {
            // 根据"," 和" " 分割一行的字符串
            NSArray *subStrArray = [subStr componentsSeparatedByString:@","];
            NSArray *sub2StrArray = [subStr componentsSeparatedByString:@" "];
            
            if(subStrArray.count == 2 || (sub2StrArray.count == 2)){
                NSArray *tempArray = (subStrArray.count == 2)? subStrArray : sub2StrArray;
                itemArray = [self checkMultipleUrlInOneUrlWithUrl:[tempArray lastObject] videoName:[tempArray firstObject] itemArray:itemArray];
            }
            else if ([subStr stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0){
                // nothing
            }
            else if (subStrArray.count >= 3 || (sub2StrArray.count >= 3)){
                NSArray *tempArray = (subStrArray.count >= 3)? subStrArray : sub2StrArray;
                NSString *tempUrl = [tempArray objectAtIndex:1];
                itemArray = [self checkMultipleUrlInOneUrlWithUrl:tempUrl.length>5?tempUrl:[tempArray objectAtIndex:2] videoName:[tempArray firstObject] itemArray:itemArray];
            }
            else {
                subStrArray = [subStr componentsSeparatedByString:@" "];
                itemArray = [self checkMultipleUrlInOneUrlWithUrl:[subStrArray lastObject] videoName:[subStrArray firstObject] itemArray:itemArray];
            }
        }
        [self.originalSource addObjectsFromArray:itemArray];
        [self.dataSource addObjectsFromArray:itemArray];
    }else {
        NSLog(@"error %@", error);
    }
}

- (NSMutableArray *)checkMultipleUrlInOneUrlWithUrl:(NSString *)url
                              videoName:(NSString *)videoName
                              itemArray:(NSMutableArray *)itemArray
{
    NSArray *multipleArray = [url componentsSeparatedByString:@"#"];
    for (NSString *itemUrl in multipleArray) {
      MMovieModel *model = [MMovieModel getMovieModelWithTitle:videoName ?: @"" url:itemUrl ?: @""];
        [itemArray addObject:model];
      /*
        if (![self isContainObject:itemUrl] && itemUrl && videoName) {
            [self writeNotRepeatURL:itemUrl name:videoName fileName:@"NotRepeat"];
        }
        else {
            [self writeNotRepeatURL:itemUrl name:videoName fileName:@"Repeat"];
        }
       */
    }
    return itemArray;
}
    
/**
 *  检查是否有重复url
 *
 *  @param url url description
 *
 *  @return 重复 YES， 不重复返回NO
 */
- (BOOL)isContainObject:(NSString *)url{
    NSString *document = [NSString stringWithFormat:@"%@/Documents/urlsSet.plist",NSHomeDirectory()];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:document]) {
        [[NSFileManager defaultManager] createFileAtPath:document contents:nil attributes:nil];
    }
    
    NSMutableArray *urlArray = [NSMutableArray arrayWithContentsOfFile:document];
    BOOL contain = [urlArray containsObject:url];
    [urlArray addObject:url];
    NSSet *urlSet = [NSSet setWithArray:urlArray];
    urlArray = (id)[urlSet allObjects];
    [urlArray writeToFile:document atomically:YES];
    return contain;
}

/**
 *  把重复的保存在一起，不重复的保存在一起
 *
 *  @param url      url description
 *  @param name     TV name
 *  @param fileName 保存文件名
 */
- (void)writeNotRepeatURL:(NSString *)url name:(NSString *)name fileName:(NSString *)fileName{
    NSString *document = [NSString stringWithFormat:@"%@/Documents/%@.txt",NSHomeDirectory(), fileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:document]) {
        [[NSFileManager defaultManager] createFileAtPath:document contents:nil attributes:nil];
    }
    NSLog(@"Home ==== %@", document);
    
    NSError *error = nil;
    NSString *NotRepeat = [NSString stringWithContentsOfFile:document encoding:NSUTF8StringEncoding error:&error];
   NotRepeat = [NotRepeat stringByAppendingFormat:@"%@,%@\n",name, url];
    NSLog(@"读取字符串 error %@", error);
    [NotRepeat writeToFile:document atomically:YES encoding:NSUTF8StringEncoding error:&error];
    NSLog(@"写入 error %@", error);
}
    
/**
 *  注册前后台观察者
 *  进入后台，暂停。进去前台，播放
 */
- (void)registerObserver{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}


- (void)applicationWillEnterForegroundNotification:(NSNotification *)notification{
        [((MPMoviePlayerViewController *)self.playerController).moviePlayer play];
}

- (void)applicationDidEnterBackgroundNotification:(NSNotification *)notification{
        [((MPMoviePlayerViewController *)self.playerController).moviePlayer pause];
}

#pragma mark - Private Method

- (UISearchBar *)searchBar{
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, kNavgationBarHeight, self.view.bounds.size.width, 44)];
        _searchBar.searchBarStyle = UISearchBarStyleDefault;
        _searchBar.tintColor = [UIColor lightTextColor];
        _searchBar.returnKeyType = UIReturnKeySearch;
        _searchBar.placeholder = @"请输入要搜索的文字";
        _searchBar.delegate = self;
    }
    return _searchBar;
}

- (UITableView *)liveListTableView{
    if (_liveListTableView == nil) {
        _liveListTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.searchBar.frame.size.height + kNavgationBarHeight, self.view.bounds.size.width, self.view.bounds.size.height-self.searchBar.frame.size.height) style:UITableViewStylePlain];
        _liveListTableView.delegate = self;
        _liveListTableView.estimatedRowHeight = 100;
        _liveListTableView.rowHeight = UITableViewAutomaticDimension;
        _liveListTableView.dataSource = self;
        [_liveListTableView registerClass:[ListTableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    }
    return _liveListTableView;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - scroll delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.searchBar resignFirstResponder];
}

#pragma mark - tableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (ListTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellName = @"cellName";
    ListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (cell == nil) {
        cell = [[ListTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellName];
    }
    
    if (indexPath.row < [self.dataSource count]) {
        MMovieModel *model =  self.dataSource[indexPath.row];
        [cell setObject:model];
        cell.nameLabel.text = [NSString stringWithFormat:@"%@-%@",@(indexPath.row+1), model.title];
//        [cell checkIsCanPlay:cell.urlLabel.text fileName:self.dict[@"title"]];
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < [self.dataSource count]) {
        
        ListTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        MMovieModel *model =  self.dataSource[indexPath.row];

        // 可播，则转移到下一个播放
        if (self.autoPlaySwitch.isOn && (model.canPlay == YES)) {
            [self autoPlayNextVideo:indexPath delegate:self];
            return;
        }

        
        if (![tableView.visibleCells containsObject:cell]) {
            if ((indexPath.row+2) < [self.dataSource count]) {
                [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(indexPath.row+2) inSection:indexPath.section] atScrollPosition:UITableViewScrollPositionNone animated:YES];
            }else {
                [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(indexPath.row) inSection:indexPath.section] atScrollPosition:UITableViewScrollPositionNone animated:YES];
            }
        }
        
        NSString *videoName = model.title;
        NSString *movieUrl = [model.url stringByReplacingOccurrencesOfString:@"[url]" withString:@""];
        
        NSLog(@"title%@\n url = %@", videoName, movieUrl);
        self.title = videoName;
        
        [self playVideoWithMovieUrl:movieUrl movieName:videoName indexPath:indexPath];
    }
}

-(void)viewDidLayoutSubviews {
    if ([self.liveListTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.liveListTableView setSeparatorInset:UIEdgeInsetsZero];
        
    }
    if ([self.liveListTableView respondsToSelector:@selector(setLayoutMargins:)])  {
        [self.liveListTableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPat{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]){
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 54;
}

#pragma mark - private Method

/**
 *  播放某一个index下的视频。对于可播放的，存储。然后根据条件自动判断是否进行下一个视频播放
 *
 *  kxResetPop 当自动进行下一个播放时，设置为NO，当进行点击操作时，变为YES，这样dispatch_after（）就可以判断不用自动进行下一个了。另外条件就是switch开关。
 *
 *  @param movieUrl  视频的播放地址
 *  @param movieName 视频的名称
 *  @param indexPath 当前播放的视频cell的索引
 */
- (void)playVideoWithMovieUrl:(NSString *)movieUrl
                    movieName:(NSString *)movieName
                    indexPath:(NSIndexPath *)indexPath{
    if (movieUrl == nil) {
        return;
    }
    
    HLPlayerViewController *playerVC = [[HLPlayerViewController alloc] init];
    [VipURLManager sharedInstance].currentPlayer = playerVC;
    playerVC.canDownload = NO;
    playerVC.url = [NSURL URLWithString:movieUrl];
    __weak typeof(self) weakself = self;
    [playerVC setBackCompleteBlock:^(BOOL finish) {
        __strong typeof(self) strongself = weakself;
        if (strongself) {
            [strongself dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    
    [self presentViewController:playerVC animated:YES completion:nil];
}



/**
 *  自动播放下一个cell里的视频
 *
 *  @param currentIndexPath 当前播放的视频cell索引
 *  @param vc 代理
 */
- (void)autoPlayNextVideo:(NSIndexPath *)currentIndexPath delegate:(HLTVListViewController *)vc{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentIndexPath.row+1 inSection:0];
    [vc tableView:self.liveListTableView didSelectRowAtIndexPath:indexPath];
}

/**
 *  根据一个列表产生一个可播放地址列表
 *
 *  @param movieUrl 播放地址
 */
- (void)saveCanPlayHistory:(NSString *)movieUrl{
    NSMutableDictionary *canPlaylistDict = [NSMutableDictionary dictionary];
    [canPlaylistDict setDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:self.dict[@"title"]]];
    [canPlaylistDict setValue:movieUrl forKey:movieUrl];
    // 保存到 NSUserDefaults
    [[NSUserDefaults standardUserDefaults] setObject:canPlaylistDict forKey:self.dict[@"title"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 *  保存可以播放的地址进入沙盒
 *
 *  @param movieUrl 播放地址
 *  @param name     播放地址名称
 */
- (void)saveCanPlayHistoryToDocument:(NSString *)movieUrl name:(NSString *)name{
    NSString *documentPath = [HLTVListViewController getResultDocumentFilePath];
    NSError *error = nil;
    NSString *oldString = [NSString stringWithContentsOfFile:documentPath encoding:NSUTF8StringEncoding error:&error];
    if (!error) {
        NSLog(@"读取字符串 error %@", error);
    }
    NSString *newString = [NSString stringWithFormat:@"%@\n%@ %@",oldString?:@"", name, movieUrl];
    BOOL success = [newString writeToFile:documentPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (!error || !success) {
        NSLog(@"写入字符串 error %@， success %d", error, success);
    }
}

/**
 *  获取过滤后的列表存储地址
 *
 *  @return 沙盒存储地址
 */
+ (NSString *)getResultDocumentFilePath{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    documentPath = [NSString stringWithFormat:@"%@/%@.txt", documentPath, CanPlayResult];
    if (![[NSFileManager defaultManager] fileExistsAtPath:documentPath]) {
        [[NSFileManager defaultManager] createFileAtPath:documentPath contents:nil attributes:nil];
    }
    NSLog(@"documentPath  %@", documentPath);
    return documentPath;
}


#pragma mark - SearchBar delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSLog(@"searchBar %@, searchText %@",searchBar.text, searchText );
    if ([searchBar.text stringByReplacingOccurrencesOfString:@" " withString:@""].length > 0) {
        [self filterDataSourceWithKey:searchBar.text finish:NO];
    }else{
        [self.dataSource removeAllObjects];
        [self.dataSource addObjectsFromArray:self.originalSource];
        [self.liveListTableView reloadData];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{

    if ([searchBar.text stringByReplacingOccurrencesOfString:@" " withString:@""].length > 0) {
        [self filterDataSourceWithKey:searchBar.text finish:YES];
    }else {
        [self.dataSource removeAllObjects];
        [self.dataSource addObjectsFromArray:self.originalSource];
        [self.liveListTableView reloadData];
    }
}

- (void)filterDataSourceWithKey:(NSString *)searchKey finish:(BOOL)finish{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title CONTAINS %@", searchKey];
    NSArray *persons = [self.originalSource filteredArrayUsingPredicate:predicate];
    NSLog(@"************ \n%@", persons);
    
    
    if (persons.count) {
        [self.dataSource removeAllObjects];
        [self.dataSource addObjectsFromArray:persons];
        [self.liveListTableView reloadData];
    }else if(!finish && persons.count==0){
        [self.dataSource removeAllObjects];
        [self.liveListTableView reloadData];
    }
    else {
        [[[UIAlertView alloc] initWithTitle:nil message:@"筛选无结果" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:Nil, nil] show];
    }
}

#pragma mark -

#define FileNamePre         @"LiveList"
#define TVHostURL           @"https://iodefog.github.io/text/"
#define VideosTVListName    @"VideosTVListName.txt"

- (void)requestNetWorkData{
    
    NSString *videosTVListNameUrl = [NSString stringWithFormat:@"%@%@", TVHostURL,VideosTVListName];
    
    __block NSError *error = nil;
    
    NSString *result = nil;
    if (videosTVListNameUrl) {
        result =  [[NSUserDefaults standardUserDefaults] objectForKey:videosTVListNameUrl];
    }
    [self transformRootVideoUrlFromString:result error:error];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *videoList = [NSString stringWithContentsOfURL:[NSURL URLWithString:videosTVListNameUrl] encoding:NSUTF8StringEncoding error:&error];
        error ? NSLog(@"%@", error) : nil;
        [self transformRootVideoUrlFromString:videoList error:error];
        
        if (videosTVListNameUrl && videoList) {
            [[NSUserDefaults standardUserDefaults] setObject:videoList forKey:videosTVListNameUrl];
        }
    });
}

- (void)transformRootVideoUrlFromString:(NSString *)videoList error:(NSError *)error
{
    [self.dataSource removeAllObjects];
    NSArray *titleArray = [videoList componentsSeparatedByString:@"\n"];
    for (NSString *title in titleArray) {
        [self.dataSource addObject:@{@"title":title,
                                     @"filePath":[NSString stringWithFormat:@"%@%@", TVHostURL, title]}];
    }
    
    NSDictionary *firstDict = [self.dataSource firstObject];
    self.dict = firstDict;
    
    [self operationStr];
}

@end
