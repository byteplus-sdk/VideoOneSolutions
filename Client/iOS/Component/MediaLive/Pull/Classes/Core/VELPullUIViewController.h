// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <MediaLive/VELCommon.h>
#import <MediaLive/VELSettings.h>
#import <YYModel/YYModel.h>
#import <MediaLive/VELCore.h>
NS_ASSUME_NONNULL_BEGIN
@interface VELPullUIViewController : VELUIViewController
@property (nonatomic, strong, nullable) TVLManager *playerManager;
@property (nonatomic, strong, readonly) UIView *playerContainer;
@property (nonatomic, strong, readonly) UIView *controlContainer;
@property (nonatomic, copy, readonly) VELPullSettingConfig *config;
@property (nonatomic, strong, readonly) UISlider *volumeSlider;
@property (nonatomic, strong, readonly) NSDateFormatter *dateFormatter;
@property (nonatomic, assign, getter=isShouldPlayInBackground) BOOL shouldPlayInBackground;
@property (nonatomic, assign, getter=isManualPaused) BOOL manualPaused;
@property (atomic, assign, getter=isPreLoading) BOOL preloading;
@property (nonatomic, assign, getter=isAutoHidePlayerView) BOOL autoHidePlayerView;
@property (nonatomic, assign, getter=isAutoPlayWhenLoaded) BOOL autoPlayWhenLoaded;
@property (nonatomic, assign) float currentVolume;
@property (nonatomic, assign) CGSize videoSize;
- (void)resetConfig:(VELPullSettingConfig *)config;
- (instancetype)initWithConfig:(nullable VELPullSettingConfig *)config NS_DESIGNATED_INITIALIZER;

@end
@interface VELPullUIViewController (Basic)
- (void)setupPlayer;
- (void)destroyPlayer;
- (BOOL)isPlaying;
- (void)preload;
- (void)play;
- (void)playWithNetworkReachable;
- (void)pause;
- (void)resume;
- (void)stop;
- (void)startPlayInBackground;
- (void)stopPlayInBackground;
- (BOOL)resolutionShouldChanged:(VELPullResolutionType)fromResolution to:(VELPullResolutionType)toResolution;
- (void)resolutionDidChanged:(VELPullResolutionType)fromResolution to:(VELPullResolutionType)toResolution;
- (NSArray <NSNumber *> *)getCurrentSupportResolutions;
- (VELPullResolutionType)getCurrentResolution;
- (void)refreshCurrentResolution NS_REQUIRES_SUPER;
- (void)openHDR;
- (void)closeHDR;
- (BOOL)isSupportHDR;
- (void)showCallbackNote NS_REQUIRES_SUPER;
- (void)hideCallbackNote NS_REQUIRES_SUPER;
- (void)showCycleInfo NS_REQUIRES_SUPER;
- (void)hideCycleInfo NS_REQUIRES_SUPER;
- (void)showBasicSetting NS_REQUIRES_SUPER;
- (void)hideBasicSetting NS_REQUIRES_SUPER;
- (BOOL)isBasicSettingShowing NS_REQUIRES_SUPER;
- (void)updateCycleInfo:(NSString *)info append:(BOOL)append NS_REQUIRES_SUPER;
- (void)updateCallBackInfo:(NSString *)info append:(BOOL)append NS_REQUIRES_SUPER;
@end
@interface VELPullUIViewController (AV)
- (void)snapshot;
- (void)mute;
- (void)unMute;
- (void)changeVolume:(float)volume;
- (void)showAVSetting NS_REQUIRES_SUPER;
- (void)hideAVSetting NS_REQUIRES_SUPER;
- (BOOL)isAVSettingShowing NS_REQUIRES_SUPER;
- (void)resetAVSettings NS_REQUIRES_SUPER;
@end


typedef NS_ENUM(NSInteger, VELCameraCommand) {
    VELCameraCommandScopicChange = 1000,
    VELCameraCommandRecenter,
    VELCameraCommandZoomIn,
    VELCameraCommandZoomOut,
    VELCameraCommandGyroEnabled,
    VELCameraCommandGyroDisEnabled,
    VELCameraCommandBackStickerEnabled,
};



NS_ASSUME_NONNULL_END
