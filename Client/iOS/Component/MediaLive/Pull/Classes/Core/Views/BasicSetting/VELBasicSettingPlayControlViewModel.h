// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import "VELPullBasicSettingDelegate.h"
#import "VELPullSettingViewModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface VELBasicSettingPlayControlViewModel : VELPullSettingViewModel
@property (nonatomic, strong) VELSettingsSegmentViewModel *topViewModel;
@property (nonatomic, strong) VELSettingsSegmentViewModel *resolutionViewModel;
///  @[@(0)), @(1)), @(2)), @(3)), @(4))]
@property (nonatomic, strong, readonly) NSArray <NSNumber *> *supportResolutions;
@property (nonatomic, assign, readonly) NSInteger defaultResolution;

/// hdr
@property (nonatomic, strong) VELSettingsButtonViewModel *hdrViewModel;
@property (nonatomic, strong) VELSettingsButtonViewModel *backgroundPlayViewModel;
@property (nonatomic, weak) id <VELPullBasicSettingDelegate> delegate;
- (void)setShouldPlayInBackground:(BOOL)playInBackground;

- (void)setSupportResolutions:(NSArray<NSNumber *> * _Nonnull)supportResolutions defaultResolution:(NSInteger)defaultRes;
@end

NS_ASSUME_NONNULL_END
