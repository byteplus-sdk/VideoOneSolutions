//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "VEVideoPlayerController.h"
#import "VEViewController.h"

@class VEVideoModel;

@protocol VEVideoDetailProtocol <NSObject>

/**
 * @brief When we switch to VEVideoDetailViewController, we can choose to pass the previous player by this interface,
 * or create a new one if not exist.
 */

- (VEVideoPlayerController *)currentPlayerController:(VEVideoModel *)videoModel;

@end

@interface VEBaseVideoDetailViewController : VEViewController <VEInterfaceDelegate, VEVideoPlaybackDelegate>

- (instancetype)initWithType:(VEVideoPlayerType)videoPlayerType;

@property (nonatomic, strong) VEVideoModel *videoModel;

@property (nonatomic, weak) id<VEVideoDetailProtocol> delegate;

@property (nonatomic, copy) void (^closeCallback)(BOOL landscapeMode, VEVideoPlayerController *playerController);

@property (nonatomic, assign) BOOL landscapeMode;

@end
