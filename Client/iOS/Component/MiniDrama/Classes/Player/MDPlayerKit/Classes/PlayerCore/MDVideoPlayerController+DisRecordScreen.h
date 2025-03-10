// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDVideoPlayerController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MDVideoPlayerController (DIsRecordScreen)

- (void)registerScreenCapturedDidChangeNotification;

- (void)unregisterScreenCaptureDidChangeNotification;

@end

NS_ASSUME_NONNULL_END
