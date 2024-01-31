//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#ifndef LiveInteractivePushStreaming_h
#define LiveInteractivePushStreaming_h

typedef NS_ENUM(NSUInteger, LiveInteractivePlayMode) {
    // Single user
    LiveInteractivePlayModeNormal = 0,
    // two anchor pk.
    LiveInteractivePlayModePK = 1,
    // anchor and guests.
    LiveInteractivePlayModeMultiGuests = 2
};

@protocol LiveInteractiveDelegate <NSObject>

- (void)liveInteractiveOnUserPublishStream:(NSString *_Nullable)uid;

@end

@protocol LiveInteractivePushStreaming <NSObject>

/**
 * @brief start interactive with others, including anchors or guests. Users will joinChannel and push data.
 */

- (void)startInteractive;

/**
 * @brief stop interactive with others. The anchor will leaveRoom and start normal stream. Guests will dealloc this session and start pulling stream.
 */

- (void)stopInteractive;

/**
 * @brief room Users changed,  the anchor need to update sei.
 * @param current users, from server.
 */

- (void)onUserListChanged:(NSArray<LiveUserModel *> *_Nullable)userList;

/**
 * @brief switch play mode.
 * @param playMode: Single Live host, pk, multi-guests.
 */

- (void)switchPlayMode:(LiveInteractivePlayMode)playMode;

/**
 * @brief Enable span the room retweet stream
 * @param roomId for rtcRoomId
 * @param token for rtcToken.
 */


- (void)startForwardStreamToRooms:(NSString *_Nonnull)roomId token:(NSString *_Nonnull)token;

- (BOOL)isInteracting;

/**
 * @brief update push stream resolution, including normal stream and rtc transcoding stream.
 * @param resolution: 540p/720p/1080p.
 */

- (void)updatePushStreamResolution:(CGSize)resolution;

/**
 * @brief Update the RTC encoding resolution, used by anchors/hosted or guests.
 * @param resolution resolution
 */

- (void)updateVideoEncoderResolution:(CGSize)resolution;

@end

#endif /* LiveInteractivePushStreaming_h */
