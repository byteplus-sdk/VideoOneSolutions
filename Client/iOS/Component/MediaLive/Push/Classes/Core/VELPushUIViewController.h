// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELUIViewController.h"
#import <MediaLive/VELCore.h>
#import <MediaLive/VELCommon.h>
#import <MediaLive/VELSettings.h>
#import <YYModel/YYModel.h>
#import <ToolKit/BytedEffectProtocol.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, VELNetworkQuality) {
    VELNetworkQualityUnKnown = -1,
    VELNetworkQualityBad,
    VELNetworkQualityPoor,
    VELNetworkQualityGood
};

typedef NS_ENUM(NSInteger, VELStreamStatus) {
    VELStreamStatusNone,
    VELStreamStatusConnecting,
    VELStreamStatusConnected,
    VELStreamStatusReconnecting,
    VELStreamStatusStop,
    VELStreamStatusEnded,
    VELStreamStatusError
};
@interface VELPushUIViewController : VELUIViewController
@property (nonatomic, strong) BytedEffectProtocol *beautyComponent;
@property (nonatomic, copy) VELPushSettingConfig *config;
@property (nonatomic, strong, readonly) UIView *previewContainer;
@property (nonatomic, strong, readonly) UIView *controlContainerView;
@property (nonatomic, assign, readonly) VELStreamStatus streamStatus;
@property (nonatomic, assign) BOOL isStartEngineAndPreview;
@property (nonatomic, assign) CGSize captureSize;
@property (nonatomic, assign) CGSize outputSize;
@property (nonatomic, strong) UIVisualEffectView *rotateVisualView;
@property(nonatomic, copy) void (^streamStatusChangedBlock)(VELStreamStatus status, BOOL isStreaming);
@property (nonatomic, copy) NSString *downloadBaseUrl;
- (instancetype)initWithConfig:(nullable VELPushSettingConfig *)config NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCaptureType:(VELSettingCaptureType)captureType NS_DESIGNATED_INITIALIZER;
- (void)startEngineAndPreview NS_REQUIRES_SUPER;
- (void)stopEngineAndPreview NS_REQUIRES_SUPER;
- (void)destoryAllAdditionMemoryObjects NS_REQUIRES_SUPER;
- (BOOL)checkConfigIsValid;
@end
@interface VELPushUIViewController (Basic)
@property (nonatomic, strong, readonly) VELNetworkQualityView *netQualityView;
- (void)setupEngine;
- (void)destoryEngine;
- (void)startVideoCapture;
- (void)stopVideoCapture;
- (void)startAudioCapture;
- (void)stopAudioCapture;
- (void)startPreivew;
- (void)startStreaming;
- (BOOL)isStreaming;
- (void)stopStreaming;
- (void)switchCamera;
- (void)muteAudio;
- (void)unMuteAudio;
- (void)setStreamMirror:(BOOL)mirror;
- (void)setPreviewMirror:(BOOL)mirror;
- (void)setCaptureMirror:(BOOL)mirror;
- (BOOL)isSupportTorch;
- (void)torch:(BOOL)isOn;
- (void)rotatedTo:(UIInterfaceOrientation)orientation;
- (void)reconfigCapture;
- (void)reconfigStream;
- (void)setEnableAudioHardwareEcho:(BOOL)enable;
- (BOOL)isSupportAudioHardwareEcho;
- (BOOL)isHardwareEchoEnable;
- (void)setAudioLoudness:(float)loudness;
- (void)setPreviewRenderMode:(VELSettingPreviewRenderMode)renderMode;
- (float)getCurrentAudioLoudness;
- (void)updateVideoEncodeResolution:(VELSettingResolutionType)resolution;
- (void)updateVideoEncodeFps:(int)fps;
- (NSAttributedString *)getPushInfoString;
- (void)restartEngine NS_REQUIRES_SUPER;
- (void)setNetworkQuality:(VELNetworkQuality)networkQuality NS_REQUIRES_SUPER;
- (void)setStreamStatus:(VELStreamStatus)streamStatus msg:(nullable NSString *)msg NS_REQUIRES_SUPER;
@end

@interface VELPushUIViewController (Info)
- (void)showCallbackNote NS_REQUIRES_SUPER;
- (void)hideCallbackNote NS_REQUIRES_SUPER;
- (void)showCycleInfo NS_REQUIRES_SUPER;
- (void)hideCycleInfo NS_REQUIRES_SUPER;
- (void)showInfoView NS_REQUIRES_SUPER;
- (void)hideInfoView NS_REQUIRES_SUPER;
- (BOOL)isInfoViewShowing NS_REQUIRES_SUPER;
- (void)updateCycleInfo:(NSString *)info append:(BOOL)append NS_REQUIRES_SUPER;
- (void)updateCallBackInfo:(NSString *)info append:(BOOL)append NS_REQUIRES_SUPER;
@end
@interface VELPushUIViewController (SEI)
- (void)sendSEIWithKey:(NSString *)key value:(NSString *)value;
- (void)stopSendSEIForKey:(NSString *)key;
@end

@interface VELPushUIViewController (Effect)
- (BOOL)isSupportEffect;
- (void)showEffect;
- (void)setupEffectManager;

@end

typedef void (^VELRecordStartBlock)(NSError *_Nullable error);
typedef void (^VELRecordStopBlock)(NSString *_Nullable videoPath, NSError *_Nullable error);
typedef void (^VELSnapshotBlock)(UIImage *_Nullable image, NSError *_Nullable error);
@interface VELPushUIViewController (Record)
- (void)startRecord:(int)width height:(int)height;
- (void)stopRecord;
- (void)snapShot;
- (void)setSnapShotResult:(nullable UIImage *)image error:(nullable NSError *)error NS_REQUIRES_SUPER;
- (void)setRecordStartResultError:(nullable NSError *)error NS_REQUIRES_SUPER;
- (void)setRecordResult:(nullable NSString *)videoPath error:(nullable NSError *)error NS_REQUIRES_SUPER;
@end
@interface VELPushUIViewController (Exposure)
- (CGFloat)getSupportedMaxExposure;
- (CGFloat)getSupportedMinExposure;
- (CGFloat)getCurrentExposure;
- (BOOL)isSupportExposure;
- (void)setExposure:(CGFloat)exposure;
@end
@interface VELPushUIViewController (WhiteBalance)
- (CGFloat)getSupportedMaxWhiteBalance;
- (CGFloat)getSupportedMinWhiteBalance;
- (CGFloat)getCurrentWhiteBalance;
- (BOOL)isSupportWhiteBalance;
- (void)setWhiteBalance:(CGFloat)whiteBalance;
@end
@interface VELPushUIViewController (Ratio)
- (CGFloat)getCurrentCameraZoomRatio;
- (CGFloat)getCameraZoomMaxRatio;
- (CGFloat)getCameraZoomMinRatio;
- (void)setCameraZoomRatio:(CGFloat)ratio;
- (BOOL)isSupportCameraZoomRatio;
@end
@interface VELPushUIViewController (Focus)
- (BOOL)isAutoFocusSupported;
- (void)enableCameraAutoFocus:(BOOL)enable;
- (void)setCameraFocusPosition:(CGPoint)position;
@end
@interface VELPushUIViewController (Gesture)
- (void)onTouchEvent:(VELTouchEvent)event x:(CGFloat)x y:(CGFloat)y force:(CGFloat)force majorRadius:(CGFloat)majorRadius pointerId:(NSInteger)pointerId pointerCount:(NSInteger)pointerCount;
/// @param dx dx
/// @param dy dy
- (void)onGesture:(VELGestureType)gesture x:(CGFloat)x y:(CGFloat)y dx:(CGFloat)dx dy:(CGFloat)dy factor:(CGFloat)factor;
@end

NS_ASSUME_NONNULL_END
