//
//  HLHomeViewController.m
//  VipVideo-iPhone
//
//  Created by LiHongli on 2019/1/12.
//  Copyright © 2019 SV. All rights reserved.
//

#import "HLHomeViewController.h"
#import "HLWebVideoViewController.h"
#import "VipURLManager.h"
#import "Masonry.h"

@interface HLHomeCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) VipUrlItem    *object;
@property (nonatomic, strong) UIImageView   *iconImageView;
@property (nonatomic, strong) UILabel       *titleLabel;

@end

@implementation HLHomeCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createUI];
    }
    
    return self;
}

- (void)createUI
{
    self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.iconImageView.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1];
    self.iconImageView.layer.cornerRadius = 10;
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.textColor = [UIColor lightGrayColor];
    self.titleLabel.font = [UIFont systemFontOfSize:13];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.titleLabel];
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(self.contentView.mas_width).multipliedBy(2/3.0);
        make.center.equalTo(self.contentView);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.top.equalTo(self.iconImageView.mas_bottom).offset(5);
        make.height.mas_equalTo(17);
    }];
}

- (void)setObject:(VipUrlItem *)object
{
    self.titleLabel.text = object.title;
    self.iconImageView.image = [UIImage imageNamed:object.icon];
    if (!self.iconImageView.image) {
        self.iconImageView.image = [UIImage imageNamed:@"视频"];
    } else {
        self.iconImageView.backgroundColor = [UIColor clearColor];
    }
}

@end


#pragma mark ---

#define kHLHomeMaxColumCount  5

@interface HLHomeViewController ()

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation HLHomeViewController

- (instancetype)init
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat itemWidth = CGRectGetWidth([UIScreen mainScreen].bounds)/kHLHomeMaxColumCount;
    flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth + 20);
    flowLayout.headerReferenceSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), 20);
    
    if (self = [super initWithCollectionViewLayout:flowLayout]) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];//获取app版本信息
    self.title = [infoDictionary objectForKey:@"CFBundleDisplayName"];;
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    self.dataArray = [NSMutableArray arrayWithArray:[VipURLManager sharedInstance].platformItemsArray];
    [self.collectionView registerClass:[HLHomeCollectionViewCell class] forCellWithReuseIdentifier:@"HLHomeCollectionViewCell"];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (HLHomeCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"HLHomeCollectionViewCell";
    HLHomeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    
    if (indexPath.row < self.dataArray.count) {
        cell.object = self.dataArray[indexPath.row];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    id object = self.dataArray[indexPath.row];

    HLWebVideoViewController *videoVC = [[HLWebVideoViewController alloc] init];
    videoVC.urlItem = object;
    UINavigationController *videoNav = [[UINavigationController alloc] initWithRootViewController:videoVC];
    
    [self presentViewController:videoNav animated:YES completion:nil];
}

@end
