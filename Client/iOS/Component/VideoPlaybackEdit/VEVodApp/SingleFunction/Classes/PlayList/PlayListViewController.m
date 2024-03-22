// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "PlayListViewController.h"
#import "VEBaseVideoDetailViewController+Private.h"
#import "VEInterfacePlayListConf.h"
#import "PlayListView.h"
#import "PlayListManager.h"

@interface PlayListViewController () <PlayListManagerDelegate>

@property (nonatomic, strong) PlayListManager *manager;

@end

@implementation PlayListViewController

- (void)layoutUI {
    [super layoutUI];
    if (!self.landscapeMode) {
        [self.view addSubview:self.manager.playListView];
        [self.manager.playListView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.videoInfoView.mas_bottom).offset(16);
            make.leading.trailing.equalTo(self.view);
            make.bottom.equalTo(self.view).priority(MASLayoutPriorityDefaultLow);
        }];
    }
}


#pragma mark - VEVideoPlaybackDelegate
- (void)videoPlayer:(id<VEVideoPlayback>)player playbackStateDidChange:(VEPlaybackState)state uniqueId:(NSString *)uniqueId {
    if (state == VEPlaybackStateFinished) {
        if (self.playMode == PlayListModeLoop) {
            if (self.manager.currentPlayViewIndex != self.manager.playList.count - 1) {
                self.manager.currentPlayViewIndex = self.manager.currentPlayViewIndex + 1;
            } else {
                self.manager.currentPlayViewIndex = 0;
            }
        }
    }
}

#pragma  mark - PlayListManagerDelegate
- (void)updatePlayVideo:(VEVideoModel *)videoModel {
    self.videoModel = videoModel;
    VEInterfacePlayListConf *scene = (VEInterfacePlayListConf *)self.sceneConf;
    [scene refresh];
}

#pragma mark - Getter
- (VEInterfaceBaseVideoDetailSceneConf *)interfaceScene {
    VEInterfacePlayListConf *scene = [VEInterfacePlayListConf new];
    scene.skipPlayMode = YES;
    scene.manager = self.manager;
    return scene;
}

- (PlayListManager *)manager {
    if (!_manager) {
        _manager = [[PlayListManager alloc] init];
        _manager.playList = self.playList;
        _manager.currentPlayViewIndex = 0;
        _manager.delegate = self;
    }
    return _manager;
}
@end
