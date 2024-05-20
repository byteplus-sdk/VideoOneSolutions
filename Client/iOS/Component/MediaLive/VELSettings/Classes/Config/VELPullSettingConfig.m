// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPullSettingConfig.h"
#import <MediaLive/VELCommon.h>
#import <MediaLive/VELCore.h>
#import "VELDnsHelper.h"
#import "VELSettingConfigDefine.h"
#import <ToolKit/Localizator.h>

@interface VELPullSettingConfig ()
@property (nonatomic, strong, readwrite) VELPullUrlConfig *mainUrlConfig;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation VELPullSettingConfig
@synthesize suggestProtocol = _suggestProtocol;
@synthesize suggestFormat = _suggestFormat;
+ (nullable NSArray<NSString *> *)modelPropertyBlacklist {
    return @[@"dateFormatter"];
}

- (instancetype)init {
    if (self = [super init]) {
        _newApi = YES;
        _identifier = @"default";
        _urlType = VELPullUrlTypeMain;
        _ignoreOpenglActivity = YES;
        _enableAutoResolutionDegrade = YES;
        _rtmAutoDowngrade = NO;
        _feedAutoScrollInternal = 2000;
        _enableCacheblePlayer = YES;
        _feedPreload = YES;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    VEL_ENCODE_BOOL_PROPERTY(newApi);
    VEL_ENCODE_OBJ_PROPERTY(date);
    VEL_ENCODE_OBJ_PROPERTY(identifier);
    VEL_ENCODE_INTEGER_PROPERTY(urlType);
    VEL_ENCODE_OBJ_PROPERTY(mainUrlConfig);
    VEL_ENCODE_BOOL_PROPERTY(enableAutoResolutionDegrade);
    VEL_ENCODE_INTEGER_PROPERTY(rtmAutoDowngrade);
    VEL_ENCODE_BOOL_PROPERTY(enableSEI);
    VEL_ENCODE_BOOL_PROPERTY(shouldReportAudioFrame);
    VEL_ENCODE_BOOL_PROPERTY(ignoreOpenglActivity);
    VEL_ENCODE_BOOL_PROPERTY(enableCacheblePlayer);
    VEL_ENCODE_BOOL_PROPERTY(enableSinglePlayer);
    VEL_ENCODE_BOOL_PROPERTY(feedAutoScroll);
    VEL_ENCODE_BOOL_PROPERTY(feedPreload);
    VEL_ENCODE_INTEGER_PROPERTY(feedAutoScrollInternal);
    VEL_ENCODE_INTEGER_PROPERTY(suggestFormat);
    VEL_ENCODE_INTEGER_PROPERTY(suggestProtocol);
}

- (nullable instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [self init]) {
        VEL_DECODE_BOOL_PROPERTY_DEFAULT(newApi, YES);
        VEL_DECODE_OBJ_PROPERTY(identifier);
        VEL_DECODE_INTEGER_PROPERTY_DEFAULT(urlType, VELPullUrlTypeMain);
        VEL_DECODE_OBJ_PROPERTY(date);
        VEL_DECODE_OBJ_PROPERTY(mainUrlConfig);
        VEL_DECODE_BOOL_PROPERTY_DEFAULT(enableAutoResolutionDegrade, YES);
        VEL_DECODE_BOOL_PROPERTY(rtmAutoDowngrade);
        VEL_DECODE_BOOL_PROPERTY(enableSEI);
        VEL_DECODE_BOOL_PROPERTY(shouldReportAudioFrame);
        VEL_DECODE_BOOL_PROPERTY_DEFAULT(ignoreOpenglActivity, YES);
        VEL_DECODE_BOOL_PROPERTY_DEFAULT(enableCacheblePlayer, YES);
        VEL_DECODE_BOOL_PROPERTY(enableSinglePlayer);
        VEL_DECODE_BOOL_PROPERTY(feedAutoScroll);
        VEL_DECODE_BOOL_PROPERTY_DEFAULT(feedPreload, YES);
        VEL_DECODE_INTEGER_PROPERTY_DEFAULT(feedAutoScrollInternal, 2000);
        VEL_DECODE_INTEGER_PROPERTY_DEFAULT(suggestFormat, VELPullUrlFormatFLV);
        VEL_DECODE_INTEGER_PROPERTY_DEFAULT(suggestProtocol, VELPullUrlProtocolTCP);
        if (self.isNewApi) {
            [self.mainUrlConfig.abrUrlConfigs enumerateObjectsUsingBlock:^(VELPullABRUrlConfig * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                obj.gopSec = -1;
            }];
        }
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return [self copy];
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
+ (instancetype)loadFromLocalWithIdentifier:(nullable NSString *)identifier {
    NSData *pullConfigData = [NSUserDefaults.standardUserDefaults objectForKey:[self getSavedKeyWithIdentifier:identifier]];
    VELPullSettingConfig *config = nil;
    if (pullConfigData != nil) {
        @try {
            config = [NSKeyedUnarchiver unarchiveObjectWithData:pullConfigData];
            config.fromLocal = YES;
        } @catch (NSException *exception) {
        }
    }
    if (config == nil) {
        config = [[self alloc] init];
        config.fromLocal = NO;
    }
    config.identifier = identifier;
    return config;
}

+ (instancetype)defaultConfigWithUrlString:(NSString *)url {
    VELPullSettingConfig *cfg = [[self alloc] init];
    cfg.mainUrlConfig.url = url.vel_validURLString;
    return cfg;
}
- (VELPullUrlConfig *)urlConfig {
    return self.mainUrlConfig;
}

- (VELPullUrlConfig *)mainUrlConfig {
    if (!_mainUrlConfig) {
        _mainUrlConfig = [VELPullUrlConfig configWithUrl:nil type:(VELPullUrlTypeMain)];
    }
    _mainUrlConfig.urlType = VELPullUrlTypeMain;
    return _mainUrlConfig;
}

- (void)setSuggestFormat:(VELPullUrlFormat)suggestFormat {
    _suggestFormat = suggestFormat;
    if (!self.enableABR && self.urlConfig.mutableFmtConfigs.count <= 1) {
        self.urlConfig.format = suggestFormat;
    }
}

- (VELPullUrlFormat)suggestFormat {
    if (_suggestFormat == VELPullUrlFormatUnKnown) {
        _suggestFormat = self.urlConfig.format;
    }
    if (_suggestFormat == VELPullUrlFormatUnKnown) {
        return VELPullUrlFormatFLV;
    }
    return _suggestFormat;
}

- (VELPullUrlProtocol)suggestProtocol {
    if (_suggestProtocol == VELPullUrlProtocolUnKnown) {
        _suggestProtocol = self.urlConfig.protocol;
    }
    if (_suggestProtocol == VELPullUrlProtocolUnKnown) {
        return VELPullUrlProtocolTCP;
    }
    return _suggestProtocol;
}

- (void)setSuggestProtocol:(VELPullUrlProtocol)suggestProtocol {
    _suggestProtocol = suggestProtocol;
    [self setEnableQuic:(suggestProtocol == VELPullUrlProtocolQuic)];
    if (!self.enableABR && self.urlConfig.mutableFmtConfigs.count <= 1) {
        self.urlConfig.protocol = suggestProtocol;
    }
}

- (void)setEnableABR:(BOOL)enableABR {
    self.urlConfig.enableABR = enableABR;
}

- (BOOL)enableABR {
    return self.urlConfig.enableABR;
}

- (void)addABRConfig:(VELPullABRUrlConfig *)urlConfig {
    [self.urlConfig addABRConfig:urlConfig];
    [self save];
}

- (void)refreshABRConfig:(VELPullABRUrlConfig *)urlConfig {
    [self.urlConfig refreshABRConfig:urlConfig];
    [self save];
}

- (void)removeABRConfig:(VELPullABRUrlConfig *)urlConfig {
    [self.urlConfig removeABRConfig:urlConfig];
    [self save];
}

- (void)clearABRConfig {
    [self.urlConfig clearABRConfig];
    [self save];
}
- (void)setEnableQuic:(BOOL)enableQuic {
    self.mainUrlConfig.enableQuic = enableQuic;
}

- (BOOL)enableQuic {
    return self.urlConfig.enableQuic;
}

- (NSArray <VELPullUrlConfig *> *)getAllActiveUrlConfigs {
    NSMutableArray <VELPullUrlConfig *>*configs = [NSMutableArray arrayWithCapacity:10];
    [configs addObjectsFromArray:[self.mainUrlConfig getAllActiveUrlConfigs]];
    return configs;
}

- (BOOL)checkShouldOpentQuic {
    __block BOOL supportQuic = YES;
    [[self getAllActiveUrlConfigs] enumerateObjectsUsingBlock:^(VELPullUrlConfig * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isSupportQuic]) {
            supportQuic = NO;
            *stop = YES;
        }
    }];
    return supportQuic && self.suggestFormat == VELPullUrlFormatFLV;
}

- (BOOL)isValid {
    BOOL valid = self.mainUrlConfig.isValid;
    return valid;
}
- (void)save {
    NSData *pushConfigData = [NSKeyedArchiver archivedDataWithRootObject:self];
    [NSUserDefaults.standardUserDefaults setObject:pushConfigData
                                            forKey:[self getSavedKey]];
}

- (void)deleteLocal {
    [NSUserDefaults.standardUserDefaults setObject:nil forKey:[self getSavedKey]];
}

- (NSArray <NSNumber *> *)getSupportResolutions {
    return self.urlConfig.getSupportResolutions;
}

+ (void)deleteLocalWithIdentifier:(NSString *)identifier {
    [NSUserDefaults.standardUserDefaults setObject:nil forKey:[self getSavedKeyWithIdentifier:identifier]];
}

+ (NSString *)getSavedKeyWithIdentifier:(NSString *)identifier {
    return [NSString stringWithFormat:@"vel_pull_config_%@", identifier ?: @"default"];
}

- (NSString *)getSavedKey {
    return [self.class getSavedKeyWithIdentifier:self.identifier];
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"YYYY:MM:dd HH:mm:ss";
    }
    return _dateFormatter;
}

- (NSString *)shortDescription {
    NSMutableString *str = [[NSMutableString alloc] initWithFormat:@"%@\n", [self.dateFormatter stringFromDate:self.date]];
    
    if (self.mainUrlConfig.enableABR) {
        [str appendFormat:@"%@ %@:\n", @"main", LocalizedStringFromBundle(@"medialive_abr_config", @"MediaLive")];
        [self.mainUrlConfig.abrUrlConfigs enumerateObjectsUsingBlock:^(VELPullABRUrlConfig * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [str appendFormat:@"%@\n", [obj shortDescription]];
        }];
    } else {
        [str appendFormat:@"%@%@: %@\n", @"main", LocalizedStringFromBundle(@"medialive_pull_address_placeholder", @"MediaLive"),self.mainUrlConfig.url?:@""];
    }
    return str;
}
- (BOOL)ignoreOpenglActivity {
    if (_newApi == NO) {
        return NO;
    }
    return _ignoreOpenglActivity;
}
@end
