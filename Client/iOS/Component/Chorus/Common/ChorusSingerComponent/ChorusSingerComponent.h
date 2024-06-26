// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface ChorusSingerComponent : NSObject

@property (nonatomic, strong) UIView *backgroundView;

- (instancetype)initWithSuperView:(UIView *)superView;

- (void)updateSingerUIWithChorusStatus:(ChorusStatus)status;
- (void)updateNetworkQuality:(ChorusNetworkQualityStatus)status uid:(NSString *)uid;
- (void)updateFirstVideoFrameRenderedWithUid:(NSString *)uid;
- (void)updateUserAudioVolume:(NSDictionary<NSString *, NSNumber *> *)dict;

@end

NS_ASSUME_NONNULL_END
