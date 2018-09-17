//
//  HLTVListViewController.h
//  MVideo
//
//  Created by LiHongli on 16/6/18.
//  Copyright © 2016年 LHL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HLTVListViewController : UIViewController

@property (nonatomic, strong) NSDictionary *dict;

+ (NSString *)getResultDocumentFilePath;

@end

