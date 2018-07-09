//
//  HLM3U8List.h
//  HLDownloadDemo
//
//  Created by LHL on 18/6/21.
//  Copyright © 2018年 LHL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLM3U8SegmentInfo.h"

@interface HLM3U8List : NSObject

/**
 *  片段数组
 */
@property (nonatomic, strong) NSMutableArray *segments;
/**
 *  片段个数
 */
@property (assign) NSInteger length;
/**
 *  父目录-视频目录
 */
@property (nonatomic,copy)NSString* filePath;

/**
 *  总时长
 */

@property (assign) double totalDuration;


- (instancetype)initWithSegments:(NSMutableArray *)segmentList;

/**
 *  得到对应索引的片段内容
 *
 *  @params index 片段
 *
 *  @return 片段信息
 */
- (HLM3U8SegmentInfo *)getSegment:(NSInteger)index;

@end
