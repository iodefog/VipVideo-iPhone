//
//  HLM3U8Praser.h
//  HLDownloadDemo
//
//  Created by LHL on 18/6/21.
//  Copyright © 2018年 LHL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLM3U8List.h"

@interface HLM3U8Praser : NSObject

@property (nonatomic, copy) NSURL *m3u8URL;

/**
 *  解析M3u8文件url
 *
 *  @param url M3u8的文件url
 */
-(void)praseM3u8Url:(NSURL *)url praserBlock:(void (^)(NSURL *m3u8URL ,HLM3U8List *segmentList))block;

/**
 *  解析M3u8字符串
 *
 *  @param m3u8str M3u8的文件url
 */
-(void)praseM3u8String:(NSString*)m3u8str praserBlock:(void (^)(NSURL *m3u8URL ,HLM3U8List *segmentList))block;

@end
