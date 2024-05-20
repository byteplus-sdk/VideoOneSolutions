// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, VELPullResolutionType) {
    VELPullResolutionTypeOrigin,
    VELPullResolutionTypeUHD,
    VELPullResolutionTypeHD,
    VELPullResolutionTypeLD,
    VELPullResolutionTypeSD
};
typedef NS_ENUM(NSInteger, VELPullUrlType) {
    VELPullUrlTypeMain,
    VELPullUrlTypeBackup,
};
typedef NS_ENUM(NSInteger, VELPullUrlFormat) {
    VELPullUrlFormatUnKnown,
    VELPullUrlFormatFLV,
    VELPullUrlFormatHLS,
    VELPullUrlFormatRTM,
};
typedef NS_ENUM(NSInteger, VELPullUrlProtocol) {
    VELPullUrlProtocolUnKnown,
    VELPullUrlProtocolTCP,
    VELPullUrlProtocolQuic,
    VELPullUrlProtocolTLS,
};

@class VELPullABRUrlConfig;

@interface VELPullUrlConfig : NSObject <NSCoding>
@property (nonatomic, copy, nullable) NSString *url;
@property (nonatomic, copy, nullable, readonly) NSString *ipHostUrl;
@property (nonatomic, copy, nullable, readonly) NSString *urlNoPort;
@property (nonatomic, copy, nullable, readonly) NSString *rtmBackupFLV;
@property (nonatomic, copy, nullable, readonly) NSString *formatStr;
@property (nonatomic, assign) VELPullUrlFormat format;
@property (nonatomic, assign) VELPullUrlProtocol protocol;
@property (nonatomic, copy, nullable, readonly) NSArray <VELPullUrlConfig *> *mutableFmtConfigs;
@property (nonatomic, copy, nullable, readonly) NSArray <VELPullABRUrlConfig *> *abrUrlConfigs;
@property (nonatomic, assign, readonly) NSInteger port;
@property (nonatomic, assign) VELPullUrlType urlType;
@property (nonatomic, assign) NSInteger bitrate;
@property (nonatomic, assign) VELPullResolutionType resolution;
@property (nonatomic, copy, readonly) NSString *resolutionDes;
@property (nonatomic, assign) BOOL enableABR;
@property (nonatomic, assign) BOOL enableQuic;
@property (nonatomic, assign, readonly) BOOL isABRConfig;
+ (instancetype)configWithUrl:(nullable NSString *)url type:(VELPullUrlType)type;
- (BOOL)isSupportQuic;
- (BOOL)isSupportRTM;
- (BOOL)isSupportRTMByChild;
- (BOOL)isValid;
- (void)replaceHostIPWith:(NSDictionary <NSString *, NSString *>*)ipHostMap;
- (void)addABRConfig:(VELPullABRUrlConfig *)urlConfig;
- (void)refreshABRConfig:(VELPullABRUrlConfig *)urlConfig;
- (void)removeABRConfig:(VELPullABRUrlConfig *)urlConfig;
- (void)clearABRConfig;
- (NSArray <NSNumber *> *)suggestedABRResolutions;
- (NSArray <NSNumber *> *)getSupportResolutions;
- (BOOL)canAddABRConfig;
- (nullable VELPullABRUrlConfig *)getDefaultABRConfig;
- (nullable VELPullABRUrlConfig *)getOriginABRConfig;
- (NSArray <VELPullUrlConfig *> *)getAllActiveUrlConfigs;
- (NSString *)shortDescription;
@end

@interface VELPullABRUrlConfig : VELPullUrlConfig
@property (nonatomic, assign) BOOL isDefault;
@property (nonatomic, assign) NSInteger gopSec;

@end

NS_ASSUME_NONNULL_END
