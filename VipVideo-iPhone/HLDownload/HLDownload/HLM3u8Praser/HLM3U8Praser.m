//
//  HLM3U8Praser.m
//  HLDownloadDemo
//
//  Created by LHL on 18/6/21.
//  Copyright © 2018年 LHL. All rights reserved.
//

#import "HLM3U8Praser.h"
#import "HLM3U8SegmentInfo.h"
#import "HLM3U8List.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation HLM3U8Praser


//解析m3u8的内容
- (void)praseM3u8Url:(NSURL *)url praserBlock:(void (^)(NSURL *m3u8URL ,HLM3U8List *segmentList))block
{
    
    NSLog(@"---begin------");
    
    // 根本就不包含
    if([url.absoluteString containsString:@"m3u8"] == FALSE)
    {
        
        NSLog(@" Invalid url");
        // 告诉代码失败
        if (block) {
            block(url,nil);
        }
        return;
    }
    
    self.m3u8URL = url;
    // 转成url
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *m3u8Str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        if ([m3u8Str hasPrefix:@"#EXTM3U"]) {
            for (NSString *subStr in [m3u8Str componentsSeparatedByString:@"\n"]) {
                if ([subStr hasSuffix:@".m3u8"]) {
                    NSURL *subURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",url.URLByDeletingLastPathComponent,subStr]];
                    [self praseM3u8Url:subURL praserBlock:block];
                    return;
                }
            }
        }
        [self praseM3u8String:m3u8Str urlPath:url.absoluteString.stringByDeletingLastPathComponent praserBlock:block];
    }];
    
    [task resume];
}

- (void)praseM3u8String:(NSString *)m3u8str praserBlock:(void (^)(NSURL *m3u8URL ,HLM3U8List *segmentList))block
{
    [self praseM3u8String:m3u8str urlPath:nil praserBlock:block];
}



- (void)praseM3u8String:(NSString *)m3u8str urlPath:(NSString *)urlPath praserBlock:(void (^)(NSURL *m3u8URL ,HLM3U8List *segmentList))block
{
    if(m3u8str == nil)
    {
        NSLog(@"data is nil");
        if (block) {
            block(self.m3u8URL,nil);
        }
        return;
    }
    
    NSMutableArray *segments = [[NSMutableArray alloc] init];
    NSString* remainData =[m3u8str copy];
    // 找到第一个片段的位置
    NSRange segmentRange = [remainData rangeOfString:@"#EXTINF:"];
    double totalDuration = 0;
    while (segmentRange.location != NSNotFound)
    {
        // 每一个片段
        HLM3U8SegmentInfo * segment = [[HLM3U8SegmentInfo alloc]init];
        
        // 获取片段长度↓↓↓↓↓↓↓↓↓↓↓↓
        /**
         *  #EXTM3U
         #EXT-X-TARGETDURATION:12
         #EXT-X-VERSION:2
         #EXTINF:6,
         */
        NSRange commaRange = [remainData rangeOfString:@","];
        // location #EXTINF:  len ,减去: 得到长度数字
        NSString* value = [remainData substringWithRange:NSMakeRange(segmentRange.location + [@"#EXTINF:" length], commaRange.location -(segmentRange.location + [@"#EXTINF:" length]))];
        segment.duration = [value intValue];
        totalDuration += segment.duration;
        
        // 获取片段url↓↓↓↓↓↓↓↓↓↓↓↓
        /* 剩下的
         ,
         http://202.102.93.173/69760FB8D783A8182AE62365CA/0300080100509EE191556504E9D2A7B927B331-4838-3F56-5086-635F9DC3D5C8.mp4.ts?ts_start=0&ts_end=5.9&ts_seg_no=0&ts_keyframe=1
         #EXTINF:3,.........
         */
        remainData = [remainData substringFromIndex:commaRange.location];
        NSRange linkRangeBegin = [remainData rangeOfString:@"http"];
        if (linkRangeBegin.length == 0) {
            linkRangeBegin.location = 0;
        }
        NSRange linkRangeEnd = [remainData rangeOfString:@"#"];
        // 下载url
        NSString* linkurl = [remainData substringWithRange:NSMakeRange(linkRangeBegin.location, linkRangeEnd.location - linkRangeBegin.location)];
        if (linkRangeBegin.length == 0) {
            linkurl = [linkurl stringByReplacingOccurrencesOfString:@"," withString:@""];
            linkurl = [linkurl stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            linkurl = [NSString stringWithFormat:@"%@/%@",urlPath, linkurl];
        }
        segment.locationUrl = [linkurl stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        [segments addObject:segment];
        // 构成while循环
        remainData = [remainData substringFromIndex:linkRangeEnd.location];
        segmentRange = [remainData rangeOfString:@"#EXTINF:"];
    }
    // 解析完成 一个数组 一个数组长度
    HLM3U8List * thePlaylist = [[HLM3U8List alloc] initWithSegments:segments];
    thePlaylist.totalDuration = totalDuration;
    thePlaylist.filePath = [self md5Hash:self.m3u8URL.absoluteString];
    if (block) {
        block(self.m3u8URL,thePlaylist);
    }
    
}


#pragma mark -

- (NSString*)md5Hash:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5([data bytes], (unsigned int)[data length], result);
    
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
            ];
}


@end
