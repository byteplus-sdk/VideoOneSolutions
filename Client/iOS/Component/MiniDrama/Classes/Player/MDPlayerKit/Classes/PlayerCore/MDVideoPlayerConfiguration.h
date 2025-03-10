// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import "MDVideoPlayback.h"

NS_ASSUME_NONNULL_BEGIN

@interface MDVideoPlayerConfiguration : NSObject
@property (nonatomic, assign) MDVideoViewMode videoViewMode;
@property (nonatomic, assign) BOOL audioMode;
@property (nonatomic, assign) BOOL muted;
@property (nonatomic, assign) BOOL looping;
@property (nonatomic, assign) CGFloat playbackRate;
@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, assign) BOOL isH265;
@property (nonatomic, assign) BOOL isSupportPictureInPictureMode;
@property (nonatomic, assign) BOOL isOpenHardware;
@property (nonatomic, assign) BOOL isOpenSR;
@property (nonatomic, assign) BOOL enableLoadSpeed;

// Pipture in picture , supported on iOS15+
@property (nonatomic, assign) BOOL enablePip;

+ (MDVideoPlayerConfiguration *)defaultPlayerConfiguration;

@end

NS_ASSUME_NONNULL_END
