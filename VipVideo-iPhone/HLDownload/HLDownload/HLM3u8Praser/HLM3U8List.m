//
//  HLM3U8List.m
//  HLDownloadDemo
//
//  Created by LHL on 18/6/21.
//  Copyright © 2018年 LHL. All rights reserved.
//

#import "HLM3U8List.h"

@implementation HLM3U8List

- (instancetype)initWithSegments:(NSMutableArray *)segmentList
{
    if (self = [super init])
    {
        self.segments = segmentList;
        self.length = segmentList.count;
    }
    return self;
}


/**
 *  得到对应索引的片段内容
 *
 *  @param index
 *
 *  @return
 */
- (HLM3U8SegmentInfo *)getSegment:(NSInteger)index
{
    if( index >=0 && index < self.length)
    {
        return (HLM3U8SegmentInfo *)[self.segments objectAtIndex:index];
    }
    else
    {
        return nil;
    }
}

@end
