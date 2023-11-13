// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
@class VEVideoModel, VEVideoPlayerController;
#import "VEViewController.h"
#import "VEVideoPlayerController.h"

@protocol VEVideoDetailProtocol <NSObject>

/**
 * @brief When we switch to VEVideoDetailViewController, we can choose to pass the previous player by this interface,
 * or create a new one if not exist.
 */

- (VEVideoPlayerController *)currentPlayerController:(VEVideoModel *)videoModel;

@end

/**
 * @brief Common video player view controller for feed and channel videos.
 */

@interface VEVideoDetailViewController : VEViewController

- (instancetype)initWithType:(VEVideoPlayerType)videoPlayerType;

@property (nonatomic, strong) VEVideoModel *videoModel;

@property (nonatomic, weak) id<VEVideoDetailProtocol> delegate;

@end
