// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEActionButton.h"

typedef enum : NSUInteger {
    VEMultiStatePlayStateUnknown,
    VEMultiStatePlayStatePlay,
    VEMultiStatePlayStatePause,
    VEMultiStatePlayStateReplay
} VEMultiStatePlayState;

@interface VEMultiStatePlayButton : VEActionButton

@property (nonatomic, assign) VEMultiStatePlayState playState;

@end
