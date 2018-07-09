//
//  HLDownloaderCenter.h
//  HLDownload
//
//  Created by LHL on 2018/6/22.
//  Copyright © 2018 HL. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HLDownLoader;


#define HLDownLoaderTaskMAX 2

@interface HLDownloaderCenter : NSObject

@property(nonatomic, strong) NSMutableArray *downloadsArray;

+ (instancetype)shareInstanced;

- (void)addDownloadWithM3u8URL:(NSURL *)url completeBlock:(void (^)(HLDownLoader *downloader))completeBlock;


- (void)startAll;
- (void)pauseAll;
- (void)resumeAll;
- (void)cancelAll;

- (void)startItemIndex:(NSUInteger)index;
- (void)pauseItemIndex:(NSUInteger)index;
- (void)resumeItemIndex:(NSUInteger)index;
- (void)cancelItemIndex:(NSUInteger)index;


- (void)removeItem:(HLDownLoader *)downloader;
- (void)removeItemIndex:(NSUInteger)index;

@end
