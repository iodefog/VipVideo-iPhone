//
//  HLSegmentProgresser.m
//  m3u8DownloadDemo
//
//  Created by LHL on 18/6/21.
//  Copyright © 2018年 LHL. All rights reserved.
//

#import "HLSegmentProgresser.h"

@implementation HLSegmentProgresser

-(instancetype)init
{
    if (self = [super init])
    {
        self.totalSize = 0.0;
        self.totalWritten = 0.0;
        self.writtenSize = 0.0;
    }
    return self;
}

@end
