// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LivePushRenderView.h"
#import "LiveStateIconView.h"
#import "LiveRTCRenderView.h"
#import "LiveTimeView.h"

@interface LivePushRenderView ()

@property (nonatomic, strong) LiveRTCRenderView *streamView;
@property (nonatomic, strong) LiveTimeView *timeView;
@property (nonatomic, strong) LiveStateIconView *netQualityView;
@property (nonatomic, strong) LiveStateIconView *micView;
@property (nonatomic, strong) LiveStateIconView *cameraView;

@end

@implementation LivePushRenderView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubview:self.streamView];
        [self.streamView mas_makeConstraints:^(MASConstraintMaker *make) {
          make.edges.equalTo(self);
        }];
        
        [self addSubview:self.timeView];
        [self.timeView mas_makeConstraints:^(MASConstraintMaker *make) {
          make.height.mas_equalTo(20);
          make.left.mas_equalTo(12);
          make.top.mas_equalTo(50 + [DeviceInforTool getStatusBarHight]);
        }];
        
        [self addSubview:self.netQualityView];
        [self.netQualityView mas_makeConstraints:^(MASConstraintMaker *make) {
          make.height.mas_equalTo(20);
          make.left.equalTo(self.timeView.mas_right).offset(6);
          make.centerY.equalTo(self.timeView);
        }];

        [self addSubview:self.micView];
        [self.micView mas_makeConstraints:^(MASConstraintMaker *make) {
          make.height.left.equalTo(self.netQualityView);
          make.top.mas_equalTo(75 + [DeviceInforTool getStatusBarHight]);
        }];

        [self addSubview:self.cameraView];
        [self.cameraView mas_makeConstraints:^(MASConstraintMaker *make) {
          make.height.left.equalTo(self.netQualityView);
          make.top.mas_equalTo(100 + [DeviceInforTool getStatusBarHight]);
        }];
    }
    return self;
}

#pragma mark - Publish Action

- (void)updateHostMic:(BOOL)mic camera:(BOOL)camera {
    self.micView.hidden = mic;
    self.cameraView.hidden = camera;
    self.streamView.isCamera = camera;
    
    CGFloat top = self.micView.hidden ? 75 + [DeviceInforTool getStatusBarHight] : 100 + [DeviceInforTool getStatusBarHight];
    [self.cameraView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(top);
    }];
}

- (void)updateNetworkQuality:(LiveNetworkQualityStatus)status {
    if (status == LiveNetworkQualityStatusGood) {
        [self.netQualityView updateState:LiveIconStateNetQuality];
    } else if (status == LiveNetworkQualityStatusNone) {
        [self.netQualityView updateState:LiveIconStateHidden];
    } else {
        [self.netQualityView updateState:LiveIconStateNetQualityBad];
    }
}

- (void)updateLiveTime:(NSDate *)time {
    [self.timeView updateLiveTime:time];
}

- (void)updateUserModel:(LiveUserModel *)userModel {
    self.streamView.uid = userModel.uid;
}

#pragma mark - Getter

- (LiveTimeView *)timeView {
    if (!_timeView) {
        _timeView = [[LiveTimeView alloc] init];
    }
    return _timeView;
}

- (LiveStateIconView *)netQualityView {
    if (!_netQualityView) {
        _netQualityView = [[LiveStateIconView alloc] initWithState:LiveIconStateHidden];
    }
    return _netQualityView;
}

- (LiveStateIconView *)micView {
    if (!_micView) {
        _micView = [[LiveStateIconView alloc] initWithState:LiveIconStateMic];
        _micView.hidden = YES;
        _micView.alpha = 0;
    }
    return _micView;
}

- (LiveStateIconView *)cameraView {
    if (!_cameraView) {
        _cameraView = [[LiveStateIconView alloc] initWithState:LiveIconStateCamera];
        _cameraView.hidden = YES;
        _cameraView.alpha = 0;
    }
    return _cameraView;
}

- (LiveRTCRenderView *)streamView {
    if (!_streamView) {
        _streamView = [[LiveRTCRenderView alloc] init];
    }
    return _streamView;
}

@end
