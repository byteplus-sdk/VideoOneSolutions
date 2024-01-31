//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveNormalPushStreaming.h"
#import "LiveRTCManager.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LiveNormalPushStreamingNetworkChangeDelegate <NSObject>

- (void)updateOnNetworkStatusChange:(LiveNetworkQualityStatus)status;

@end

@interface LiveNormalPushStreamingImpl : NSObject <LiveNormalPushStreaming>

@property (nonatomic, strong) LiveNormalStreamConfig *streamConfig;
@property (nonatomic, weak) id<LiveNormalPushStreamingNetworkChangeDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
