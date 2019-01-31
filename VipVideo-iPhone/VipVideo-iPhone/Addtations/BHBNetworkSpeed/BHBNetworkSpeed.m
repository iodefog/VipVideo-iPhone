//
//  BHBNetworkSpeed.m
//  BHBNetworkSpeedDemo
//
//  Created by bihongbo on 15/11/19.
//  Copyright © 2015年 bihongbo. All rights reserved.
//

#import "BHBNetworkSpeed.h"
#include <arpa/inet.h>
#include <net/if.h>
#include <ifaddrs.h>
#include <net/if_dl.h>

/**
 *  @{@"received":@"100kB/s"}
 */
NSString *const kNetworkReceivedSpeedNotification = @"kNetworkReceivedSpeedNotification";

/**
 *  @{@"send":@"100kB/s"}
 */
NSString *const kNetworkSendSpeedNotification = @"kNetworkSendSpeedNotification";

@interface BHBNetworkSpeed ()
{
    uint32_t _iBytes;
    uint32_t _oBytes;
    uint32_t _allFlow;
    uint32_t _wifiIBytes;
    uint32_t _wifiOBytes;
    uint32_t _wifiFlow;
    uint32_t _wwanIBytes;
    uint32_t _wwanOBytes;
    uint32_t _wwanFlow;
}

@property (nonatomic, copy) NSString * receivedNetworkSpeed;

@property (nonatomic, copy) NSString * sendNetworkSpeed;

@property (nonatomic, strong) NSTimer * timer;

@end

@implementation BHBNetworkSpeed

static BHBNetworkSpeed * instance = nil;

+ (instancetype)shareNetworkSpeed{
    if(instance == nil){
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init] ;
    }) ;
    }
    return instance;
    
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    
    if(instance == nil){
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [super allocWithZone:zone];
        
    });
    }
    return instance;
}

-(instancetype)init{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super init];
        _iBytes = _oBytes = _allFlow = _wifiIBytes = _wifiOBytes = _wifiFlow = _wwanIBytes = _wwanOBytes = _wwanFlow = 0;
    });
    return instance;
    
}

- (void)startMonitoringNetworkSpeed{
    if(_timer)
        [self stopMonitoringNetworkSpeed];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(netSpeedNotification) userInfo:nil repeats:YES];
}

- (void)stopMonitoringNetworkSpeed{
    if ([_timer isValid]) {
        [_timer invalidate];
    }
}

- (void)netSpeedNotification{
    [self checkNetworkflow];
}

-(NSString *)bytesToAvaiUnit:(int)bytes
{
    if(bytes < 1024)     // B
    {
        return [NSString stringWithFormat:@"%dB", bytes];
    }
    else if(bytes >= 1024 && bytes < 1024 * 1024) // KB
    {
        return [NSString stringWithFormat:@"%.1fKB", (double)bytes / 1024];
    }
    else if(bytes >= 1024 * 1024 && bytes < 1024 * 1024 * 1024)   // MB
    {
        return [NSString stringWithFormat:@"%.1fMB", (double)bytes / (1024 * 1024)];
    }
    else    // GB
    {
        return [NSString stringWithFormat:@"%.1fGB", (double)bytes / (1024 * 1024 * 1024)];
    }
}


-(void)checkNetworkflow
{
    struct ifaddrs *ifa_list = 0, *ifa;
    if (getifaddrs(&ifa_list) == -1)
    {
        return ;
    }
    
    uint32_t iBytes     = 0;
    uint32_t oBytes     = 0;
    uint32_t allFlow    = 0;
    uint32_t wifiIBytes = 0;
    uint32_t wifiOBytes = 0;
    uint32_t wifiFlow   = 0;
    uint32_t wwanIBytes = 0;
    uint32_t wwanOBytes = 0;
    uint32_t wwanFlow   = 0;
//    struct timeval32 time;
    
    for (ifa = ifa_list; ifa; ifa = ifa->ifa_next)
    {
        if (AF_LINK != ifa->ifa_addr->sa_family)
            continue;
        
        if (!(ifa->ifa_flags & IFF_UP) && !(ifa->ifa_flags & IFF_RUNNING))
            continue;
        
        if (ifa->ifa_data == 0)
            continue;
        
        // network flow
        if (strncmp(ifa->ifa_name, "lo", 2))
        {
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;
            
            iBytes += if_data->ifi_ibytes;
            oBytes += if_data->ifi_obytes;
            allFlow = iBytes + oBytes;
//            time = if_data->ifi_lastchange;
        }
        
        //wifi flow
        if (!strcmp(ifa->ifa_name, "en0"))
        {
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;
            
            wifiIBytes += if_data->ifi_ibytes;
            wifiOBytes += if_data->ifi_obytes;
            wifiFlow    = wifiIBytes + wifiOBytes;
        }
        
        //3G and gprs flow
        if (!strcmp(ifa->ifa_name, "pdp_ip0"))
        {
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;
            
            wwanIBytes += if_data->ifi_ibytes;
            wwanOBytes += if_data->ifi_obytes;
            wwanFlow    = wwanIBytes + wwanOBytes;
        }
    }
    freeifaddrs(ifa_list);
    

    if (_iBytes != 0) {
        self.receivedNetworkSpeed = [[self bytesToAvaiUnit:iBytes - _iBytes] stringByAppendingString:@"/s"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNetworkReceivedSpeedNotification object:@{@"received":self.receivedNetworkSpeed}];
    }
    
    _iBytes = iBytes;
    
    if (_oBytes != 0) {
        self.sendNetworkSpeed = [[self bytesToAvaiUnit:oBytes - _oBytes] stringByAppendingString:@"/s"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNetworkSendSpeedNotification object:@{@"send":self.sendNetworkSpeed}];
    }
    _oBytes = oBytes;
    
    //
//    NSLog(@"sentBytes==%@",sentBytes);
//    NSString *networkFlow      = [self bytesToAvaiUnit:allFlow];
//    //
//    NSLog(@"networkFlow==%@",networkFlow);
//    //
//    NSString *wifiReceived   = [self bytesToAvaiUnit:wifiIBytes];
//    
//    NSLog(@"wifiReceived==%@",wifiReceived);
//    
//    NSString *wifiSent       = [self bytesToAvaiUnit: wifiOBytes];
//    
//    NSLog(@"wifiSent==%@",wifiSent);
//    
//    NSString *wifiBytes      = [self bytesToAvaiUnit:wifiFlow];
//    //
//    NSLog(@"wifiBytes==%@",wifiBytes);
//    NSString *wwanReceived   = [self bytesToAvaiUnit:wwanIBytes];
//    
//    NSLog(@"wwanReceived==%@",wwanReceived);
//    NSString *wwanSent       = [self bytesToAvaiUnit:wwanOBytes];
//    
//    NSLog(@"wwanSent==%@",wwanSent);
//    NSString *wwanBytes      = [self bytesToAvaiUnit:wwanFlow];
//    //
//    NSLog(@"wwanBytes==%@",wwanBytes);
}
@end

