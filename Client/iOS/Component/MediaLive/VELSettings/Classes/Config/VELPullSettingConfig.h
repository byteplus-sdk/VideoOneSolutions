// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import "VELPullUrlConfig.h"
NS_ASSUME_NONNULL_BEGIN


@interface VELPullSettingConfig : NSObject <NSCoding, NSCopying, NSMutableCopying>
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, assign) BOOL fromLocal;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, assign, getter=isNewApi) BOOL newApi;
@property (nonatomic, assign) VELPullUrlType urlType;
@property (nonatomic, strong, readonly) VELPullUrlConfig *urlConfig;
@property (nonatomic, strong, readonly) VELPullUrlConfig *mainUrlConfig;
@property (nonatomic, assign) VELPullUrlFormat suggestFormat;
@property (nonatomic, assign) VELPullUrlProtocol suggestProtocol;
@property (nonatomic, assign) BOOL enableAutoResolutionDegrade;
@property (nonatomic, assign) BOOL enableSEI;
@property (nonatomic, assign) BOOL enableQuic;
@property (nonatomic, assign) BOOL enableABR;
@property (nonatomic, assign, getter=isValid, readonly) BOOL valid;
@property (nonatomic, assign) BOOL shouldReportAudioFrame;
@property (nonatomic, assign) BOOL ignoreOpenglActivity;
@property (nonatomic, assign) BOOL rtmAutoDowngrade;
@property (nonatomic, assign) BOOL enableSinglePlayer;
@property (nonatomic, assign) BOOL enableCacheblePlayer;
@property (nonatomic, assign) BOOL feedAutoScroll;
@property (nonatomic, assign) NSInteger feedAutoScrollInternal;
@property (nonatomic, assign) BOOL feedPreload;
- (void)addABRConfig:(VELPullABRUrlConfig *)urlConfig;
- (void)refreshABRConfig:(VELPullABRUrlConfig *)urlConfig;
- (void)removeABRConfig:(VELPullABRUrlConfig *)urlConfig;
- (void)clearABRConfig;
- (NSArray <VELPullUrlConfig *> *)getAllActiveUrlConfigs;
- (BOOL)checkShouldOpentQuic;
- (void)save;
- (void)deleteLocal;
- (NSArray <NSNumber *> *)getSupportResolutions;
+ (void)deleteLocalWithIdentifier:(NSString *)identifier;
+ (instancetype)loadFromLocalWithIdentifier:(nullable NSString *)identifier;
+ (instancetype)defaultConfigWithUrlString:(NSString *)url;
- (NSString *)shortDescription;
@end

NS_ASSUME_NONNULL_END
