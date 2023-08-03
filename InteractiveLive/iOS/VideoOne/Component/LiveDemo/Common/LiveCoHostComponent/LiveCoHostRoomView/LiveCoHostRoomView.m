// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveCoHostRoomView.h"
#import "LiveCoHostRoomItemView.h"
#import "LiveStateIconView.h"
#import "LiveTimeView.h"
#import "GCDTimer.h"

@interface LiveCoHostRoomView ()

@property (nonatomic, strong) LiveCoHostRoomItemView *ownItemView;
@property (nonatomic, strong) LiveCoHostRoomItemView *otherItemView;
@property (nonatomic, strong) LiveTimeView *liveTimeView;
@property (nonatomic, strong) LiveStateIconView *netQualityView;
@property (nonatomic, strong) UIImageView *topTimeBackgroundImageView;
@property (nonatomic, strong) UIView *topTimeView;
@property (nonatomic, strong) UIImageView *topTimeImageView;
@property (nonatomic, strong) UILabel *topTimeLabel;
@property (nonatomic, strong) UIView *renderView;
@property (nonatomic, strong) GCDTimer *timer;
@property (nonatomic, assign) NSInteger second;

@end

@implementation LiveCoHostRoomView

- (instancetype)initWithRenderSize:(CGSize)renderSize
                     roomInfoModel:(LiveRoomInfoModel *)roomInfoModel {
    self = [super init];
    if (self) {
        [self addSubviewConstraints:renderSize];
        [self.liveTimeView updateLiveTime:roomInfoModel.startTime];
        __weak __typeof(self) wself = self;
        [self.timer start:1 block:^(BOOL result) {
            [wself timerMethod];
        }];
        [self.timer suspend];
        
    }
    return self;
}

#pragma mark - Publish Action

- (void)setUserModelList:(NSArray<LiveUserModel *> *)userModelList {
    _userModelList = userModelList;

    LiveUserModel *userModel = nil;
    LiveUserModel *otherModel = nil;
    for (LiveUserModel *tempUserModel in userModelList) {
        if ([tempUserModel.uid isEqualToString:[LocalUserComponent userModel].uid]) {
            userModel = tempUserModel;
        } else {
            otherModel = tempUserModel;
        }
    }
    self.ownItemView.userModel = userModel;
    self.otherItemView.userModel = otherModel;
}

- (void)updateGuestsMic:(BOOL)mic uid:(NSString *)uid {
    if ([uid isEqualToString:[LocalUserComponent userModel].uid]) {
        LiveUserModel *userModel = self.ownItemView.userModel;
        userModel.mic = mic;
        self.ownItemView.userModel = userModel;
        [[LiveRTCManager shareRtc] switchAudioCapture:mic];
    } else {
        LiveUserModel *userModel = self.otherItemView.userModel;
        userModel.mic = mic;
        self.otherItemView.userModel = userModel;
    }
}

- (void)updateGuestsCamera:(BOOL)camera uid:(NSString *)uid {
    if ([uid isEqualToString:[LocalUserComponent userModel].uid]) {
        LiveUserModel *userModel = self.ownItemView.userModel;
        userModel.camera = camera;
        self.ownItemView.userModel = userModel;
        [[LiveRTCManager shareRtc] switchVideoCapture:camera];
    } else {
        LiveUserModel *userModel = self.otherItemView.userModel;
        userModel.camera = camera;
        self.otherItemView.userModel = userModel;
    }
}

- (void)updateNetworkQuality:(LiveNetworkQualityStatus)status uid:(NSString *)uid {
    if ([uid isEqualToString:[LocalUserComponent userModel].uid]) {
        if (status == LiveNetworkQualityStatusGood) {
            [self.netQualityView updateState:LiveIconStateNetQuality];
        } else if (status == LiveNetworkQualityStatusNone) {
            [self.netQualityView updateState:LiveIconStateHidden];
        } else {
            [self.netQualityView updateState:LiveIconStateNetQualityBad];
        }
    }
}

- (void)startTime {    
    [self.timer resume];
}

#pragma mark - Private Action

- (void)timerMethod {
    self.second++;
    
    self.topTimeLabel.text = [NSString stringWithFormat:@"%.02ld:%.02ld", (long)self.second / 60, (long)self.second % 60];
}

- (void)addSubviewConstraints:(CGSize)renderSize {
    [self addSubview:self.liveTimeView];
    [self.liveTimeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20);
        make.left.mas_equalTo(12);
        make.top.mas_equalTo(50 + [DeviceInforTool getStatusBarHight]);
    }];
    
    [self addSubview:self.netQualityView];
    [self.netQualityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20);
        make.left.equalTo(self.liveTimeView.mas_right).offset(6);
        make.centerY.equalTo(self.liveTimeView);
    }];
    
    [self addSubview:self.renderView];
    [self.renderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(renderSize);
        make.left.equalTo(self);
        make.top.equalTo(self.liveTimeView.mas_bottom).offset(14);
    }];
    
    [self.renderView addSubview:self.ownItemView];
    [self.ownItemView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.renderView).multipliedBy(0.5);
        make.left.bottom.height.equalTo(self.renderView);
    }];

    [self.renderView addSubview:self.otherItemView];
    [self.otherItemView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.renderView).multipliedBy(0.5);
        make.right.bottom.height.equalTo(self.renderView);
    }];

    [self.renderView addSubview:self.topTimeBackgroundImageView];
    [self.topTimeBackgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(83, 20));
        make.top.centerX.equalTo(self.renderView);
    }];
    
    [self.renderView addSubview:self.topTimeView];
    [self.topTimeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.renderView);
        make.height.top.equalTo(self.topTimeBackgroundImageView);
    }];
    
    [self.topTimeView addSubview:self.topTimeImageView];
    [self.topTimeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.topTimeView);
        make.left.equalTo(self.topTimeView);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
    
    [self.topTimeView addSubview:self.topTimeLabel];
    [self.topTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topTimeImageView.mas_right).offset(4);
        make.right.equalTo(self.topTimeView);
        make.centerY.equalTo(self.topTimeView);
    }];
}

#pragma mark - Getter

- (UIImageView *)topTimeImageView {
    if (!_topTimeImageView) {
        _topTimeImageView = [[UIImageView alloc] init];
        _topTimeImageView.image = [UIImage imageNamed:@"pk_room_icon" bundleName:HomeBundleName];
    }
    return _topTimeImageView;
}

- (UIView *)topTimeView {
    if (!_topTimeView) {
        _topTimeView = [[UIView alloc] init];
        _topTimeView.backgroundColor = [UIColor clearColor];
    }
    return _topTimeView;
}

- (UILabel *)topTimeLabel {
    if (!_topTimeLabel) {
        _topTimeLabel = [[UILabel alloc] init];
        _topTimeLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
        _topTimeLabel.textColor = [UIColor whiteColor];
        _topTimeLabel.text = @"00:00";
        _topTimeLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _topTimeLabel;
}

- (LiveCoHostRoomItemView *)ownItemView {
    if (!_ownItemView) {
        _ownItemView = [[LiveCoHostRoomItemView alloc] initWithIsOwn:YES];
    }
    return _ownItemView;
}

- (LiveCoHostRoomItemView *)otherItemView {
    if (!_otherItemView) {
        _otherItemView = [[LiveCoHostRoomItemView alloc] initWithIsOwn:NO];
    }
    return _otherItemView;
}

- (UIImageView *)topTimeBackgroundImageView {
    if (!_topTimeBackgroundImageView) {
        _topTimeBackgroundImageView = [[UIImageView alloc] init];
        _topTimeBackgroundImageView.image = [UIImage imageNamed:@"pk_room_bg" bundleName:HomeBundleName];
    }
    return _topTimeBackgroundImageView;
}

- (LiveTimeView *)liveTimeView {
    if (!_liveTimeView) {
        _liveTimeView = [[LiveTimeView alloc] init];
    }
    return _liveTimeView;
}

- (LiveStateIconView *)netQualityView {
    if (!_netQualityView) {
        _netQualityView = [[LiveStateIconView alloc] initWithState:LiveIconStateHidden];
    }
    return _netQualityView;
}

- (UIView *)renderView {
    if (!_renderView) {
        _renderView = [[UIView alloc] init];
    }
    return _renderView;
}

- (GCDTimer *)timer {
    if (!_timer) {
        _timer = [[GCDTimer alloc] init];
    }
    return _timer;
}

@end
