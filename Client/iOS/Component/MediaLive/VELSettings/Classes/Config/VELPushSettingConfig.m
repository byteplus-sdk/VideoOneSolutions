// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPushSettingConfig.h"
#import "VELSettingConfigDefine.h"
#import <MediaLive/VELCommon.h>
#import <YYModel/YYModel.h>
@interface VELPushSettingConfig ()
@property (nonatomic, copy, readwrite) NSArray <NSString *> *urls;
@property (nonatomic, copy, readwrite) NSString *originUrlString;
@property (nonatomic, assign, readwrite) BOOL fromLocal;
@end
@implementation VELPushSettingConfig
- (instancetype)init {
    if (self = [super init]) {
        _captureResolutionType = VELSettingResolutionType_720;
        _encodeFPS = 15;
        _captureFPS = 15;
        _encodeResolutionType = VELSettingResolutionType_720;
        _bitrate = 1200;
        _identifier = @"default";
        _videoProfile = VELSettingVideoProfileType_Default;
        _glVersion = 3;
        _renderMode = VELSettingPreviewRenderModeHidden;
        [self setupUrlsWithString:@""];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    VEL_ENCODE_BOOL_PROPERTY(newApi);
    VEL_ENCODE_OBJ_PROPERTY(date);
    VEL_ENCODE_OBJ_PROPERTY(originUrlString);
    VEL_ENCODE_OBJ_PROPERTY(identifier);
    VEL_ENCODE_INTEGER_PROPERTY(captureType);
    VEL_ENCODE_INTEGER_PROPERTY(captureResolutionType);
    VEL_ENCODE_INTEGER_PROPERTY(captureFPS);
    VEL_ENCODE_INTEGER_PROPERTY(encodeResolutionType);
    VEL_ENCODE_INTEGER_PROPERTY(encodeFPS);
    VEL_ENCODE_INTEGER_PROPERTY(bitrate);
    VEL_ENCODE_BOOL_PROPERTY(enableAutoBitrate);
    VEL_ENCODE_BOOL_PROPERTY(enableByteAudio);
    VEL_ENCODE_BOOL_PROPERTY(enableAudioOnly);
    VEL_ENCODE_BOOL_PROPERTY(rtmAutoDegradate);
    VEL_ENCODE_INTEGER_PROPERTY(videoProfile);
    VEL_ENCODE_BOOL_PROPERTY(enableHardwareEarback);
    VEL_ENCODE_BOOL_PROPERTY(enableQuic);
    VEL_ENCODE_BOOL_PROPERTY(exposureOptimize);
    VEL_ENCODE_BOOL_PROPERTY(bytePlusRtmHttps);
    VEL_ENCODE_INTEGER_PROPERTY(glVersion);
    VEL_ENCODE_INTEGER_PROPERTY(renderMode);
}

- (nullable instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [self init]) {
        VEL_DECODE_BOOL_PROPERTY_DEFAULT(newApi, YES);
        VEL_DECODE_OBJ_PROPERTY(date);
        VEL_DECODE_OBJ_PROPERTY(originUrlString);
        VEL_DECODE_OBJ_PROPERTY(identifier);
        VEL_DECODE_INTEGER_PROPERTY_DEFAULT(captureType, VELSettingCaptureTypeInner);
        VEL_DECODE_INTEGER_PROPERTY_DEFAULT(captureResolutionType, VELSettingResolutionType_720);
        VEL_DECODE_INTEGER_PROPERTY_DEFAULT_MIN(captureFPS, 30, 15);
        VEL_DECODE_INTEGER_PROPERTY_DEFAULT(encodeResolutionType, VELSettingResolutionType_720);
        VEL_DECODE_INTEGER_PROPERTY_DEFAULT_MIN(encodeFPS, 30, 15);
        VEL_DECODE_INTEGER_PROPERTY_DEFAULT(bitrate, 1200);
        VEL_DECODE_BOOL_PROPERTY(enableAutoBitrate);
        VEL_DECODE_BOOL_PROPERTY_DEFAULT(enableByteAudio, YES);
        VEL_DECODE_BOOL_PROPERTY(enableAudioOnly);
        VEL_DECODE_BOOL_PROPERTY(rtmAutoDegradate);
        VEL_DECODE_INTEGER_PROPERTY_DEFAULT(videoProfile, VELSettingVideoProfileType_Default);
        VEL_DECODE_BOOL_PROPERTY(enableHardwareEarback);
        VEL_DECODE_BOOL_PROPERTY(enableQuic);
        VEL_DECODE_BOOL_PROPERTY(exposureOptimize);
        VEL_DECODE_BOOL_PROPERTY(bytePlusRtmHttps);
        VEL_DECODE_INTEGER_PROPERTY_DEFAULT(glVersion, 3);
        VEL_DECODE_INTEGER_PROPERTY_DEFAULT(renderMode, VELSettingPreviewRenderModeHidden);
        [self setupUrlsWithString:self.originUrlString];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)copy {
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return [self mutableCopy];
}

- (id)mutableCopy {
    @try {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    } @catch (NSException *exception) {
        return self;
    }
}

- (void)setEncodeResolutionType:(VELSettingResolutionType)encodeResolutionType {
    _encodeResolutionType = encodeResolutionType;
}

- (CGSize)captureSize {
    return [[self class] getSizeFromResoultion:self.captureResolutionType];
}

- (AVCaptureSessionPreset)capturePreset {
    return [[self class] getCapturePresetFromResoultion:self.captureResolutionType];
}
- (CGSize)encodeSize {
    return [[self class] getSizeFromResoultion:self.encodeResolutionType];
}


- (void)setRtmAutoDegradate:(BOOL)rtmAutoDegradate {
    _rtmAutoDegradate = rtmAutoDegradate;
    [self setupUrlsWithString:self.originUrlString];
}

- (void)setupUrlsWithString:(NSString *)str {
    if (VEL_IS_EMPTY_STRING(str)) {
        str = [NSUserDefaults.standardUserDefaults stringForKey:@"VEL_COMMON_DEFAULT_PUSH_URL"];
    } else {
        [NSUserDefaults.standardUserDefaults setObject:str forKey:@"VEL_COMMON_DEFAULT_PUSH_URL"];
    }
    
    if (str == nil) {
        self.urls = @[];
        return;
    }
    self.originUrlString = str;
    NSMutableArray *urls = [NSMutableArray arrayWithCapacity:3];
    if ([str containsString:@"\n"]) {
        [[str componentsSeparatedByString:@"\n"] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj vel_validPushURLString] != nil) {
                [urls addObject:obj.vel_validPushURLString];
            }
        }];
    } else {
        NSString *urlStr = str.vel_validPushURLString;
        if (urlStr != nil) {
            [urls addObject:urlStr];
            if (self.rtmAutoDegradate && urlStr) {
                NSURLComponents *components = [NSURLComponents componentsWithString:urlStr];
                if ([components.path hasSuffix:@".sdp"]) {
                    components.scheme = @"rtmp";
                    components.path = [components.path stringByReplacingOccurrencesOfString:@".sdp" withString:@""];
                    [urls addObject:components.URL.absoluteString];
                }
            }
        }
    }
    self.urls = urls;
}

+ (CGSize)getSizeFromResoultion:(VELSettingResolutionType)resolutionType {
    switch (resolutionType) {
        case VELSettingResolutionType_360: return CGSizeMake(360, 640);
        case VELSettingResolutionType_480: return CGSizeMake(480, 860);
        case VELSettingResolutionType_540: return CGSizeMake(540, 960);
        case VELSettingResolutionType_720: return CGSizeMake(720, 1280);
        case VELSettingResolutionType_1080: return CGSizeMake(1080, 1920);
        default: return CGSizeMake(720, 1280);
    }
    return CGSizeMake(720, 1280);
}

+ (NSString *)getCapturePresetFromResoultion:(VELSettingResolutionType)resolutionType {
    return [self getCapturePresetFromSize:[self getSizeFromResoultion:resolutionType]];
}

+ (NSString *)getCapturePresetFromSize:(CGSize)size {
    NSInteger maxValue = MAX(size.width, size.height);
    if (maxValue <= 640) {
        return AVCaptureSessionPreset640x480;
    } else if (maxValue <= 960) {
        return AVCaptureSessionPresetiFrame960x540;
    } else if (maxValue <= 1280) {
        return AVCaptureSessionPreset1280x720;
    }
    return AVCaptureSessionPreset1920x1080;
}

- (BOOL)checkShouldTipBitrateBugFix {
    if (VEL_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"16.4")
        && VEL_SYSTEM_VERSION_LESS_THAN(@"16.5")) {
        if (self.enableAutoBitrate) {
            self.enableAutoBitrate = NO;
            return YES;
        }
    }
    return NO;
}

- (NSString *)videoProfileStr {
    switch (self.videoProfile) {
        case VELSettingVideoProfileType_Default : return @"Default";
        case VELSettingVideoProfileType_BASELINE_30 : return @"BASELINE_30";
        case VELSettingVideoProfileType_BASELINE_31 : return @"BASELINE_31";
        case VELSettingVideoProfileType_BASELINE_32 : return @"BASELINE_32";
        case VELSettingVideoProfileType_BASELINE_AUTO : return @"BASELINE_AUTO";
        case VELSettingVideoProfileType_MAIN_30 : return @"MAIN_30";
        case VELSettingVideoProfileType_MAIN_31 : return @"MAIN_31";
        case VELSettingVideoProfileType_MAIN_32 : return @"MAIN_32";
        case VELSettingVideoProfileType_MAIN_AUTO : return @"MAIN_AUTO";
        case VELSettingVideoProfileType_HIGH_30 : return @"HIGH_30";
        case VELSettingVideoProfileType_HIGH_31 : return @"HIGH_31";
        case VELSettingVideoProfileType_HIGH_32 : return @"HIGH_32";
        case VELSettingVideoProfileType_HIGH_AUTO : return @"HIGH_AUTO";
        case VELSettingVideoProfileType_H265_MAIN_AUTO : return @"H265_MAIN_AUTO";
        case VELSettingVideoProfileType_H265_MAIN_10_AUTO : return @"H265_MAIN_10_AUTO";
    }
    return @"Default";
}

+ (NSArray<NSNumber *> *)getDefaultBitrateFromResoultion:(VELSettingResolutionType)resolutionType {
    switch (resolutionType) {
        case VELSettingResolutionType_360: return @[@500, @250, @800];
        case VELSettingResolutionType_480: return @[@800, @320, @1266];
        case VELSettingResolutionType_540: return @[@1000, @500, @1520];
        case VELSettingResolutionType_720: return @[@1200, @800, @1900];
        case VELSettingResolutionType_1080: return @[@2500, @1000, @3800];
        case VELSettingResolutionType_Screen: return @[@2500, @1000, @3800];
    }
    return @[@1200, @800, @1900];
}

+ (NSString *)getSavedKeyWithIdentifier:(NSString *)identifier {
    return [NSString stringWithFormat:@"vel_push_config_%@", identifier ?: @"default"];
}

- (NSString *)getSavedKey {
    return [self.class getSavedKeyWithIdentifier:self.identifier];
}
- (void)save {
    NSData *pushConfigData = [NSKeyedArchiver archivedDataWithRootObject:self];
    [NSUserDefaults.standardUserDefaults setObject:pushConfigData
                                            forKey:[self getSavedKey]];
}
- (void)deleteLocal {
    [NSUserDefaults.standardUserDefaults setObject:nil forKey:[self getSavedKey]];
}

+ (void)deleteLocalWithIdentifier:(NSString *)identifier {
    [NSUserDefaults.standardUserDefaults setObject:nil forKey:[self getSavedKeyWithIdentifier:identifier]];
}
+ (instancetype)loadFromLocalWithIdentifier:(nullable NSString *)identifier {
    NSData *pushConfigData = [NSUserDefaults.standardUserDefaults objectForKey:[self getSavedKeyWithIdentifier:identifier]];
    VELPushSettingConfig *config = nil;
    if (pushConfigData != nil) {
        @try {
            config = [NSKeyedUnarchiver unarchiveObjectWithData:pushConfigData];
            config.fromLocal = YES;
        } @catch (NSException *exception) {
        } @finally {}
        
    }
    if (config == nil) {
        config = [[self alloc] init];
        config.fromLocal = NO;
    }
    config.identifier = identifier;
    return config;
}

- (NSString *)shortDescription {
    return [NSString stringWithFormat:@"%@", self.originUrlString];
}

- (BOOL)needRestartVideoCaptureForm:(VELPushSettingConfig *)config {
    return (self.captureFPS != config.captureFPS
            || !CGSizeEqualToSize(self.captureSize, config.captureSize)
            || ![self.capturePreset isEqualToString:config.capturePreset]
            || self.captureResolutionType != config.captureResolutionType);
}

- (BOOL)needRestartAudioCaptureForm:(VELPushSettingConfig *)config {
    return NO;
}

- (BOOL)needRestartVideoEncoderForm:(VELPushSettingConfig *)config {
    return (self.videoProfile != config.videoProfile
            || self.encodeFPS != config.encodeFPS
            || !CGSizeEqualToSize(self.encodeSize, config.encodeSize)
            || self.encodeResolutionType != config.encodeResolutionType);
}

- (BOOL)needRestartEngineFrom:(VELPushSettingConfig *)config {
    return ([self needRestartVideoCaptureForm:config]
            || [self needRestartAudioCaptureForm:config]
            || [self needRestartVideoEncoderForm:config]);
}

- (BOOL)isValid {
    return VEL_IS_NOT_EMPTY_STRING(self.originUrlString) && self.urls.count > 0;
}

- (NSDictionary *)toJson {
    return [self yy_modelToJSONObject];
}

- (BOOL)isEqual:(VELPushSettingConfig *)object {
    if (![object isKindOfClass:VELPushSettingConfig.class]) {
        return NO;
    }
    return [[self toJson] isEqualToDictionary:[object toJson]];
}

+ (nullable NSArray<NSString *> *)modelPropertyBlacklist {
    return @[@"identifier", @"date", @"urls", @"valid"];
}
@end
