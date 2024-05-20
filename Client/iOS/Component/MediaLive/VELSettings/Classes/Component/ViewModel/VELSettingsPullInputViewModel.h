// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELSettingsInputViewModel.h"
#import "VELPullSettingConfig.h"
#import "VELSettingsButtonViewModel.h"
NS_ASSUME_NONNULL_BEGIN
@interface VELSettingsPullInputViewModel : VELSettingsInputViewModel
@property (nonatomic, strong) VELPullUrlConfig *mainUrlConfig;
@property (nonatomic, strong) VELPullUrlConfig *backupUrlConfig;
@property (nonatomic, strong) VELPullUrlConfig *currentUrlConfig;
@property (nonatomic, assign) VELPullUrlType urlType;
@property (nonatomic, assign, readonly) BOOL enableABRConfig;
@property (nonatomic, assign) BOOL enableBackupConfig;
@property(nonatomic, copy) void (^streamTypeChangedBlock)(VELSettingsPullInputViewModel *model, VELPullUrlType urlType);
@property(nonatomic, copy) void (^addAbrActionBlock)(VELSettingsPullInputViewModel *model);
@property(nonatomic, copy) void (^clearAbrActionBlock)(VELSettingsPullInputViewModel *model);
@property(nonatomic, copy) void (^didClickAbrConfigBlock)(VELSettingsPullInputViewModel *model, VELSettingsButtonViewModel *btnModel, VELPullABRUrlConfig *cfg);

@property(nonatomic, copy) void (^deleteAbrConfigBlock)(VELSettingsPullInputViewModel *model, VELSettingsButtonViewModel *btnModel, VELPullABRUrlConfig *cfg);
@end

NS_ASSUME_NONNULL_END
