//
//  VipURLManager.m
//  VipVideo
//
//  Created by LiHongli on 2017/10/20.
//  Copyright © 2017年 SV. All rights reserved.
//

#import "VipURLManager.h"
#import "AppDelegate.h"
#import "JSONKit.h"

#define OnlineVipUrl @"https://iodefog.github.io/text/viplist.json"

@implementation VipUrlItem

+ (instancetype)createTitle:(NSString *)title url:(NSString *)url{
    VipUrlItem *model = [[VipUrlItem alloc] init];
    model.title = title;
    model.url = url;
    return model;
}

@end

/*--------------------------*/

@interface VipMenuItem : NSObject

@property (nonatomic, strong) VipUrlItem *item;

@end



@implementation VipMenuItem

@end

/*--------------------------*/


@implementation VipURLManager

+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init{
    if (self = [super init]) {
        
        self.itemsArray = [NSMutableArray array];
        self.platformItemsArray = [NSMutableArray array];
        
        [self initVipURLs];
        self.currentIndex = 0;
        
        [self initDefaultData];
    }
    return self;
}

- (void)initDefaultData{
    NSError *error = nil;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"vlist" ofType:@"json"];
    if (!path) {
        return;
    }
    NSData *data = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:&error];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];

    [self transformJsonToModel:dict[@"list"]];
    [self transformPlatformJsonToModel:dict[@"platformlist"]];
}

- (void)initVipURLs{
    
    NSURL *url = [NSURL URLWithString:OnlineVipUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15];
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse * _Nullable response,
                                               NSData * _Nullable data,
                                               NSError * _Nullable connectionError) {
       if(!connectionError){
           NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
           
           BOOL update = [dict[@"i_new_version_info"][@"i_update"] boolValue];
           NSString *updateMsg = dict[@"i_new_version_info"][@"i_updateMessage"];
           BOOL limit = [dict[@"i_new_version_info"][@"i_needLimit"] boolValue];
           if (limit || update) {
               UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"app已失效" message:updateMsg preferredStyle:UIAlertControllerStyleAlert];
               UIAlertAction *updateAction = [UIAlertAction actionWithTitle:@"下载安装包" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                   NSLog(@"确定");
                   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://iodefog.github.io/dmg/VipVideo-iPhone.zip"]];
                   if (limit) {
                       exit(0);
                   }
               }];
               
               UIAlertAction *exitAction = [UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                   NSLog(@"退出");
                   if (limit) {
                       exit(0);
                   }
               }];
               
               [alert addAction:updateAction];
               [alert addAction:exitAction];

               [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
               return;
           }
       }else {
           NSLog(@"connectionError = %@",connectionError);
       }
   }];
}

- (void)transformPlatformJsonToModel:(NSArray *)jsonArray
{
    if ([jsonArray isKindOfClass:[NSArray class]]) {
        NSMutableArray *urlsArray = [NSMutableArray array];
        for (NSDictionary *dict in jsonArray) {
            VipUrlItem *item = [[VipUrlItem alloc] init];
            item.title = dict[@"name"];
            item.icon = dict[@"icon"];
            item.url = dict[@"url"];
            [urlsArray addObject:item];
        }
        
        [self.platformItemsArray removeAllObjects];
        [self.platformItemsArray addObjectsFromArray:urlsArray];
    }
}


- (void)transformJsonToModel:(NSArray *)jsonArray
{
    if ([jsonArray isKindOfClass:[NSArray class]]) {
        NSMutableArray *urlsArray = [NSMutableArray array];
        for (NSDictionary *dict in jsonArray) {
            VipUrlItem *item = [[VipUrlItem alloc] init];
            item.title = dict[@"name"];
            item.icon = dict[@"icon"];
            item.url = dict[@"url"];
            [urlsArray addObject:item];
        }
        
        [self.itemsArray removeAllObjects];
        [self.itemsArray addObjectsFromArray:urlsArray];
    }
}

- (NSString *)currentVipApi{
    if (_currentVipApi) {
       return _currentVipApi;
    }
    else {
        VipUrlItem *item = [self.itemsArray firstObject];
        return item.url;
    }
}

- (void)willChangeVideoItem:(VipUrlItem *)item{
    [[NSNotificationCenter defaultCenter] postNotificationName:KHLVipVideoCurrentApiWillChange object:nil];
}

- (void)changeVideoItem:(VipUrlItem *)item{
    self.currentVipApi = item.url;
    self.currentIndex = [self.itemsArray indexOfObject:item];
    
    if (self.currentVipApi) {
        [[NSUserDefaults standardUserDefaults] setObject:self.currentVipApi forKey:KHLVipVideoCurrentApiDidChange];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:KHLVipVideoCurrentApiDidChange object:nil];
    }
}

- (void)setCurrentIndex:(NSInteger)currentIndex{
    if (_currentIndex != currentIndex) {
        VipUrlItem *item = self.itemsArray[currentIndex];
        self.currentVipApi = item.url;

        _currentIndex = currentIndex;

    }
}

@end
