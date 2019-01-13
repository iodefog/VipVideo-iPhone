//
//  VipURLManager.h
//  VipVideo
//
//  Created by LiHongli on 2017/10/20.
//  Copyright © 2017年 SV. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KHLVipVideoCurrentApiWillChange     @"KHLVipVideoCurrentApiWillChange"
#define KHLVipVideoCurrentApiDidChange      @"KHLVipVideoCurrentApiDidChange"
#define KHLVipVideoRequestSuccess           @"KHLVipVideoRequestSuccess"

@interface VipUrlItem:NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSString *url;

+ (instancetype)createTitle:(NSString *)title url:(NSString *)url;

@end

/*--------------------------*/

@interface VipURLManager : NSObject

@property (nonatomic, strong) NSMutableArray *itemsArray;
@property (nonatomic, strong) NSMutableArray *platformItemsArray;

@property (nonatomic, strong) NSString *currentVipApi;
@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, weak) id currentPlayer;


+ (instancetype)sharedInstance;
- (void)changeVideoItem:(VipUrlItem *)item;


@end
