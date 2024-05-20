// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef VELPushUIViewController_Info_h
#define VELPushUIViewController_Info_h
#import "VELPushSettingInfoViewModel.h"
#import "VELPushUIViewController.h"
#import <MediaLive/VELCommon.h>
@class _VELPushInfoUIScrollView;
@interface VELPushUIViewController (InfoControl) <VELPushInfoSettingDelegate>
@property (nonatomic, strong, readonly) _VELPushInfoUIScrollView *infoScrollView;
@property (nonatomic, strong, readonly) NSMutableArray <VELConsoleView *>* infoViews;
@property (nonatomic, strong, readonly) VELConsoleView *cycleInfoView;
@property (nonatomic, strong, readonly) VELConsoleView *callBackInfoView;
@property (nonatomic, strong, readonly) UIView *infoContainer;
@property (nonatomic, strong, readonly) VELPushSettingInfoViewModel *infoSettingVM;
- (void)hideAllConsoleInfoView;
@end

#endif /* VELPushUIViewController_Info_h */
