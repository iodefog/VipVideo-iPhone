//
//  BHBNetworkSpeed.h
//  BHBNetworkSpeedDemo
//
//  Created by bihongbo on 15/11/19.
//  Copyright © 2015年 bihongbo. All rights reserved.
//



#import <Foundation/Foundation.h>


@interface BHBNetworkSpeed : NSObject

@property (nonatomic, copy, readonly) NSString * receivedNetworkSpeed;

@property (nonatomic, copy, readonly) NSString * sendNetworkSpeed;

+ (instancetype)shareNetworkSpeed;

- (void)startMonitoringNetworkSpeed;

- (void)stopMonitoringNetworkSpeed;

@end



/**
 *  @{@"received":@"100kB/s"}
 */
FOUNDATION_EXTERN NSString *const kNetworkReceivedSpeedNotification;

/**
 *  @{@"send":@"100kB/s"}
 */
FOUNDATION_EXTERN NSString *const kNetworkSendSpeedNotification;

