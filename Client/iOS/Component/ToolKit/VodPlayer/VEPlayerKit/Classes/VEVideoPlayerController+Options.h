// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEVideoPlayerController.h"


@interface VEVideoPlayerController (EngineOptions)

@property (nonatomic, assign) BOOL h265Open;

@property (nonatomic, assign) BOOL hardwareDecodeOpen;

- (void)openVideoEngineFeedDefaultOptions;

- (void)openVideoEngineShortDefaultOptions;

@end

