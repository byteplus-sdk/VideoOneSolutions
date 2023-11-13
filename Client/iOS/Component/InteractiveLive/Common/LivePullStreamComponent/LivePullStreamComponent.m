// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LivePullStreamComponent.h"
#import "LiveRTCManager.h"
#import "LiveSettingVideoConfig.h"

@interface LivePullStreamComponent ()

@property (nonatomic, weak) UIView *superView;
@property (nonatomic, weak) LivePullRenderView *renderView;
@property (nonatomic, strong) LiveRoomInfoModel *roomModel;

@end

@implementation LivePullStreamComponent

- (instancetype)initWithSuperView:(UIView *)superView {
    self = [super init];
    if (self) {
        _superView = superView;
    }
    return self;
}
- (void)open:(LiveRoomInfoModel *)roomModel {
    _roomModel = roomModel;
    _isConnect = YES;

    if (!_renderView) {
        LivePullRenderView *renderView = [[LivePullRenderView alloc] init];
        renderView.hostUid = roomModel.anchorUserID;
        [_superView addSubview:renderView];
        [renderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_superView);
        }];
        _renderView = renderView;
    }

    NSString *defaultResUrl = roomModel.streamPullStreamList[@"720"];

    if (NOEmptyStr(defaultResUrl)) {
        __weak __typeof(self) wself = self;
        [[LivePlayerManager sharePlayer] setPlayerWithUrlMap:roomModel.streamPullStreamList
                                           defaultResolution:@"720"
                                                   superView:_renderView.streamView
                                                    SEIBlcok:^(NSDictionary *_Nonnull SEIDic) {
                                                        // Monitor and parse SEI
                                                        if (SEIDic && [SEIDic isKindOfClass:[NSDictionary class]]) {
                                                            PullRenderStatus status = PullRenderStatusNone;
                                                            NSDictionary *dic = [wself dictionaryWithJsonString:SEIDic[@"app_data"]];
                                                            if ([dic isKindOfClass:[NSDictionary class]]) {
                                                                RTCMixStatus value = [dic[LiveSEIKEY] integerValue];
                                                                switch (value) {
                                                                    case RTCMixStatusPK:
                                                                        status = PullRenderStatusPK;
                                                                        break;
                                                                    case RTCMixStatusAddGuestsTwo:
                                                                        status = PullRenderStatusTwoCoHost;
                                                                        break;
                                                                    case RTCMixStatusAddGuestsMulti:
                                                                        status = PullRenderStatusMultiCoHost;
                                                                        break;
                                                                    case RTCMixStatusSingleLive:
                                                                    default:
                                                                        status = PullRenderStatusNone;
                                                                        break;
                                                                }
                                                                [wself updateWithStatus:status];
                                                            }
                                                        }
                                                    }];
        [[LivePlayerManager sharePlayer] playPull];

        if ((roomModel.hostUserModel.videoSize.width *
             roomModel.hostUserModel.videoSize.height) > 0) {
            if ((roomModel.hostUserModel.videoSize.width > roomModel.hostUserModel.videoSize.height)) {
                // Horizontal video flow
                [[LivePlayerManager sharePlayer] updatePlayScaleMode:PullScalingModeNone];
            } else {
                // Vertical video flow
                [[LivePlayerManager sharePlayer] updatePlayScaleMode:PullScalingModeAspectFill];
            }
        }
    }
    if (roomModel.hostUserModel) {
        [self updateHostMic:roomModel.hostUserModel.mic camera:roomModel.hostUserModel.camera];
    }
}

- (void)updateHostMic:(BOOL)mic camera:(BOOL)camera {
    if (_renderView) {
        [_renderView updateHostMic:mic camera:camera];
    }
}

- (void)updateWithStatus:(PullRenderStatus)status {
    if (_renderView) {
        _renderView.status = status;
    }
    if ([self.delegate respondsToSelector:@selector(pullStreamComponent:didChangeStatus:)]) {
        [self.delegate pullStreamComponent:self didChangeStatus:status];
    }
}

- (void)close {
    _isConnect = NO;
    if (_renderView) {
        [_renderView removeFromSuperview];
        _renderView = nil;
    }
    [[LivePlayerManager sharePlayer] stopPull];
}

#pragma mark - Tool

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }

    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if (err) {
        return nil;
    }
    return dic;
}

@end
