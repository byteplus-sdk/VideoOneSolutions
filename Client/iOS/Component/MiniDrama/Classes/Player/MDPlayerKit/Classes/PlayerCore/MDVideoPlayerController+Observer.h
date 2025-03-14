// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDVideoPlayerController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MDVideoPlayerController (Observer)

@property (nonatomic, assign) BOOL needResumePlay;

@property (nonatomic, assign) BOOL closeResumePlay;

- (void)addObserver;

- (void)removeObserver;

@end

NS_ASSUME_NONNULL_END
