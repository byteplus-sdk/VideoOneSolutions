//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveInteractivePushStreaming.h"
#import "LiveNormalPushStreaming.h"
#import "LiveNormalStreamConfig.h"
#import "LivePushStreamParams.h"
#import "LiveRTCManager.h"
#import <Foundation/Foundation.h>

@class LiveRoomInfoModel, LiveRtcLinkSession;

NS_ASSUME_NONNULL_BEGIN

@protocol LiveRtcLinkSessionNetworkChangeDelegate <NSObject>

- (void)updateOnNetworkStatusChange:(LiveNetworkQualityStatus)status;

@end

@interface LiveRtcLinkSession : NSObject

@property (nonatomic, strong) LiveNormalStreamConfig *streamConfig;
@property (nonatomic, weak) id<LiveInteractiveDelegate> interactiveDelegate;

@property (nonatomic, strong, readonly) NSArray<LiveUserModel *> *userList;

@property (nonatomic, weak) id<LiveRtcLinkSessionNetworkChangeDelegate> netwrokDelegate;

@property (nonatomic, strong, readonly) id<LiveNormalPushStreaming> normalPushStreaming;

- (instancetype)initWithRoom:(LiveRoomInfoModel *)roomModel;

#pragma mark - Live Broadcast
/**
 * @brief start single live streaming without pushing rtc.
 */

- (void)startNormalStreaming;

/**
 * @brief stop single live streaming.
 */

- (void)stopNormalStreaming;

/**
 * @brief start interactive with others, including anchors or guests. Users will joinChannel and push data.
 */

- (void)startInteractive:(LiveInteractivePlayMode)playMode;

/**
 * @brief stop interactive with others. The anchor will leaveRoom and start normal stream. Guests will dealloc this session and start pulling stream.
 */

- (void)stopInteractive;

/**
 * @brief Whether the anchor is interacting with others.
 */

- (BOOL)isInteracting;

/**
 * @brief room Users changed,  the anchor need to update sei.
 * @param current users, from server.
 */

- (void)onUserListChanged:(NSArray<LiveUserModel *> *)userList;

/**
 * @brief switch interactive mode
 * @param play mode like: single anchor, pk, guests(two or more).
 */

- (void)switchPlayMode:(LiveInteractivePlayMode)playMode;

/**
 * @brief Enable span the room retweet stream
 * @param roomId: for rtcRoomId, token: rtcToken.
 */

- (void)startForwardStreamToRooms:(NSString *)rtcRoomId token:(NSString *)rtcToken;

/**
 * @brief Start/Stop local video capture
 * @param isStart ture: enable video capture false: disable video capture
 */

- (void)switchVideoCapture:(BOOL)isStart;

/**
 * @brief Start/Stop local audio capture
 * @param isStart ture: enable audio capture false: disable audio capture
 */

- (void)switchAudioCapture:(BOOL)isStart;

/**
 * @brief update push stream resolution, including normal stream and rtc transcoding stream.
 * @param resolution: 540p/720p/1080p.
 */

- (void)updatePushStreamResolution:(CGSize)resolution;

/**
 * @brief Update the NormalPushing/RTC encoding resolution, used by anchors/hosted or guests.
 * @param resolution resolution
 */

- (void)updateVideoEncoderResolution:(CGSize)resolution;

@end

NS_ASSUME_NONNULL_END
