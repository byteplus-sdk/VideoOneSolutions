// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPullUrlConfig.h"
#import <MediaLive/VELCommon.h>
#import "VELSettingConfigDefine.h"
#import <ToolKit/Localizator.h>

@interface VELPullUrlConfig ()
@property (nonatomic, copy, nullable, readwrite) NSString *ipHostUrl;
@property (nonatomic, copy, nullable, readwrite) NSArray <VELPullABRUrlConfig *> *abrUrlConfigs;
@property (nonatomic, copy) NSMutableArray <VELPullABRUrlConfig *> *abrUrlConfigsM;
@property (nonatomic, copy, nullable, readwrite) NSArray <VELPullUrlConfig *> *mutableFmtConfigs;
@end
@implementation VELPullUrlConfig
@synthesize format = _format;
@synthesize protocol = _protocol;
+ (nullable NSArray<NSString *> *)modelPropertyBlacklist {
    return @[@"abrUrlConfigsM"];
}
- (instancetype)init {
    if (self = [super init]) {
        _bitrate = -1;
        _resolution = VELPullResolutionTypeOrigin;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    VEL_ENCODE_INTEGER_PROPERTY(bitrate);
    VEL_ENCODE_OBJ_PROPERTY(url);
    VEL_ENCODE_OBJ_PROPERTY(abrUrlConfigsM);
    VEL_ENCODE_INTEGER_PROPERTY(urlType);
    VEL_ENCODE_INTEGER_PROPERTY(resolution);
    VEL_ENCODE_INTEGER_PROPERTY(enableABR);
    VEL_ENCODE_INTEGER_PROPERTY(enableQuic);
    VEL_ENCODE_INTEGER_PROPERTY(protocol);
    VEL_ENCODE_INTEGER_PROPERTY(format);
}

- (nullable instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [self init]) {
        VEL_DECODE_INTEGER_PROPERTY(bitrate);
        VEL_DECODE_OBJ_PROPERTY(url);
        VEL_DECODE_OBJ_PROPERTY(abrUrlConfigsM);
        VEL_DECODE_INTEGER_PROPERTY(urlType);
        VEL_DECODE_INTEGER_PROPERTY_DEFAULT(resolution, VELPullResolutionTypeOrigin);
        VEL_DECODE_INTEGER_PROPERTY(enableABR);
        VEL_DECODE_INTEGER_PROPERTY(enableQuic);
        VEL_DECODE_INTEGER_PROPERTY(protocol);
        VEL_DECODE_INTEGER_PROPERTY(format);
    }
    return self;
}

- (id)copy {
    return self;
}

- (id)mutableCopy {
    @try {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    } @catch (NSException *exception) {
        return self;
    }
}

+ (instancetype)configWithUrl:(NSString *)url type:(VELPullUrlType)type {
    VELPullUrlConfig *cfg = [[self alloc] init];
    cfg.url = url;
    cfg.urlType = type;
    return cfg;
}

- (void)setUrl:(NSString *)url {
    _url = [url.copy vel_trim];
    _mutableFmtConfigs = nil;
    _format = VELPullUrlFormatUnKnown;
    _protocol = VELPullUrlProtocolUnKnown;
}

- (NSArray<VELPullUrlConfig *> *)mutableFmtConfigs {
    if (![self.url containsString:@"\n"] || self.enableABR) {
        return nil;
    }
    if (!_mutableFmtConfigs) {
        NSArray <NSString *>* components = [self.url componentsSeparatedByString:@"\n"];
        NSMutableArray <VELPullUrlConfig *>* configs = [NSMutableArray arrayWithCapacity:components.count];
        [components enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *url = [obj vel_validURLString];
            if (!VEL_IS_EMPTY_STRING(url)) {
                VELPullUrlConfig *cfg = [self mutableCopy];
                cfg.url = url;
                if ([cfg isValid]) {
                    [configs addObject:cfg];
                }
            }
        }];
        _mutableFmtConfigs = configs.copy;
    }
    return _mutableFmtConfigs;
}

- (NSArray<VELPullABRUrlConfig *> *)abrUrlConfigs {
    return self.abrUrlConfigsM.copy;
}

- (NSMutableArray<VELPullABRUrlConfig *> *)abrUrlConfigsM {
    if (!_abrUrlConfigsM) {
        _abrUrlConfigsM = [NSMutableArray arrayWithCapacity:10];
    }
    if (![_abrUrlConfigsM isKindOfClass:NSMutableArray.class]) {
        _abrUrlConfigsM = [NSMutableArray arrayWithArray:_abrUrlConfigs?:@[]];
    }
    return _abrUrlConfigsM;
}

- (BOOL)isABRConfig {
    return NO;
}

- (BOOL)isValid {
    __block BOOL valid = YES;
    if (self.enableABR) {
        valid &= (self.abrUrlConfigsM.count > 0);
        NSInteger originBitrate = [self getOriginABRConfig].bitrate;
        [self.abrUrlConfigsM enumerateObjectsUsingBlock:^(VELPullABRUrlConfig * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            valid &= obj.isValid;
            valid &= (originBitrate >= obj.bitrate);
            if (!valid) {
                *stop = YES;
            }
        }];
        valid &= (self.getDefaultABRConfig != nil && self.getOriginABRConfig != nil);
    } else {
        valid &= (self.mutableFmtConfigs.count > 0 || VEL_IS_NOT_EMPTY_STRING(self.url.vel_validURLString));
    }
    return valid;
}

- (NSString *)ipHostUrl {
    if (_ipHostUrl == nil) {
        return self.url;
    }
    return _ipHostUrl;
}

- (void)replaceHostIPWith:(NSDictionary<NSString *,NSString *> *)ipHostMap {
    if (!self.isValid) {
        return;
    }
    if (self.mutableFmtConfigs.count > 0) {
        [self.mutableFmtConfigs enumerateObjectsUsingBlock:^(VELPullUrlConfig * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj replaceHostIPWith:ipHostMap];
        }];
        return;
    }
    NSURLComponents *components = [NSURLComponents componentsWithString:self.url];
    NSString *host = components.host;
    if (VEL_IS_EMPTY_STRING(host) || ![ipHostMap.allValues containsObject:host]) {
        return;
    }
    [ipHostMap enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:host]) {
            components.host = key;
            *stop = YES;
        }
    }];
    self.ipHostUrl = components.string;
}


- (NSInteger)bitrate {
    if (_bitrate <= 0) {
        return -1;
    }
    return _bitrate;
}

- (NSString *)resolutionDes {
    switch (self.resolution) {
        case VELPullResolutionTypeOrigin: return @"Origin";
        case VELPullResolutionTypeUHD: return @"UHD";
        case VELPullResolutionTypeHD: return @"HD";
        case VELPullResolutionTypeLD: return @"LD";
        case VELPullResolutionTypeSD: return @"SD";
    }
    return @"";
}

- (NSInteger)port {
    return [self getUrlComponent].port.integerValue;
}

- (NSString *)formatStr {
    NSString *path = [self getUrlComponent].path;
    NSString *format = path.pathExtension.lowercaseString;
    return format;
}
- (void)setFormat:(VELPullUrlFormat)format {
    _format = format;
}
- (VELPullUrlFormat)format {
    if (_format == VELPullUrlFormatUnKnown) {
        NSString *format = self.formatStr;
        if ([format isEqualToString:@"sdp"]) {
            _format = VELPullUrlFormatRTM;
        } else if ([format isEqualToString:@"m3u8"]) {
            _format = VELPullUrlFormatHLS;
        } else if ([format isEqualToString:@"flv"]) {
            _format = VELPullUrlFormatFLV;
        }
    }
    return _format;
}
- (void)setProtocol:(VELPullUrlProtocol)protocol {
    _protocol = protocol;
}
- (VELPullUrlProtocol)protocol {
    if (_protocol == VELPullUrlProtocolUnKnown) {
        if (self.enableQuic && self.isSupportQuic) {
            _protocol = VELPullUrlProtocolQuic;
        } else if ([self.url hasPrefix:@"http://"] || [self.url hasPrefix:@"rtmp://"]) {
            _protocol = VELPullUrlProtocolTCP;
        } else if ([self.url hasPrefix:@"https://"] || [self.url hasPrefix:@"rtmps://"]) {
            _protocol = VELPullUrlProtocolTLS;
        }
    }
    return _protocol;
}

- (NSString *)rtmBackupFLV {
    NSURLComponents *comp = [self getUrlComponent];
    comp.scheme = @"http";
    comp.port = nil;
    comp.path = [comp.path stringByReplacingOccurrencesOfString:@".sdp" withString:@".flv"];
    return [comp string];
}

- (NSString *)urlNoPort {
    NSURLComponents *comp = [self getUrlComponent];
    comp.port = nil;
    return [comp string];
}

- (BOOL)isSupportQuic {
    if (VEL_IS_EMPTY_STRING(self.url)) {
        return NO;
    }
    NSURLComponents *compoents = [self getUrlComponent];
    return compoents && [compoents.scheme hasPrefix:@"http"] && [compoents.path hasSuffix:@".flv"];
}

- (BOOL)isSupportRTM {
    if (VEL_IS_EMPTY_STRING(self.url)) {
        return NO;
    }
    NSURLComponents *compoents = [self getUrlComponent];
    return compoents && [compoents.path hasSuffix:@".sdp"];
}

- (BOOL)isSupportRTMByChild {
    __block BOOL support = NO;
    if (self.mutableFmtConfigs.count > 0) {
        [self.mutableFmtConfigs enumerateObjectsUsingBlock:^(VELPullUrlConfig * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.isSupportRTM) {
                support = YES;
                *stop = YES;
            }
        }];
    } else {
        support = [self isSupportRTM];
    }
    return support;
}

- (NSURLComponents *)getUrlComponent {
    if (VEL_IS_EMPTY_STRING(self.ipHostUrl)) {
        return nil;
    }
    return [NSURLComponents componentsWithString:self.ipHostUrl?:@""];
}

- (void)addABRConfig:(VELPullABRUrlConfig *)urlConfig {
    if (urlConfig == nil) {
        return;
    }
    if ([self.abrUrlConfigsM containsObject:urlConfig]) {
        [self refreshABRConfig:urlConfig];
        return;
    }
    urlConfig.urlType = self.urlType;
    if (urlConfig.isDefault) {
        [self.abrUrlConfigsM enumerateObjectsUsingBlock:^(VELPullABRUrlConfig * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj != urlConfig) {
                obj.isDefault = NO;
            }
        }];
    }
    [self.abrUrlConfigsM addObject:urlConfig];
}

- (void)refreshABRConfig:(VELPullABRUrlConfig *)urlConfig {
    if ( urlConfig == nil || ![self.abrUrlConfigsM containsObject:urlConfig]) {
        return;
    }
    urlConfig.urlType = self.urlType;
    
    if (urlConfig.isDefault) {
        [self.abrUrlConfigsM enumerateObjectsUsingBlock:^(VELPullABRUrlConfig * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj != urlConfig) {
                obj.isDefault = NO;
            }
        }];
    }
}

- (void)removeABRConfig:(VELPullABRUrlConfig *)urlConfig {
    if (urlConfig == nil) {
        return;
    }
    [self.abrUrlConfigsM removeObject:urlConfig];
}

- (void)clearABRConfig {
    [self.abrUrlConfigsM removeAllObjects];
}

- (NSArray <NSNumber *> *)suggestedABRResolutions {
    if (!self.enableABR) {
        return @[@(VELPullResolutionTypeOrigin)];
    }
    NSMutableArray *allResolutions = @[@(VELPullResolutionTypeOrigin),
                                       @(VELPullResolutionTypeUHD),
                                       @(VELPullResolutionTypeHD),
                                       @(VELPullResolutionTypeLD),
                                       @(VELPullResolutionTypeSD)].mutableCopy;
    [allResolutions removeObjectsInArray:self.getSupportResolutions];
    return allResolutions;
}

- (NSArray <NSNumber *> *)getSupportResolutions {
    if (!self.enableABR) {
        return @[@(VELPullResolutionTypeOrigin)];
    }
    NSMutableArray *resolutions = [NSMutableArray arrayWithCapacity:10];
    [self.abrUrlConfigs enumerateObjectsUsingBlock:^(VELPullABRUrlConfig * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [resolutions addObject:@(obj.resolution)];
    }];
    return resolutions;
}

- (BOOL)canAddABRConfig {
    return self.enableABR && self.abrUrlConfigsM.count < 5;
}

- (VELPullABRUrlConfig *)getDefaultABRConfig {
    __block VELPullABRUrlConfig *cfg = nil;
    [self.abrUrlConfigs enumerateObjectsUsingBlock:^(VELPullABRUrlConfig * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isDefault) {
            cfg = obj;
            *stop = YES;
        }
    }];
    return cfg;
}

- (VELPullABRUrlConfig *)getOriginABRConfig {
    __block VELPullABRUrlConfig *cfg = nil;
    [self.abrUrlConfigs enumerateObjectsUsingBlock:^(VELPullABRUrlConfig * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.resolution == VELPullResolutionTypeOrigin) {
            cfg = obj;
            *stop = YES;
        }
    }];
    return cfg;
}

- (NSArray <VELPullUrlConfig *> *)getAllActiveUrlConfigs {
    NSMutableArray <VELPullUrlConfig *>*configs = [NSMutableArray arrayWithCapacity:10];
    [configs addObject:self];
    if (self.enableABR) {
        [configs addObjectsFromArray:self.abrUrlConfigsM];
    }
    return configs;
}

- (NSString *)shortDescription {
    return [NSString stringWithFormat:@"%@", self.url];
}

@end
@implementation VELPullABRUrlConfig
- (instancetype)init {
    if (self = [super init]) {
        _gopSec = 2;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    VEL_ENCODE_BOOL_PROPERTY(isDefault);
    VEL_ENCODE_INTEGER_PROPERTY(gopSec);
}

- (nullable instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        VEL_DECODE_BOOL_PROPERTY(isDefault);
        VEL_DECODE_INTEGER_PROPERTY_DEFAULT(gopSec, 2);
    }
    return self;
}

+ (instancetype)configWithUrl:(NSString *)url type:(VELPullUrlType)type {
    VELPullABRUrlConfig *cfg = [super configWithUrl:url type:type];
    if (type == VELPullUrlTypeMain) {
        cfg.isDefault = YES;
    }
    return cfg;
}

- (NSString *)shortDescription {
    if (self.gopSec < 0) {
        return [NSString stringWithFormat:@"%@: %@ %d kbps;", self.resolutionDes, LocalizedStringFromBundle(@"medialive_bitrate", @"MediaLive"),(int)self.bitrate];
    }
    return [NSString stringWithFormat:@"%@: %@ %d kbps; GOP %d s", self.resolutionDes, LocalizedStringFromBundle(@"medialive_bitrate", @"MediaLive"),(int)self.bitrate, (int)self.gopSec];
}

- (BOOL)isValid {
    if (self.gopSec < 0) {
        return VEL_IS_NOT_EMPTY_STRING(self.url) && self.bitrate > 0;
    }
    return VEL_IS_NOT_EMPTY_STRING(self.url) && self.gopSec > 0 && self.bitrate > 0;
}

- (BOOL)isABRConfig {
    return NO;
}
@end
