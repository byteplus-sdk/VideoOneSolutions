// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef VELPushUIViewController_Stream_h
#define VELPushUIViewController_Stream_h
#import "VELPushUIViewController.h"

@interface VELPushUIViewController (Stream)
@property (nonatomic, strong, readonly) VELSettingsCollectionView *streamingControl;
@property (nonatomic, strong, readonly) VELSettingsTableView *pushSettingView;
@property (nonatomic, strong, readonly) VELSettingsRecordViewModel *recordViewModel;
@property (nonatomic, strong, readonly) VELSettingsMirrorViewModel *mirrorViewModel;
@property (nonatomic, strong, readonly) VELSettingPushVCfgViewModel *vCfgViewModel;
@property (nonatomic, strong, readonly) VELSettingPushACfgViewModel *aCfgViewModel;
@property (nonatomic, strong, readonly) VELSettingsInputActionViewModel *seiViewModel;
- (void)setupUIForStreaming;
- (void)setupUIForStreamingLandspace:(BOOL)isLandSpace force:(BOOL)force;

- (void)showStreamSettings;
- (void)hideStreamSettings;
- (BOOL)isStreamSettingsShowing;
- (void)resetSettingView;
@end

#endif /* VELPushUIViewController_Stream_h */
