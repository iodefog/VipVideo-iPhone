//
//  HLSegmentProgresser.h
//  m3u8DownloadDemo
//
//  Created by LHL on 18/6/21.
//  Copyright © 2018年 LHL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HLSegmentProgresser : NSObject

@property (nonatomic, assign) double totalSize;
@property (nonatomic, assign) double writtenSize;
// 当前已写字节数 暂停使用
@property (nonatomic, assign) double totalWritten;


@end
