// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import "ChorusRTCManager.h"
#import "BaseRTCManager.h"

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, ChorusNetworkQualityStatus) {
    ChorusNetworkQualityStatusNone,
    ChorusNetworkQualityStatusGood,
    ChorusNetworkQualityStatusPoor,
    ChorusNetworkQualityStatusBad,
};
typedef NS_ENUM(NSInteger, ChorusStatus) {
    ChorusStatusIdle,
    ChorusStatusPrepare,
    ChorusStatusSinging,
    ChorusStatusSingEnd,
};

@class ChorusRTCManager;
@protocol ChorusRTCManagerDelegate <NSObject>

/**
 * @brief Callback on room state changes. Via this callback you get notified of room relating warnings, errors and events. For example, the user joins the room, the user is removed from the room, and so on.
 * @param manager GameRTCManager model
 * @param userID UserID
 */

- (void)chorusRTCManager:(ChorusRTCManager *)manager
      onRoomStateChanged:(RTCJoinModel *)joinModel;
- (void)chorusRTCManager:(ChorusRTCManager *_Nonnull)chorusRTCManager onStreamSyncInfoReceived:(NSString *)json;
- (void)chorusRTCManager:(ChorusRTCManager *_Nonnull)chorusRTCManager onSingEnded:(BOOL)result;
- (void)chorusRTCManager:(ChorusRTCManager *_Nonnull)chorusRTCManager onAudioMixingPlayingProgress:(NSInteger)progress;
- (void)chorusRTCManager:(ChorusRTCManager *_Nonnull)chorusRTCManager onNetworkQualityStatus:(ChorusNetworkQualityStatus)status userID:(NSString *)userID;
- (void)chorusRTCManager:(ChorusRTCManager *_Nonnull)chorusRTCManager onFirstVideoFrameRenderedWithUserID:(NSString *)userID;
- (void)chorusRTCManager:(ChorusRTCManager *_Nonnull)chorusRTCManager onReportUserAudioVolume:(NSDictionary<NSString *, NSNumber *> *_Nonnull)volumeInfo;
- (void)chorusRTCManagerOnAudioRouteChanged:
    (ChorusRTCManager *_Nonnull)chorusRTCManager;

@end

@interface ChorusRTCManager : BaseRTCManager

@property (nonatomic, weak) id<ChorusRTCManagerDelegate> delegate;
@property(nonatomic, assign, readonly) BOOL canEarMonitor;
@property (nonatomic, assign, readonly) BOOL isCameraOpen;
@property (nonatomic, assign, readonly) BOOL isMicrophoneOpen;

/*
 * RTC Manager Singletons
 */
+ (ChorusRTCManager *_Nullable)shareRtc;

#pragma mark - Base Method
- (void)joinChannelWithToken:(NSString *)token
                      roomID:(NSString *)roomID
                      userID:(NSString *)userID
                      isHost:(BOOL)isHost;

/*
 * Switch local audio capture
 * @param enable ture:Turn on audio capture false：Turn off audio capture
 */
- (void)enableLocalAudio:(BOOL)enable;

- (void)enableLocalVideo:(BOOL)enable;
- (void)switchIdentifyBecomeSinger:(BOOL)isSinger;

/*
 * Leave the room
 */
- (void)leaveChannel;

#pragma mark - Render & audio
- (UIView *)getStreamViewWithUserID:(NSString *)userID;
- (void)bingCanvasViewToUserID:(NSString *)userID;
- (void)updateAudioSubscribeWithChorusStatus:(ChorusStatus)status;
- (void)updateSuccentorAudioMixingWithChorusState:(ChorusStatus)status;

#pragma mark - Singing Music Method

/*
 * Modify the collection volume
 */
- (void)setRecordingVolume:(NSInteger)volume;

/*
 * Modify the background music volume
 */
- (void)setMusicVolume:(NSInteger)volume;


- (void)startAudioMixingWithFilePath:(NSString *)filePath;

- (void)stopSinging;

- (void)setVoiceReverbType:(ByteRTCVoiceReverbType)reverbType;

- (void)sendStreamSyncTime:(NSString *)time;

- (void)switchAccompaniment:(BOOL)isAccompaniment;

- (void)enableEarMonitor:(BOOL)isEnable;

- (void)setEarMonitorVolume:(NSInteger)volume;

@end

NS_ASSUME_NONNULL_END
