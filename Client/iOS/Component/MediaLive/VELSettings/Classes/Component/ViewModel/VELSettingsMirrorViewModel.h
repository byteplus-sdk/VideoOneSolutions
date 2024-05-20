// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELSettingsBaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, VELSettingsMirrorType) {
    VELSettingsMirrorTypeCapture,
    VELSettingsMirrorTypePreview,
    VELSettingsMirrorTypeStream
};
@interface VELSettingsMirrorViewModel : VELSettingsBaseViewModel
@property (nonatomic, assign) BOOL captureMirror;
@property (nonatomic, assign) BOOL previewMirror;
@property (nonatomic, assign) BOOL streamMirror;
@property(nonatomic, copy) void (^mirrorActionBlock)(VELSettingsMirrorViewModel *model, VELSettingsMirrorType mirrorType, BOOL isOn);
@end

NS_ASSUME_NONNULL_END
