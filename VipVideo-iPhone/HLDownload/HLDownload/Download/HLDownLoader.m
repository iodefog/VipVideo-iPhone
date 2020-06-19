
//  HLDownLoader.m
//  HLDownloadDemo
//
//  Created by LHL on 18/6/21.
//  Copyright © 2018年 LHL. All rights reserved.
//

#import "HLDownLoader.h"

#define MAXCount 3

static NSLock *downloadLock;

@interface HLDownLoader()

@property (nonatomic, strong) NSMutableArray *isDownloadingArray;
@property (nonatomic, strong) NSMutableArray *downloadFailArray;

@property (nonatomic, strong) dispatch_queue_t dispatchQueue;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@end

@implementation HLDownLoader

-(instancetype)initWithHLM3U8List:(HLM3U8List *)list
{
    if (self = [super init])
    {
        self.playlist = list;
        self.progress = 0.0;
        self.writtenSize = 0.0;
        self.totalSize = 0.0;
        self.filePath = self.playlist.filePath;
        self.isDownloadingArray = [NSMutableArray arrayWithCapacity:MAXCount];
        self.downloadFailArray = [NSMutableArray array];
        downloadLock = [[NSLock alloc] init];
        
        self.dispatchQueue = dispatch_queue_create("com.lhl.downloader", nil);
        self.semaphore = dispatch_semaphore_create(1);
    }
    return  self;
}

/**
 *  开始下载
 */
-(void)startDownload
{
    [self.downloadArray removeAllObjects];
    [self.downloadFailArray removeAllObjects];
    
    for(int i = 0;i< self.playlist.length;i++)
    {
        // 一个文件名
        NSString *fileName = [NSString stringWithFormat:@"%d.ts",i];
        // 根据索引获得片段info
        HLM3U8SegmentInfo *segment = [self.playlist getSegment:i];
        // 创建分段下载器
        HLSegmentDownLoader *sgDownloader = [[HLSegmentDownLoader alloc]
                                             initWithUrl:segment.locationUrl
                                             andFilePathName:self.playlist.filePath
                                             andFileName:fileName];
        sgDownloader.delegate = self;
        [self.downloadArray addObject:sgDownloader];
    }
    
    [self downloadNext:nil];
    
    self.state = HLDownLoaderState_Downloading;
    
    self.localM3U8 = [self createLocalM3U8file];
}

-(void)resumeDownload
{
    [self.downloadFailArray removeAllObjects];
    
    for(HLSegmentDownLoader *obj in self.downloadArray)
    {
        [obj resume];
    }
    self.state = HLDownLoaderState_Downloading;
}

/**
 *  暂停下载
 */
- (void)suspendDownload
{
    [downloadLock lock];
    [self.downloadFailArray removeAllObjects];
    NSLog(@"suspendDownload");
    if(self.state != HLDownLoaderState_Downloading && self.downloadArray != nil)
    {
        for(HLSegmentDownLoader *obj in self.downloadArray)
        {
            [obj suspend];
        }
        self.state = HLDownLoaderState_Pause;
    }
    [downloadLock unlock];
}

/**
 *  取消下载
 */
- (void)cancelDownload{
    [downloadLock lock];
    [self.downloadFailArray removeAllObjects];
    for(HLSegmentDownLoader *obj in self.downloadArray)
    {
        [obj cancel];
    }
    
    [self.downloadArray removeAllObjects];
    self.state = HLDownLoaderState_Cancel;
    [downloadLock unlock];
}

- (void)downloadNext:(HLSegmentDownLoader *)downloader{
    dispatch_async(self.dispatchQueue, ^{
        dispatch_semaphore_wait(self.semaphore, 1);
        
        if (self.downloadArray.count == 0) {
            if (downloader) {
                [self.isDownloadingArray removeObject:downloader];
            }
            return;
        }
        
        NSMutableArray *tempArray = [NSMutableArray array];
        [self.isDownloadingArray enumerateObjectsUsingBlock:^(HLSegmentDownLoader *downloader, NSUInteger idx, BOOL * _Nonnull stop) {
            if (downloader.status == DownloadTaskStatusSuccessed) {
                [tempArray addObject:downloader];
            }
        }];
        // 移除已经完成的
        [self.isDownloadingArray removeObjectsInArray:tempArray];
        
        
        [self.downloadArray enumerateObjectsUsingBlock:^(HLSegmentDownLoader *downloader, NSUInteger idx, BOOL * _Nonnull stop) {
            if (self.isDownloadingArray.count < MAXCount) {
                [self.isDownloadingArray addObject:downloader];
            }
            else {
                *stop = YES;
            }
        }];
        // 移除开始任务的
        [self.downloadArray removeObjectsInArray:self.isDownloadingArray];
        
        [tempArray removeAllObjects];
        [self.isDownloadingArray enumerateObjectsUsingBlock:^(HLSegmentDownLoader *downloader, NSUInteger idx, BOOL * _Nonnull stop) {
            if (downloader.status == DownloadTaskStatusStopped &&  ![downloader start]) {
                [tempArray addObject:downloader];
            }
        }];
        // 移除本地已经下载完的
        [self.isDownloadingArray removeObjectsInArray:tempArray];
        
        if (self.downloadArray.count > 0 && self.isDownloadingArray.count < MAXCount) {
            [self downloadNext:nil];
        }
        
        dispatch_semaphore_signal(self.semaphore);
    });
}


#pragma mark - SegmentHLDownloadDelegate

// 每个下载器下载完成
-(void)segmentDownloadFinished:(HLSegmentDownLoader *)request
{
    [self downloadNext:request];
    
    NSLog(@"a segment Download Finished downloadArray.count %@, self.isDownloadingArray.count %@ self.downloadFailArray.count %@", @(self.downloadArray.count), @(self.isDownloadingArray.count), @(self.downloadFailArray.count));
    

    if(self.downloadArray.count == 0 && self.isDownloadingArray.count == 0)
    {
        if (self.downloadFailArray.count > 0) {
            [self.downloadArray addObjectsFromArray:self.downloadFailArray];
            [self.downloadFailArray removeAllObjects];
            [self downloadNext:nil];
            return;
        }
        
        self.progress = 1;
        self.downloadArray = nil;
        NSLog(@"-----100%%-------all the segments downloaded. video download finished");
        // 总下载字节数有时候有误差
        if (self.delegate && [self.delegate respondsToSelector:@selector(downloader:progress:)])
        {
            [self.delegate downloader:self progress:self.progress];
        }
        self.state = HLDownLoaderState_Finish;
        [[NSNotificationCenter defaultCenter] postNotificationName:HLDownLoaderStateChange object:self];
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(downloaderFinished:)])
        {
            [self.delegate downloaderFinished:self];
        }
        
        self.progress = 0;
        self.writtenSize = 0.0;
    }else {
        
        double progress = (self.playlist.segments.count - self.downloadArray.count)/(float)self.playlist.segments.count;
        self.progress = progress;
        if (self.progress > 1) {
            self.progress = 1.0;
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(downloader:progress:)])
        {
            [self.delegate downloader:self progress:self.progress];
        }
    }
}

// 进度
- (void)segmentDownload:(HLSegmentDownLoader *)request progresser:(HLSegmentProgresser *)progresser
{
    NSLog(@"totalSize %@ , writtenSize %@",@(progresser.totalSize), @(progresser.writtenSize));
    
    
    self.writtenSize += progresser.writtenSize;
    self.totalSize = progresser.totalSize;
    
    double progress = (self.playlist.segments.count - self.downloadArray.count+1)/(float)self.playlist.segments.count;
    self.progress = progress+(progresser.writtenSize/progresser.totalSize)/self.playlist.segments.count;
    if (self.progress > 1) {
        self.progress = 1.0;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(downloader:progress:)])
    {
        [self.delegate downloader:self progress:self.progress];
    }
}


// 下载失败
-(void)segmentDownloadFailed:(HLSegmentDownLoader *)request error:(NSError *)error progresser:(HLSegmentProgresser *)progresser
{
    NSLog(@"segmentDownloadFailed error =%@", error);
    [self.downloadFailArray addObject:request];
    [self downloadNext:request];
    
    if (error.code != NSURLErrorCancelled) { // 取消
        //        [request start];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(downloader:progress:)])
    {
        [self.delegate downloader:self progress:self.progress];
    }
}

#pragma mark -


-(NSString*)createLocalM3U8file
{
    
    if(self.playlist !=nil)
    {
        NSString *pathPrefix = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
        NSString *saveTo = [[pathPrefix stringByAppendingPathComponent:kPathDownload] stringByAppendingPathComponent:self.filePath];
        NSString *fullpath = [saveTo stringByAppendingPathComponent:@"index.m3u8"];
        
        NSLog(@"createLocalM3U8file:%@",fullpath);
        
        //创建文件头部
        NSString* head = @"#EXTM3U\n#EXT-X-TARGETDURATION:30\n#EXT-X-VERSION:2\n#EXT-X-DISCONTINUITY\n";
        
        //        NSString* segmentPrefix = [NSString stringWithFormat:@"http://127.0.0.1:12345/%@/",self.filePath]; // 这是localServer
        NSString* segmentPrefix = @"";
        //填充片段数据
        for(int i = 0;i< self.playlist.length;i++)
        {
            NSString* filename = [NSString stringWithFormat:@"%d.ts",i];
            HLM3U8SegmentInfo* segInfo = [self.playlist getSegment:i];
            NSString* length = [NSString stringWithFormat:@"#EXTINF:%ld,\n",(long)segInfo.duration];
            NSString* url = [segmentPrefix stringByAppendingString:filename];
            head = [NSString stringWithFormat:@"%@%@%@\n",head,length,url];
        }
        //创建尾部
        NSString* end = @"#EXT-X-ENDLIST";
        head = [head stringByAppendingString:end];
        NSMutableData *writer = [[NSMutableData alloc] init];
        [writer appendData:[head dataUsingEncoding:NSUTF8StringEncoding]];
        
        BOOL bSucc =[writer writeToFile:fullpath atomically:YES];
        if(bSucc)
        {
            NSLog(@"create m3u8file succeed; fullpath:%@, content:%@",fullpath,head);
            return  fullpath;
        }
        else
        {
            NSLog(@"create m3u8file failed");
            return  nil;
        }
    }
    return nil;
}

- (NSMutableArray *)downloadArray{
    if (!_downloadArray) {
        _downloadArray = [[NSMutableArray alloc]init];
    }
    return _downloadArray;
}

@end


