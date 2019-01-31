//
//  QSPDownloadTool.h
//  QSPDownload_Demo
//
//  Created by 綦 on 17/3/21.
//  Copyright © 2017年 PowesunHolding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HLDownload/HLDownload.h>

#define QSPDownloadTool_Document_Path                   [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
#define QSPDownloadTool_DownloadDataDocument_Path       [QSPDownloadTool_Document_Path stringByAppendingPathComponent:@"QSPDownloadTool_DownloadDataDocument_Path"]
#define QSPDownloadTool_DownloadSources_Path            [QSPDownloadTool_Document_Path stringByAppendingPathComponent:@"QSPDownloadTool_downloadSources.data"]
#define QSPDownloadTool_DownloadFinishedSources_Path     [QSPDownloadTool_Document_Path stringByAppendingPathComponent:@"QSPDownloadTool_DownloadFinishedSources.data"]
#define QSPDownloadTool_OffLineStyle_Key                @"QSPDownloadTool_OffLineStyle_Key"
#define QSPDownloadTool_OffLine_Key                     @"QSPDownloadTool_OffLine_Key"


typedef NS_ENUM(NSInteger, QSPDownloadSourceStyle) {
    QSPDownloadSourceStyleDown = 0,//下载
    QSPDownloadSourceStyleSuspend = 1,//暂停
    QSPDownloadSourceStyleStop = 2,//停止
    QSPDownloadSourceStyleFinished = 3,//完成
    QSPDownloadSourceStyleFail = 4//失败
};

@class QSPDownloadSource;
@protocol QSPDownloadSourceDelegate <NSObject>
@optional
- (void)downloadSource:(QSPDownloadSource *)source changedStyle:(QSPDownloadSourceStyle)style;
- (void)downloadSource:(QSPDownloadSource *)source didWriteData:(NSData *)data totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;

- (void)downloadSource:(QSPDownloadSource *)source
              progress:(CGFloat)progress;

@end

@interface QSPDownloadSource : NSObject <NSCoding>
//地址路径
@property (copy, nonatomic, readonly) NSString *netPath;
//本地路径
@property (copy, nonatomic, readonly) NSString *location;
//创建时间
@property (copy, nonatomic, readonly) NSDate *createDate;
//进度
@property (assign, nonatomic, readonly) CGFloat progress;
//下载状态
@property (assign, nonatomic, readonly) QSPDownloadSourceStyle style;
//mp4下载任务
@property (strong, nonatomic, readonly) NSURLSessionDataTask *task;
//m3u8下载任务
@property (strong, nonatomic, readonly) HLDownLoader *downloader;
//文件名称
@property (strong, nonatomic, readonly) NSString *fileName;
//已下载的字节数
@property (assign, nonatomic, readonly) int64_t totalBytesWritten;
//文件字节数
@property (assign, nonatomic, readonly) int64_t totalBytesExpectedToWrite;
//是否离线下载
@property (assign, nonatomic, getter=isOffLine) BOOL offLine;
//代理
@property (weak, nonatomic) id<QSPDownloadSourceDelegate> delegate;

@end


@class QSPDownloadTool;
@protocol QSPDownloadToolDelegate <NSObject>

- (void)downloadToolDidFinish:(QSPDownloadTool *)tool downloadSource:(QSPDownloadSource *)source;

@end

typedef NS_ENUM(NSInteger, QSPDownloadToolOffLineStyle) {
    QSPDownloadToolOffLineStyleDefaut = 0,//默认离线后暂停
    QSPDownloadToolOffLineStyleAuto = 1,//根据保存的状态自动处理
    QSPDownloadToolOffLineStyleFromSource = 2//根据保存的状态自动处理
};
@interface QSPDownloadTool : NSObject

/**
 下载的所有任务资源
 */
@property (strong, nonatomic, readonly) NSArray *downloadSources;
//离线后的下载方式
@property (assign, nonatomic) QSPDownloadToolOffLineStyle offLineStyle;

+ (instancetype)shareInstance;

/**
 按字节计算文件大小
 
 @param tytes 字节数
 @return 文件大小字符串
 */
+ (NSString *)calculationDataWithBytes:(int64_t)tytes;

/**
 添加下载任务

 @param netPath 下载地址
 @return 下载任务数据模型
 */
- (QSPDownloadSource *)addDownloadTast:(NSString *)netPath
                                 title:(NSString *)title
                            andOffLine:(BOOL)offLine;

/**
 添加代理
 
 @param delegate 代理对象
 */
- (void)addDownloadToolDelegate:(id<QSPDownloadToolDelegate>)delegate;
/**
 移除代理

 @param delegate 代理对象
 */
- (void)removeDownloadToolDelegate:(id<QSPDownloadToolDelegate>)delegate;

/**
 暂停下载任务

 @param source 下载任务数据模型
 */
- (void)suspendDownload:(QSPDownloadSource *)source;
/**
 暂停所有下载任务
 */
- (void)suspendAllTask;

/**
 继续下载任务

 @param source 下载任务数据模型
 */
- (void)continueDownload:(QSPDownloadSource *)source;
/**
 开启所有下载任务
 */
- (void)startAllTask;
/**
 停止下载任务

 @param source 下载任务数据模型
 */
- (void)stopDownload:(QSPDownloadSource *)source;
/**
 停止所有下载任务
 */
- (void)stopAllTask;
/**
 获取已经完成的下载任务
 */
+ (NSArray *)getFinishTasks;

@end


@interface QSPDownloadToolDelegateObject : NSObject

@property (weak, nonatomic) id<QSPDownloadToolDelegate> delegate;

@end
