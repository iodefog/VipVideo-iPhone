//
//  HLDownLoader.h
//  HLDownloadDemo
//
//  Created by LHL on 18/6/21.
//  Copyright © 2018年 LHL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLM3U8List.h"
#import "HLSegmentDownLoader.h"

#define HLDownLoaderStateChange @"HLDownLoaderStateChange"

typedef enum : NSUInteger {
    HLDownLoaderState_Wait,
    HLDownLoaderState_Downloading,
    HLDownLoaderState_Pause,
    HLDownLoaderState_Cancel,
    HLDownLoaderState_Finish
} HLDownLoaderState;

@interface HLDownLoader : NSObject<HLSegmentDownloadDelegate>

@property(nonatomic, weak) id <HLDownloadDelegate> delegate;
@property(nonatomic, strong) HLM3U8List *playlist;
@property(nonatomic, strong) NSURL      *m3u8url;

// 当前写入大小
@property(nonatomic, assign) double writtenSize;
// 总大小
@property(nonatomic, assign) double totalSize;
// 当前总写入大小
@property (nonatomic, assign) double totalWrittenSize;
// 整体进度
@property(nonatomic, assign) double progress;
@property(nonatomic, assign) HLDownLoaderState state;
/**
 *  分段下载器数组
 */
@property (nonatomic, strong) NSMutableArray *downloadArray;
/**
 *  每个视频的目录
 */
@property (nonatomic, copy) NSString *filePath;

/**
 *  本地m3u8地址
 */
@property (nonatomic, copy) NSString *localM3U8;


-(instancetype)initWithHLM3U8List:(HLM3U8List *)list;


/**
 *  开始下载
 */
- (void)startDownload;

/**
 *  继续下载
 */
-(void)resumeDownload;

/**
 *  暂停下载
 */
- (void)suspendDownload;

/**
 *  取消下载
 */
- (void)cancelDownload;

@end
