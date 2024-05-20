// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <MediaLive/VELCommon.h>
#import "VELPullSettingConfig.h"
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, VELPullSettingsType) {
    VELPullSettingsTypeNormal,
    VELPullSettingsTypeFeed
};
@interface VELPullSettingsViewController : VELUIViewController
@property (nonatomic, strong) VELPullSettingConfig *config;
@property(nonatomic, copy) void (^startBlock)(void);

@property (nonatomic, assign) VELPullSettingsType settingType;

- (void)startPlayBtnAction NS_REQUIRES_SUPER; 
@end

NS_ASSUME_NONNULL_END
