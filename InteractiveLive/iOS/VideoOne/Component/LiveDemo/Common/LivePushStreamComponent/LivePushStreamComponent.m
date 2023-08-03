// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LivePushStreamComponent.h"
#import "LivePushRenderView.h"
#import "LiveRTCManager.h"

@interface LivePushStreamComponent ()

@property (nonatomic, weak) UIView *superView;
@property (nonatomic, weak) LivePushRenderView *renderView;
@property (nonatomic, strong) LiveRoomInfoModel *roomModel;

@end

@implementation LivePushStreamComponent

- (instancetype)initWithSuperView:(UIView *)superView
                        roomModel:(LiveRoomInfoModel *)roomModel
                    streamPushUrl:(NSString *)streamPushUrl {
    self = [super init];
    if (self) {
        _roomModel = roomModel;
        _superView = superView;
    }
    return self;
}

- (void)openWithUserModel:(LiveUserModel *)userModel {
    _isConnect = YES;

    [[LiveRTCManager shareRtc] bindCanvasViewToUid:userModel.uid];

    if (!_renderView) {
        LivePushRenderView *renderView = [[LivePushRenderView alloc] init];
        [renderView updateLiveTime:self.roomModel.startTime];
        [_superView addSubview:renderView];
        [renderView mas_makeConstraints:^(MASConstraintMaker *make) {
          make.edges.equalTo(_superView);
        }];
        _renderView = renderView;
    }
    [_renderView updateUserModel:userModel];
    [self updateHostMic:userModel.mic camera:userModel.camera];
}

- (void)updateNetworkQuality:(LiveNetworkQualityStatus)status {
    if(self.renderView) {
        __weak __typeof(self) wself = self;
        dispatch_queue_async_safe(dispatch_get_main_queue(), (^{
            [wself.renderView updateNetworkQuality:status];
        }))
    }
}

- (void)close {
    _isConnect = NO;
    if (_renderView) {
        [_renderView removeFromSuperview];
        _renderView = nil;
    }
}

- (void)updateHostMic:(BOOL)mic camera:(BOOL)camera {
    if (_renderView) {
        [_renderView updateHostMic:mic camera:camera];
    }
}

@end
