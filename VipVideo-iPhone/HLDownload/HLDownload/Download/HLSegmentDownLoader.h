//
//  HLSegmentDownLoader.h
//  HLDownloadDemo
//
//  Created by LHL on 18/6/21.
//  Copyright © 2018年 LHL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLDownloadDelegate.h"
#import "HLSegmentProgresser.h"

#define kPathDownload @"Download"

typedef enum
{
    DownloadTaskStatusStopped = 0,
    DownloadTaskStatusRunning = 1,
    DownloadTaskStatusFailure = 2,
    DownloadTaskStatusSuccessed = 3,
}DownloadTaskStatus;

@interface HLSegmentDownLoader : NSObject<NSURLSessionDownloadDelegate>

@property(nonatomic, copy) NSString *fileName;
@property(nonatomic, copy) NSString *filePathName;
@property(nonatomic, copy) NSString *filePath;
@property(nonatomic, copy) NSString *downloadUrl;
@property(nonatomic, weak) id <HLSegmentDownloadDelegate>delegate;
@property(nonatomic,assign)DownloadTaskStatus status;
// 当前会话
@property(nonatomic, strong) NSURLSession *currentSession;
// 下载任务
@property(nonatomic, strong) NSURLSessionDownloadTask *resumableTask;
// 用于可恢复的下载任务的数据
@property(nonatomic, strong) NSData *partialData;
@property(nonatomic, strong) HLSegmentProgresser *progresser;

@property(nonatomic, copy) NSString *tmpFileName;

- (instancetype)initWithUrl:(NSString*)url
            andFilePathName:(NSString*)pathName
                andFileName:(NSString*)fileName;

/**
 *  开始、继续
 */
- (BOOL)start;
- (void)resume;
- (void)suspend;
- (void)cancel;

@end
