// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "SmartSubtitleViewController.h"
#import "Masonry.h"
#import "SmartSubtitleManager.h"
#import "SubtitleidType.h"
#import "VEBaseVideoDetailViewController+Private.h"
#import "VEInterfaceSmartSubtitleConf.h"
#import "BaseVideoModel.h"
#import "VEVideoPlayerController.h"
#import <ToolKit/ToolKit.h>

@interface SmartSubtitleViewController ()

@property (nonatomic, strong) UIView *subTitleView;

@property (nonatomic, strong) SmartSubtitleManager *manager;

@end

@implementation SmartSubtitleViewController

- (void)layoutUI {
    [super layoutUI];
    [self.playContainerView.contentView insertSubview:self.subTitleView aboveSubview:self.playerController.view];
    [self.subTitleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.playContainerView.contentView);
    }];
    [self.subTitleView addSubview:self.manager.subTitleLabel];
    [self.manager.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.offset(44);
        make.trailing.offset(-44);
        make.bottom.equalTo(self.subTitleView.mas_safeAreaLayoutGuideBottom).offset(-25);
    }];
}

- (void)playerOptionsAfterSetMediaSource {
    [super playerOptionsAfterSetMediaSource];
    self.manager.videoEngine = self.playerController.videoEngine;
    [self.manager openSubtitle:self.videoModel.subtitleAuthToken];
}

#pragma mark - VEVideoPlaybackDelegate
- (void)videoPlayer:(id<VEVideoPlayback>)player playbackStateDidChange:(VEPlaybackState)state uniqueId:(NSString *)uniqueId {
    if (state == VEPlaybackStateFinished) {
        __weak __typeof__(self) weak_self = self;
        dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
            weak_self.manager.subTitleLabel.text = @"";
        });
    }
}

#pragma mark - Getter
- (VEInterfaceBaseVideoDetailSceneConf *)interfaceScene {
    VEInterfaceSmartSubtitleConf *scene = [VEInterfaceSmartSubtitleConf new];
    scene.manager = self.manager;
    return scene;
}

- (SmartSubtitleManager *)manager {
    if (!_manager) {
        _manager = [[SmartSubtitleManager alloc] init];
    }
    return _manager;
}

- (UIView *)subTitleView {
    if (!_subTitleView) {
        _subTitleView = [[UIView alloc] init];
        _subTitleView.backgroundColor = [UIColor clearColor];
    }
    return _subTitleView;
}
@end
