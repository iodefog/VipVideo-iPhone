//
//  DownLoadCell.h
//  QSPDownLoad_Demo
//
//  Created by 綦 on 17/3/26.
//  Copyright © 2017年 PowesunHolding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QSPDownloadTool.h"

#define DownLoadCell_Height         50.0
@interface DownLoadCell : UITableViewCell

@property (strong, nonatomic) QSPDownloadSource *source;

@end
