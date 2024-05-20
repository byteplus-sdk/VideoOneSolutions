// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef VELPushUIViewController_Device_h
#define VELPushUIViewController_Device_h
#import "VELPushUIViewController.h"
@interface VELPushUIViewController (Device) <VELGestureDelegate>
@property (nonatomic, strong) VELFocusView *focusView;
@property (nonatomic, strong) VELUILabel *scaleLabel;

- (void)showFocusViewAt:(CGPoint)center;
- (BOOL)shouldShowFocusView;
- (void)hideFocusView;
- (void)_hideFocusView;
- (void)showScaleLabel:(CGFloat)scale;
- (void)hideScaleLabel;
- (void)setupDeviceGesture;
@end

#endif /* VELPushUIViewController_Device_h */
