// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, LiveIconState) {
    LiveIconStateHidden,
    LiveIconStateNetQuality,
    LiveIconStateNetQualityBad,
    LiveIconStateMic,
    LiveIconStateCamera,
};

@interface LiveStateIconView : UIView

- (instancetype)initWithState:(LiveIconState)state;

- (void)updateState:(LiveIconState)state;

@end

NS_ASSUME_NONNULL_END
