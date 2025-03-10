// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define MiniDramaSpeedTipViewViewWidth 120
#define MiniDramaSpeedTipViewViewHeight 40

@interface MiniDramaSpeedTipView : UIView

- (void)showSpeedView:(NSString *)tip;

- (void)hiddenSpeedView;

@end

NS_ASSUME_NONNULL_END
