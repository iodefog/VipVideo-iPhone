//
//  HLSegmentDownLoader.m
//  HLDownloadDemo
//
//  Created by LHL on 18/6/21.
//  Copyright © 2018年 LHL. All rights reserved.
//

#import "HLSegmentDownLoader.h"

static  NSString * const kCurrentSession = @"kCurrentSession";
static  NSLock *lock;
static  NSInteger QueueMax = 3;

@implementation HLSegmentDownLoader

- (void)dealloc{
    [self.resumableTask cancel];
}

- (instancetype)initWithUrl:(NSString *)url andFilePathName:(NSString *)pathName andFileName:(NSString *)fileName
{
    self = [super init];
    if(self != nil)
    {
        lock = [NSLock new];
        [lock lock];
        
        self.downloadUrl = url;
        self.fileName = fileName;
        self.filePathName = pathName;
        
        NSString *pathPrefix = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask,YES) objectAtIndex:0];
        // 拼接目录
        self.filePath = [[pathPrefix stringByAppendingPathComponent:kPathDownload] stringByAppendingPathComponent:self.filePathName];
        NSLog(@"------ %@",self.filePath);
        // 创建目录
        BOOL isDir = NO;
        NSFileManager *fm = [NSFileManager defaultManager];
        if(!([fm fileExistsAtPath:self.filePath isDirectory:&isDir] && isDir))
        {
            [fm createDirectoryAtPath:self.filePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        self.status = DownloadTaskStatusStopped;
        [lock unlock];

    }
    return  self;
}



// 开始下载
- (BOOL)start
{
    NSString *fileName = [self.filePath stringByAppendingPathComponent:self.fileName];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:fileName]) {
        self.status = DownloadTaskStatusStopped;
        if (self.delegate && [self.delegate respondsToSelector:@selector(segmentDownloadFinished:)])
        {
            [self.delegate segmentDownloadFinished:self];
        }
        return NO;
    }
    
    self.downloadUrl = [self.downloadUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.downloadUrl] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];
    
    self.resumableTask = [self.currentSession downloadTaskWithRequest:request];

    [self.resumableTask resume];
    
    self.status = DownloadTaskStatusRunning;
    return YES;
}

/**
 *  恢复下载
 */
- (void)resume{
    if (self.partialData)
    {
        self.resumableTask = [self.currentSession downloadTaskWithResumeData:self.partialData];
        self.status = DownloadTaskStatusRunning;
    }
}


/**
 *  停止  不可恢复
 */
-(void)cancel
{
    NSLog(@"segment download stop");
    
    if(self.resumableTask && self.status == DownloadTaskStatusRunning)
    {
        [self.resumableTask cancel];
    }
    self.status = DownloadTaskStatusStopped;
}

/**
 *  暂停下载
 */
-(void)suspend
{
    NSLog(@"segment download suspend");
    
    [self.resumableTask cancelByProducingResumeData:^(NSData *resumeData) {
        // 如果是可恢复的下载任务，应该先将数据保存到partialData中，注意在这里不要调用cancel方法
        self.partialData = resumeData;
        self.resumableTask = nil;
    }];
}

#pragma mark - NSURLSessionDownloadDelegate
/**
 *  下载成功才会调用
 *
 *  @params session        会话
 *  @params downloadTask   下载任务
 *  @params location       临时路径
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    self.status = DownloadTaskStatusSuccessed;

    // 下载完成 系统下载在tmp中
    NSError *fileManagerError = nil;
    if (self.filePath)
    {
        self.filePath = [self.filePath stringByAppendingPathComponent:self.fileName];
        if (![[NSFileManager defaultManager] fileExistsAtPath:self.filePath]) {
            [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:self.filePath] error:&fileManagerError];
        }
    }
    if (fileManagerError)
    {
        NSLog(@"fileManagerError:%@",fileManagerError);
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(segmentDownloadFinished:)])
    {
        [self.delegate segmentDownloadFinished:self];
    }
}

/* 完成下载任务，无论下载成功还是失败都调用该方法 */
// 暂停下载也会进来
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error)
    {
        if (error.code == NSURLErrorCancelled) {
            self.status = DownloadTaskStatusStopped;
        }else {
            self.status = DownloadTaskStatusFailure;
        }
        NSLog(@"下载失败:%@", error);
        if (self.delegate && [self.delegate respondsToSelector:@selector(segmentDownloadFailed:error:progresser:)])
        {
            [self.delegate segmentDownloadFailed:self error:error progresser:self.progresser];
        }
    }
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten // 当前写入字节数
 totalBytesWritten:(int64_t)totalBytesWritten // 已写字节数
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite // 全部字节数
{
    [lock lock];
    
    if (self.progresser.totalSize != (double)totalBytesExpectedToWrite)
    {
        self.progresser.totalSize = (double)totalBytesExpectedToWrite;
    }
    self.progresser.writtenSize = (double)bytesWritten;
    self.progresser.totalWritten = (double)totalBytesWritten;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(segmentDownload:progresser:)])
    {
        [self.delegate segmentDownload:self progresser:self.progresser];
    }
    
    [lock unlock];

}

// 恢复下载
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    NSLog(@"恢复下载: Resume download at %f", (double)fileOffset);
}


#pragma mark -

- (NSURLSession *)currentSession
{
    if (_currentSession == nil)
    {
        NSURLSessionConfiguration *defaultConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        queue.maxConcurrentOperationCount = QueueMax;
        
        self.currentSession = [NSURLSession sessionWithConfiguration:defaultConfig delegate:self delegateQueue:queue];
        self.currentSession.sessionDescription = kCurrentSession;
    }
    return _currentSession;
}

-(HLSegmentProgresser *)progresser
{
    if (_progresser == nil)
    {
        _progresser = [[HLSegmentProgresser alloc] init];
    }
    return _progresser;
}

@end
