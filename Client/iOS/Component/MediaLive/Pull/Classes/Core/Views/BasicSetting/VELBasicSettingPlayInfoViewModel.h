// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import "VELPullBasicSettingDelegate.h"
#import "VELPullSettingViewModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface VELBasicSettingPlayInfoViewModel : VELPullSettingViewModel
@property (nonatomic, strong) VELSettingsButtonViewModel *cyclInfoViewModel;
@property (nonatomic, strong) VELSettingsButtonViewModel *callBackNoteViewModel;
@property (nonatomic, weak) id <VELPullBasicSettingDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
