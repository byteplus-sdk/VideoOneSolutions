// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEVideoPlayerController+Resolution.h"

static TTVideoEngineResolutionType kDefaultResolutionType = TTVideoEngineResolutionTypeHD;

@implementation VEVideoPlayerController (Resolution)

+ (TTVideoEngineResolutionType)getPlayerCurrentResolution {
    return kDefaultResolutionType;
}

+ (void)setPlayerCurrentResolution:(TTVideoEngineResolutionType)defaultResolution {
    kDefaultResolutionType = defaultResolution;
}

@end
