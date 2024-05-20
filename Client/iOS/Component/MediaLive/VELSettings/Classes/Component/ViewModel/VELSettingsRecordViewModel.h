// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELSettingsBaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, VELSettingsRecordState) {
    VELSettingsRecordStateNone,
    VELSettingsRecordStateStart,
    VELSettingsRecordStateStop,
    VELSettingsRecordStateSnapshot
};

@interface VELSettingsRecordViewModel : VELSettingsBaseViewModel
@property (nonatomic, assign) NSTimeInterval time;
@property (nonatomic, assign) BOOL showSanpShot;
@property (nonatomic, assign) VELSettingsRecordState state;
@property(nonatomic, copy) void (^recordActionBlock)(VELSettingsRecordViewModel *model, VELSettingsRecordState state, int width, int height);
@end

NS_ASSUME_NONNULL_END
