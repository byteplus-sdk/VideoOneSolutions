// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChorusSingerItemView : UIView

@property (nonatomic, strong) ChorusUserModel * _Nullable userModel;

- (instancetype)initWithLocationRight:(BOOL)isRight;
- (void)updateNetworkQuality:(ChorusNetworkQualityStatus)status;
- (void)updateFirstVideoFrameRendered;
- (void)updateUserAudioVolume:(NSInteger)volume;

@end

NS_ASSUME_NONNULL_END
