//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LivePushStreamParams.h"
#import "LiveRTCManager.h"
#import <Foundation/Foundation.h>

@class LiveRTCMixer;

@protocol LiveRTCMixerDelegate <NSObject>

- (LivePushStreamParams *_Nonnull)pushStreamConfigForMixer;
- (void)mixingEvent:(ByteRTCMixedStreamTaskEvent)event taskId:(NSString *_Nullable)taskId error:(ByteRTCMixedStreamTaskErrorCode)Code mixType:(ByteRTCMixedStreamPushTargetType)mixType;

@end

NS_ASSUME_NONNULL_BEGIN

@interface LiveRTCMixer : NSObject

- (instancetype)initWithRTCEngine:(ByteRTCEngine *)rtcEngine;
@property (nonatomic, weak) id<LiveRTCMixerDelegate> delegate;

- (void)startPushMixStreamToCDN;

- (void)updatePushMixedStreamToCDN:(NSArray<LiveUserModel *> *)userList
                         mixStatus:(RTCMixStatus)mixStatus
                         rtcRoomId:(NSString *)rtcRoomId;

- (void)stopPushStreamToCDN;

@end

NS_ASSUME_NONNULL_END
