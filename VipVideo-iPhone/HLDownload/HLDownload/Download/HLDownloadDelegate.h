//
//  DownloadDelegate.h
//  HLDownloadDemo
//
//  Created by LHL on 18/6/21.
//  Copyright © 2018年 LHL. All rights reserved.
//
#import <Foundation/Foundation.h>

@class HLSegmentDownLoader;
@class HLSegmentProgresser;
@protocol HLSegmentDownloadDelegate <NSObject>
@optional
-(void)segmentDownloadFinished:(HLSegmentDownLoader *)downLoader;
-(void)segmentDownloadFailed:(HLSegmentDownLoader *)downLoader
                       error:(NSError *)error
                  progresser:(HLSegmentProgresser *)progresser;
// 进度
- (void)segmentDownload:(HLSegmentDownLoader *)downLoader
             progresser:(HLSegmentProgresser *)progresser;

@end


@class HLDownLoader;
@protocol HLDownloadDelegate <NSObject>
@optional
-(void)downloaderFinished:(HLDownLoader *)download;
-(void)downloaderFailed:(HLDownLoader *)download; // 暂未使用
-(void)downloader:(HLDownLoader *)download progress:(double)progess;
@end
