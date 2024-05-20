// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef VELPushUIViewController_Preview_h
#define VELPushUIViewController_Preview_h
#import "VELPushUIViewController.h"

@interface VELPushUIViewController (Preview)
@property (nonatomic, strong, readonly) VELPushSettingViewController *previewSettingVC;
@property (nonatomic, strong, readonly) VELSettingsCollectionView *previewControl;
- (void)showPreviewSettings;
- (void)hidePreviewSettings;
- (BOOL)isPreviewSettingsShowing;
- (void)setupUIForNotStreaming;
- (void)setupUIForNotStreamingLandSpace:(BOOL)isLandSpace force:(BOOL)force;
@end
#endif /* VELPushUIViewController_Preview_h */
