// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>
#import "MDPlayerActionView.h"
#import "MDPlayerControlView.h"

NS_ASSUME_NONNULL_BEGIN

/** ---------------------------------------  */
/** {zh}  播放器视图层级                             **/
/**  -playerContainerView                    **/
/**  --EnginePlayerView                       **/
/**  --ActionView                                  **/
/**  ---ControlView                               **/
/** ---------------------------------------  */

@protocol MDPlayerActionViewInterface <NSObject>
@property (nonatomic, weak, nullable) UIView *playerContainerView;
@property (nonatomic, strong, readonly) MDPlayerActionView *actionView;
@property (nonatomic, strong, readonly) MDPlayerControlView *underlayControlView;
@property (nonatomic, strong, readonly) MDPlayerControlView * playbackControlView;
@property (nonatomic, strong, readonly) MDPlayerControlView * playbackLockControlView;
@property (nonatomic, strong, readonly) MDPlayerControlView * overlayControlView;

@end

NS_ASSUME_NONNULL_END
