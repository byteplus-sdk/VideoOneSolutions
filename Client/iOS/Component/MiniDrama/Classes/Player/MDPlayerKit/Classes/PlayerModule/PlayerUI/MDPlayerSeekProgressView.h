// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MDPlayerSeekProgressViewProtocol <NSObject>

- (void)showView:(BOOL)show;

- (void)updateProgress:(NSInteger)playbackTime duration:(NSInteger)duration;

@end

@interface MDPlayerSeekProgressView : UIView <MDPlayerSeekProgressViewProtocol>


@end

NS_ASSUME_NONNULL_END
