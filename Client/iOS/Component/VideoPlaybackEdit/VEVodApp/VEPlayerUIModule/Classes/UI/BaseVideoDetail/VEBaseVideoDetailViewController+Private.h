//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "VEBaseVideoDetailViewController.h"
#import "VEInterfaceBaseVideoDetailSceneConf.h"
#import "VEPlayerContainer.h"
#import "VEPlayerKit.h"
#import "VESettingManager.h"
#import "VEVideoDetailVideoInfoView.h"
#import "VEVideoModel.h"
#import <Masonry/Masonry.h>
#import <ToolKit/UIColor+String.h>
#import <ToolKit/UIViewController+Orientation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VEBaseVideoDetailViewController ()

@property (nonatomic, strong) VEVideoPlayerController *playerController; // player Container

@property (nonatomic, strong) VEInterface *playerControlView; // player Control view

@property (nonatomic, strong) VEPlayerContainer *playContainerView; // playerView & playerControlView Container

@property (nonatomic, assign) VEVideoPlayerType videoPlayerType;

@property (nonatomic, strong) VEVideoDetailVideoInfoView *videoInfoView;

@property (nonatomic, strong) VEInterfaceBaseVideoDetailSceneConf *sceneConf;

@property (nonatomic, assign) BOOL prefersHomeIndicatorAutoHidden;

- (void)layoutUI;

- (void)updateUIToSize:(CGSize)size;

- (void)reloadPlayerController;

// called before set media source
- (void)playerOptionsBeforeSetMediaSource;

// called after set media source
- (void)playerOptionsAfterSetMediaSource;

- (void)closeViewControllerAnimated:(BOOL)animated;

- (id<VEPlayCoreAbilityProtocol>)playerCore;

- (VEInterfaceBaseVideoDetailSceneConf *)interfaceScene;

@property (class, nonatomic, readonly) Class playerContainerClass; // default is [VEPlayerContainer class]. Used when creating playContainerView.

@end

NS_ASSUME_NONNULL_END
