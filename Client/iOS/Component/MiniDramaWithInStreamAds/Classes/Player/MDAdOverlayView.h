// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// Display-only overlay shown on top of an ad. Owns the progress bar, a
/// "mm:ss / mm:ss" progress-time label, and a non-interactive "Advertising" banner.
/// All touches pass through to the underlying ad view.
@interface MDAdOverlayView : UIView

/// Updates the progress bar and the "mm:ss / mm:ss" label.
- (void)updateProgressWithCurrentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime;

/// Resets progress.
- (void)reset;

@end

NS_ASSUME_NONNULL_END
