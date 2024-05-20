// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <MediaLive/VELCommon.h>
#import "VELPullSettingConfig.h"
NS_ASSUME_NONNULL_BEGIN

@interface VELPullABRSettingViewController : VELUIViewController
@property (nonatomic, strong) VELPullABRUrlConfig *abrConfig;
@property (nonatomic, strong) VELPullSettingConfig *settingConfig;

+ (instancetype)abrSettingWithSettingConfig:(VELPullSettingConfig *)settingConfig abrConfig:(nullable VELPullABRUrlConfig *)abrConfig;

- (void)showFromVC:(nullable UIViewController *)vc
        completion:(void (^)(VELPullABRSettingViewController *vc, VELPullABRUrlConfig *urlConfig))completion;

- (void)hide;
@end

NS_ASSUME_NONNULL_END
