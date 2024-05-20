// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import <MediaLive/VELSettings.h>
#import <MediaLive/VELCommon.h>
NS_ASSUME_NONNULL_BEGIN

@protocol VELPushInfoSettingDelegate <NSObject>
@optional
- (void)showCycleInfo;
- (void)hideCycleInfo;
- (void)showCallbackNote;
- (void)hideCallbackNote;
@end
@interface VELPushSettingInfoViewModel : NSObject
@property (nonatomic, strong, readonly) UIView *settingsView;
@property (nonatomic, strong) VELSettingsButtonViewModel *cyclInfoViewModel;
@property (nonatomic, strong) VELSettingsButtonViewModel *callBackNoteViewModel;
@property(nonatomic, weak) id <VELPushInfoSettingDelegate> delegate;
- (BOOL)isShowingOnView:(UIView *)view;
@end

NS_ASSUME_NONNULL_END
