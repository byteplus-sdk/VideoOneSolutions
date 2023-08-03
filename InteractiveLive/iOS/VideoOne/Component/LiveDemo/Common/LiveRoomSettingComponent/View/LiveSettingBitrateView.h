// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LiveSettingBitrateView : UIView
@property (nonatomic, assign) NSInteger minBitrate;
@property (nonatomic, assign) NSInteger maxBitrate;
@property (nonatomic, assign) NSInteger bitrate;

@property (nonatomic, copy) void (^bitrateDidChangedBlock)(NSInteger bitrate);
@end

NS_ASSUME_NONNULL_END
