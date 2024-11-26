// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveCoHostRoomItemView.h"
#import "LiveHostAvatarView.h"
#import "LiveRTCRenderView.h"
#import "LiveStateIconView.h"

@interface LiveCoHostRoomItemView ()

@property (nonatomic, strong) UIImageView *bgMaskImageView;
@property (nonatomic, strong) UIImageView *topMaskImageView;
@property (nonatomic, strong) LiveRTCRenderView *renderView;
@property (nonatomic, strong) BaseButton *micButton;
@property (nonatomic, strong) LiveHostAvatarView *hostAvatarView;
@property (nonatomic, strong) LiveStateIconView *micView;
@property (nonatomic, strong) LiveStateIconView *cameraView;

@property (nonatomic, assign) BOOL hasAddItemLayer;
@property (nonatomic, assign) BOOL muteRemoteAudio;

@end

@implementation LiveCoHostRoomItemView

- (instancetype)initWithIsOwn:(BOOL)isOwn {
    self = [super init];
    if (self) {
        _muteRemoteAudio = NO;

        [self addSubview:self.bgMaskImageView];
        [self.bgMaskImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];

        [self addSubview:self.renderView];
        [self.renderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];

        [self addSubview:self.topMaskImageView];
        [self.topMaskImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self);
            make.height.mas_equalTo(42);
        }];

        [self addSubview:self.micButton];
        [self.micButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(34, 34));
            make.left.mas_equalTo(8);
            make.bottom.mas_equalTo(-8);
        }];

        [self addSubview:self.hostAvatarView];
        [self.hostAvatarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(34);
            make.right.equalTo(self).offset(-8);
            make.bottom.equalTo(self).offset(-8);
            make.left.mas_greaterThanOrEqualTo(self.micButton.mas_right).offset(8);
        }];

        [self addSubview:self.micView];
        [self.micView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(17);
            if (isOwn) {
                make.left.mas_equalTo(7);
            } else {
                make.right.mas_equalTo(-7);
            }
            make.top.mas_equalTo(25);
        }];

        [self addSubview:self.cameraView];
        [self.cameraView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(17);
            if (isOwn) {
                make.left.mas_equalTo(7);
            } else {
                make.right.mas_equalTo(-7);
            }
            make.top.mas_equalTo(46);
        }];

        if (isOwn) {
            self.hostAvatarView.hidden = YES;
            self.micButton.hidden = YES;
        } else {
            self.hostAvatarView.hidden = NO;
            self.micButton.hidden = YES;
        }
    }
    return self;
}

#pragma mark - Publish Action

- (void)setUserModel:(LiveUserModel *)userModel {
    _userModel = userModel;

    self.hostAvatarView.avatarName = userModel.avatarName;
    self.hostAvatarView.userName = userModel.user_name;

    self.micView.hidden = userModel.mic;
    self.cameraView.hidden = userModel.camera;
    self.renderView.uid = userModel.uid;
    self.renderView.isCamera = userModel.camera;

    [self.cameraView mas_updateConstraints:^(MASConstraintMaker *make) {
        if (!self.micView.hidden) {
            make.top.mas_equalTo(46);
        } else {
            make.top.mas_equalTo(25);
        }
    }];
}

#pragma mark - Private Action

- (void)micButtonAction {
    _muteRemoteAudio = !_muteRemoteAudio;

    if (_muteRemoteAudio) {
        [_micButton setImage:[UIImage imageNamed:@"InteractiveLive_mic_un" bundleName:HomeBundleName] forState:UIControlStateNormal];
    } else {
        [_micButton setImage:[UIImage imageNamed:@"InteractiveLive_mic" bundleName:HomeBundleName] forState:UIControlStateNormal];
    }
}

#pragma mark - Getter

- (LiveHostAvatarView *)hostAvatarView {
    if (!_hostAvatarView) {
        _hostAvatarView = [[LiveHostAvatarView alloc] init];
        _hostAvatarView.backgroundColor = [UIColor colorFromRGBHexString:@"#000000" andAlpha:0.2 * 255];
        _hostAvatarView.layer.cornerRadius = 18;
        _hostAvatarView.layer.masksToBounds = YES;
    }
    return _hostAvatarView;
}

- (UIImageView *)topMaskImageView {
    if (!_topMaskImageView) {
        _topMaskImageView = [[UIImageView alloc] init];
        _topMaskImageView.image = [UIImage imageNamed:@"pk_top_mask" bundleName:HomeBundleName];
    }
    return _topMaskImageView;
}

- (UIImageView *)bgMaskImageView {
    if (!_bgMaskImageView) {
        _bgMaskImageView = [[UIImageView alloc] init];
        _bgMaskImageView.image = [UIImage imageNamed:@"InteractiveLive_bg" bundleName:HomeBundleName];
    }
    return _bgMaskImageView;
}

- (BaseButton *)micButton {
    if (!_micButton) {
        _micButton = [[BaseButton alloc] init];
        [_micButton setImage:[UIImage imageNamed:@"InteractiveLive_mic" bundleName:HomeBundleName] forState:UIControlStateNormal];
        [_micButton addTarget:self action:@selector(micButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _micButton.backgroundColor = [UIColor clearColor];
        _micButton.hidden = YES;
    }
    return _micButton;
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

- (LiveRTCRenderView *)renderView {
    if (!_renderView) {
        _renderView = [[LiveRTCRenderView alloc] init];
    }
    return _renderView;
}

@end
