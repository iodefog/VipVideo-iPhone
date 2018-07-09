//
//  HLM3U8SegmentInfo.h
//  HLDownloadDemo
//
//  Created by LHL on 18/6/21.
//  Copyright © 2018年 LHL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HLM3U8SegmentInfo : NSObject
/**
 *  片段长度
 */
@property(nonatomic,assign)NSInteger duration;
/**
 *  片段url
 */
@property(nonatomic,copy)NSString *locationUrl;

@end
