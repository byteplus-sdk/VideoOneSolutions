// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, VELSettingCaptureType) {
    VELSettingCaptureTypeInner,
    VELSettingCaptureTypeAudioOnly,
    VELSettingCaptureTypeFile,
    VELSettingCaptureTypeScreen,
};

typedef NS_ENUM(NSInteger, VELSettingResolutionType) {
    VELSettingResolutionType_360,
    VELSettingResolutionType_480,
    VELSettingResolutionType_540,
    VELSettingResolutionType_720,
    VELSettingResolutionType_1080,
    VELSettingResolutionType_Screen = 10,
};

typedef NS_ENUM(NSInteger, VELSettingVideoEncodeType) {
    VELSettingVideoEncodeType_H264,
    VELSettingVideoEncodeType_H265,
};

typedef NS_ENUM(NSInteger, VELSettingVideoProfileType) {
    VELSettingVideoProfileType_Default,
    VELSettingVideoProfileType_BASELINE_30 = 130,
    VELSettingVideoProfileType_BASELINE_31  = 131,
    VELSettingVideoProfileType_BASELINE_32 = 132,
    VELSettingVideoProfileType_BASELINE_AUTO = 159,
    VELSettingVideoProfileType_MAIN_30 = 230,
    VELSettingVideoProfileType_MAIN_31 = 231,
    VELSettingVideoProfileType_MAIN_32 = 232,
    VELSettingVideoProfileType_MAIN_AUTO = 259,
    VELSettingVideoProfileType_HIGH_30 = 330,
    VELSettingVideoProfileType_HIGH_31 = 331,
    VELSettingVideoProfileType_HIGH_32 = 332,
    VELSettingVideoProfileType_HIGH_AUTO = 359,
    VELSettingVideoProfileType_H265_MAIN_AUTO = 901,
    VELSettingVideoProfileType_H265_MAIN_10_AUTO = 902,
};
typedef NS_ENUM(NSInteger, VELSettingPreviewRenderMode) {
    VELSettingPreviewRenderModeHidden = 0,
    VELSettingPreviewRenderModeFit = 1,
    VELSettingPreviewRenderModeFill = 2,
};


@interface VELPushSettingConfig : NSObject <NSCoding, NSCopying, NSMutableCopying>
@property (nonatomic, assign, readonly) BOOL fromLocal;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, assign, getter=isNewApi) BOOL newApi;
@property (nonatomic, copy, readonly) NSString *originUrlString;
@property (nonatomic, copy, readonly) NSArray <NSString *> *urls;
@property (nonatomic, assign) VELSettingCaptureType captureType;
@property (nonatomic, assign) VELSettingResolutionType captureResolutionType;
@property (nonatomic, assign, readonly) CGSize captureSize;
@property (nonatomic, copy, readonly) AVCaptureSessionPreset capturePreset;
@property (nonatomic, assign) NSInteger captureFPS;
@property (nonatomic, assign) VELSettingResolutionType encodeResolutionType;
@property (nonatomic, assign, readonly) CGSize encodeSize;
@property (nonatomic, assign) NSInteger encodeFPS;
@property (nonatomic, assign) BOOL enableFixScreenCaptureVideoAudioDiff;
@property (nonatomic, assign) NSInteger bitrate;
@property (nonatomic, assign) BOOL enableAutoBitrate;
@property (nonatomic, assign) BOOL enableByteAudio;
@property (nonatomic, assign) BOOL enableAudioOnly;
@property (nonatomic, assign) BOOL rtmAutoDegradate;
@property (nonatomic, assign) VELSettingVideoProfileType videoProfile;

/// profile -> str
@property (nonatomic, copy, readonly) NSString *videoProfileStr;
@property (nonatomic, assign) BOOL enableHardwareEarback;
@property (nonatomic, assign) float audioVoiceLoudness;
@property (nonatomic, assign) BOOL enableQuic;
@property (nonatomic, assign) BOOL exposureOptimize;
@property (nonatomic, assign, getter=isValid, readonly) BOOL valid;
@property (nonatomic, assign) BOOL bytePlusRtmHttps;

/// opengl version 2, 3
@property (nonatomic, assign) NSInteger glVersion;
@property (nonatomic, assign) VELSettingPreviewRenderMode renderMode;
- (void)setupUrlsWithString:(NSString *)str;
+ (CGSize)getSizeFromResoultion:(VELSettingResolutionType)resolutionType;
+ (NSArray <NSNumber *> *)getDefaultBitrateFromResoultion:(VELSettingResolutionType)resolutionType;
+ (NSString *)getCapturePresetFromResoultion:(VELSettingResolutionType)resolutionType;
+ (NSString *)getCapturePresetFromSize:(CGSize)size;
- (void)save;
- (void)deleteLocal;
- (BOOL)checkShouldTipBitrateBugFix;
+ (void)deleteLocalWithIdentifier:(NSString *)identifier;
+ (instancetype)loadFromLocalWithIdentifier:(nullable NSString *)identifier;

- (NSString *)shortDescription;
- (BOOL)needRestartVideoCaptureForm:(VELPushSettingConfig *)config;
- (BOOL)needRestartAudioCaptureForm:(VELPushSettingConfig *)config;
- (BOOL)needRestartVideoEncoderForm:(VELPushSettingConfig *)config;
- (BOOL)needRestartEngineFrom:(VELPushSettingConfig *)config;
@end

NS_ASSUME_NONNULL_END
