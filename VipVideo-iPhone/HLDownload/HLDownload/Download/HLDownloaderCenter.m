//
//  HLDownloaderCenter.m
//  HLDownload
//
//  Created by LHL on 2018/6/22.
//  Copyright © 2018 HL. All rights reserved.
//

#import "HLDownloaderCenter.h"
#import "HLDownLoader.h"
#import "HLM3U8Praser.h"

@interface HLDownloaderCenter()

@property(nonatomic, strong) dispatch_queue_t m3u8RequestQueue;
@property(nonatomic, strong) NSMutableArray  *queueArray;

@end

@implementation HLDownloaderCenter

static id manager = nil;
+ (instancetype)shareInstanced{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager == nil) {
            manager = [[[self class] alloc] init];
        }
    });
    return manager;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init{
    if (self = [super init]) {
        self.m3u8RequestQueue = dispatch_queue_create("com.lhl.m3u8RequestQueue", NULL);
        self.downloadsArray = [NSMutableArray array];
        self.queueArray = [NSMutableArray array];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downLoaderStateChange:) name:HLDownLoaderStateChange object:nil];
    }
    return self;
}

- (void)addDownloadWithM3u8URL:(NSURL *)url completeBlock:(void (^)(HLDownLoader *downloader))completeBlock
{
    dispatch_async(self.m3u8RequestQueue, ^{
        HLM3U8Praser *m3u8Praser = [[HLM3U8Praser alloc] init];
        [m3u8Praser praseM3u8Url:url praserBlock:^(NSURL *m3u8URL ,HLM3U8List *segmentList) {
            HLDownLoader *downloader = [[HLDownLoader alloc] initWithHLM3U8List:segmentList];
            downloader.m3u8url = m3u8URL;
            [self.downloadsArray addObject:downloader];
            
            if (completeBlock) {
                completeBlock(downloader);
            }

            if (self.queueArray.count < HLDownLoaderTaskMAX) {
                [self.queueArray addObject:downloader];
                [downloader startDownload];
            }
            
        }];
    });
}

- (void)startAll{
    [self.downloadsArray enumerateObjectsUsingBlock:^(HLDownLoader *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.state != HLDownLoaderState_Finish) {
            [obj startDownload];
        }
    }];
}

- (void)pauseAll{
    [self.downloadsArray enumerateObjectsUsingBlock:^(HLDownLoader *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.state != HLDownLoaderState_Downloading) {
            [obj suspendDownload];
        }
    }];
}

- (void)resumeAll{
    [self.downloadsArray enumerateObjectsUsingBlock:^(HLDownLoader *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.state != HLDownLoaderState_Pause) {
            [obj resumeDownload];
        }
    }];
}

- (void)cancelAll{
    [self.downloadsArray enumerateObjectsUsingBlock:^(HLDownLoader *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.state != HLDownLoaderState_Finish && obj.state != HLDownLoaderState_Cancel) {
            [obj cancelDownload];
        }
    }];
}

- (void)startItemIndex:(NSUInteger)index{
    if (index < self.downloadsArray.count) {
        HLDownLoader *downloader = self.downloadsArray[index];
        if (downloader.state != HLDownLoaderState_Finish) {
            [downloader startDownload];
        }
    }
}

- (void)pauseItemIndex:(NSUInteger)index{
    if (index < self.downloadsArray.count) {
        HLDownLoader *downloader = self.downloadsArray[index];
        if (downloader.state != HLDownLoaderState_Finish) {
            [downloader startDownload];
        }
    }
}

- (void)resumeItemIndex:(NSUInteger)index{
    if (index < self.downloadsArray.count) {
        HLDownLoader *downloader = self.downloadsArray[index];
        if (downloader.state == HLDownLoaderState_Pause) {
            [downloader startDownload];
        }
    }
}

- (void)cancelItemIndex:(NSUInteger)index{
    if (index < self.downloadsArray.count) {
        HLDownLoader *downloader = self.downloadsArray[index];
        if (downloader.state != HLDownLoaderState_Finish) {
            [downloader startDownload];
        }
    }
}

- (void)removeItem:(HLDownLoader *)downloader{
    if (downloader) {
        if (downloader.state == HLDownLoaderState_Downloading) {
            [downloader cancelDownload];
        }
        [self.downloadsArray removeObject:downloader];
    }
}

- (void)removeItemIndex:(NSUInteger)index{
    if (index < self.downloadsArray.count) {
        [self removeItem:self.downloadsArray[index]];
    }
}

- (void)downLoaderStateChange:(NSNotification *)notificaiton{
    if ([notificaiton.object isKindOfClass:[HLDownLoader class]]) {
        HLDownLoader *item = notificaiton.object;
        if (item.state == HLDownLoaderState_Finish) {
            [self.queueArray removeObject:item];
        }
        for (HLDownLoader *downloader in self.downloadsArray) {
            if (self.queueArray.count < HLDownLoaderTaskMAX && downloader.state == HLDownLoaderState_Wait) {
                [downloader startDownload];
                [self.queueArray addObject:downloader];
            }else {
                break;
            }
        }
    }
}


@end
