// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEVideoPlayerController.h"

NS_ASSUME_NONNULL_BEGIN

@interface VEVideoPlayerController (Resolution)

+ (TTVideoEngineResolutionType)getPlayerCurrentResolution;

+ (void)setPlayerCurrentResolution:(TTVideoEngineResolutionType)defaultResolution;

@end

NS_ASSUME_NONNULL_END
