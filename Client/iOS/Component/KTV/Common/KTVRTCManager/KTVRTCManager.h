#import <ToolKit/BaseRTCManager.h>
#import "KTVRTCManager.h"
#import "KTVRoomParamInfoModel.h"
#import "KTVSongModel.h"
#import "KTVDownloadSongModel.h"

NS_ASSUME_NONNULL_BEGIN
@class KTVRTCManager;
@protocol KTVRTCManagerDelegate <NSObject>

- (void)KTVRTCManager:(KTVRTCManager *)KTVRTCManager
    onRoomStateChanged:(RTCJoinModel *)joinModel
                   uid:(NSString *)uid;

- (void)KTVRTCManager:(KTVRTCManager *)KTVRTCManager changeParamInfo:(KTVRoomParamInfoModel *)model;

- (void)KTVRTCManager:(KTVRTCManager *_Nonnull)KTVRTCManager reportAllAudioVolume:(NSDictionary<NSString *, NSNumber *> *_Nonnull)volumeInfo;

- (void)KTVRTCManager:(KTVRTCManager *_Nonnull)KTVRTCManager onStreamSyncInfoReceived:(NSDictionary *)infoDic;

- (void)KTVRTCManager:(KTVRTCManager *_Nonnull)KTVRTCManager songEnds:(BOOL)result;

- (void)KTVRTCManager:(KTVRTCManager *_Nonnull)KTVRTCManager onAudioMixingPlayingProgress:(NSInteger)progress;

/// 用户音频播放路由改变回调
/// @param KTVRTCManager RTC manager
- (void)KTVRTCManagerOnAudioRouteChanged:(KTVRTCManager *_Nonnull)KTVRTCManager;

@end

@interface KTVRTCManager : BaseRTCManager

@property (nonatomic, weak) id<KTVRTCManagerDelegate> delegate;

/// 是否可以开启耳返
@property(nonatomic, assign, readonly) BOOL canEarMonitor;

/*
 * RTC Manager Singletons
 */
+ (KTVRTCManager *_Nullable)shareRtc;

#pragma mark - Base Method

/**
 * Join room
 * @param token token
 * @param roomID roomID
 * @param uid uid
 */
- (void)joinChannelWithToken:(NSString *)token roomID:(NSString *)roomID uid:(NSString *)uid;

/*
 * Switch local audio capture
 * @param enable ture:Turn on audio capture false：Turn off audio capture
 */
- (void)enableLocalAudio:(BOOL)enable;

/*
 * Switch local audio capture
 * @param mute ture:Turn on audio capture false：Turn off audio capture
 */
- (void)muteLocalAudio:(BOOL)mute;

/*
 * Leave the room
 */
- (void)leaveChannel;

#pragma mark - Singing Music Method

/*
 * Modify the collection volume
 */
- (void)setRecordingVolume:(NSInteger)volume;

/*
 * Modify the background music volume
 */
- (void)setMusicVolume:(NSInteger)volume;

/*
 * Start singing
 */
- (void)startStartSinging:(NSString *)filePath;

/*
 * Pause singing
 */
- (void)pauseSinging;

/*
 * Resume singing
 */
- (void)resumeSinging;

/*
 * Stop singing
 */
- (void)stopSinging;

/*
 * Reset mix state
 */
- (void)resetAudioMixingStatus;

/*
 * Set audio reverb effects
 */
- (void)setVoiceReverbType:(ByteRTCVoiceReverbType)reverbType;

/*
 * Send audio sync timestamp
 */
- (void)sendStreamSyncTime:(NSDictionary *)infoDic;

/*
 * Original vocal/accompaniment switch
 */
- (void)switchAccompaniment:(BOOL)isAccompaniment;

/*
 * On/off ear monitor
 */
- (void)enableEarMonitor:(BOOL)isEnable;

/*
 * Set ear monitor volume
 */
- (void)setEarMonitorVolume:(NSInteger)volume;



@end

NS_ASSUME_NONNULL_END
