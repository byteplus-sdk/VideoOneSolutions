// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>
#import <MediaLive/VELSettings.h>
#import <MediaLive/VELCommon.h>
NS_ASSUME_NONNULL_BEGIN

@interface VELPullSettingViewModel : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong, readonly) UIView *settingsView;
@property (nonatomic, copy, readonly) NSString *cellIdentifier;
- (void)setupSettingsView;
- (void)setupViewModels;
@end

NS_ASSUME_NONNULL_END
