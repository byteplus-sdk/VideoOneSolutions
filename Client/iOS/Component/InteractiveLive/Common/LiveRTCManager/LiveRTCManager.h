//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LivePlayerManager.h"
#import "LiveStreamMixingEvent.h"
#import "LiveUserModel.h"
#import <Foundation/Foundation.h>
#import <ToolKit/BaseRTCManager.h>

@class LiveRTCManager, LiveNormalStreamConfig;
NS_ASSUME_NONNULL_BEGIN

static NSString *const LiveSEIKEY = @"liveMode";

typedef NS_ENUM(NSInteger, LiveNetworkQualityStatus) {
    LiveNetworkQualityStatusNone,
    LiveNetworkQualityStatusGood,
    LiveNetworkQualityStatusBad,
};

typedef NS_ENUM(NSUInteger, RTCMixStatus) {
    RTCMixStatusSingleLive = 1,
    RTCMixStatusPK = 2,
    RTCMixStatusAddGuestsTwo = 3,
    RTCMixStatusAddGuestsMulti = 4,
};

@protocol LiveRTCManagerDelegate <NSObject>

/**
 * @brief Callback on room state changes. Via this callback you get notified of room relating warnings, errors and events. For example, the user joins the room, the user is removed from the room, and so on.
 * @param manager GameRTCManager model
 * @param userID UserID
 */

- (void)liveRTCManager:(LiveRTCManager *)manager
    onRoomStateChanged:(RTCJoinModel *)joinModel
                   uid:(NSString *)uid;

- (BOOL)liveRTCManager:(LiveRTCManager *)manager onUserJoined:(NSString *)uid;
- (void)liveRTCManager:(LiveRTCManager *)manager onJoinRoomResult:(NSString *)roomId withUid:(NSString *)uid joinType:(NSInteger)joinType elapsed:(NSInteger)elapsed;
- (void)liveRTCManager:(LiveRTCManager *)manager onUserPublishStream:(NSString *)uid;
- (void)liveRTCManager:(LiveRTCManager *)manager onUserLeave:(NSString *)uid reason:(ByteRTCUserOfflineReason)reason;

@end

@protocol LiveRTCManagerReconnectDelegate <NSObject>

- (void)LiveRTCManagerReconnectDelegate:(LiveRTCManager *)manager
                     onRoomStateChanged:(RTCJoinModel *)joinModel
                                    uid:(NSString *)uid;

@end

@interface LiveRTCManager : BaseRTCManager

@property (nonatomic, weak) id<LiveRTCManagerDelegate> delegate;
@property (nonatomic, weak) id<LiveRTCManagerReconnectDelegate> businessDelegate;

@property (nonatomic, strong) LiveNormalStreamConfig *streamConfig;

+ (LiveRTCManager *_Nullable)shareRtc;

/**
 * @brief join live room. Because audience do not need to join the RTC room when they join the live broadcast room. Audience need to join the live broadcast room first, and then join the RTC room when they become mic guests.
 * @param token RTS Token
 * @param roomID RTS room ID
 * @param userID RTS user ID
 */

- (void)joinLiveRoomByToken:(NSString *)token
                     roomID:(NSString *)roomID
                     userID:(NSString *)userID;

/**
 * @brief Leave live room
 */

- (void)leaveLiveRoom;

/**
 * @brief Join the RTC room. When hosts or guests join a room, they need to join the live room first and then join the RTC room.
 * @param token RTC Token
 * @param rtcRoomID RTC room ID
 * @param userID RTC user ID
 */

- (void)joinRTCRoomByToken:(NSString *)token
                 rtcRoomID:(NSString *)rtcRoomID
                    userID:(NSString *)userID;

/**
 * @brief Leave RTC room
 */

- (void)leaveRTCRoom;

/**
 * @brief start forward stream rooms
 * @param roomId The other party's room ID
 * @param token RTC Token required to join the other party's room
 */

- (void)startForwardStreamToRooms:(NSString *)roomId
                            token:(NSString *)token;

/**
 * @brief Stop retweeting audio and video streams across rooms
 */

- (void)stopForwardStreamToRooms;

#pragma mark - Device Setting

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
 * @brief Get the current video capture switch status
 */

- (BOOL)getCurrentVideoCapture;

/**
 * @brief Front and rear camera switching
 */

- (void)switchCamera;

/**
 * @brief Update the RTC encoding resolution, used by anchors/hosted guests.
 * @param size resolution
 */

- (void)updateVideoEncoderResolution:(CGSize)size;

/**
 * @brief Update the RTC encoding video frame rate in fps, used by anchors/hosted guests.
 * @param frameRate video frame rate in fps
 */

- (void)updateVideoEncoderFrameRate:(NSInteger)frameRate;

#pragma mark - NetworkQuality

/**
 * @brief Listen for network callbacks
 */

- (void)didChangeNetworkQuality:(void (^)(LiveNetworkQualityStatus status,
                                          NSString *uid))block;

#pragma mark - RTC Render View

/**
 * @brief Get RTC rendering UIView
 * @param uid User id
 */

- (nullable UIView *)getStreamViewWithUid:(NSString *)uid;

/**
 * @brief user ID and RTC rendering View for binding
 * @param uid User id
 */

- (nullable UIView *)bindCanvasViewToUid:(NSString *)uid;

/**
 * @brief remove all  rendering UIView
 */
- (void)cleanAllStreamViews;

@end

NS_ASSUME_NONNULL_END
