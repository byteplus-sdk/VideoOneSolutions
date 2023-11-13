// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LivePullRenderView.h"
#import "LiveHostAvatarView.h"
#import "LiveRTCManager.h"
#import "LiveStateIconView.h"

@interface LivePullRenderView ()

@property (nonatomic, strong) UIImageView *emptyImageView;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIImageView *topMaskImageView;
@property (nonatomic, strong) UIView *coHostMaskView;
@property (nonatomic, assign) BOOL hasAddItemLayer;
@property (nonatomic, strong) UILabel *connectingLabel;
@property (nonatomic, assign) BOOL curHostCamera;
@property (nonatomic, assign) BOOL curHostMic;

@end

@implementation LivePullRenderView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubview:self.emptyImageView];
        [self.emptyImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];

        [self addSubview:self.streamView];
        [self.streamView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];

        [self.streamView addSubview:self.coHostMaskView];
        [self.coHostMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.streamView);
        }];

        [self.streamView addSubview:self.topMaskImageView];
        [self.topMaskImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self.streamView);
            make.height.mas_equalTo(42);
        }];

        [self.streamView addSubview:self.iconImageView];
        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(90, 20));
            make.top.centerX.equalTo(self.streamView);
        }];

        [self.iconImageView addSubview:self.connectingLabel];
        [self.connectingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(66);
            make.height.centerX.equalTo(self.iconImageView);
        }];
    }
    return self;
}
- (void)setStatus:(PullRenderStatus)status {
    if (_status != status) {
        _status = status;

        switch (status) {
            case PullRenderStatusNone: {
                [self.streamView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(self);
                }];
                [self updatePKViewHidden:YES];
            } break;

            case PullRenderStatusPK: {
                [self.streamView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(56 + [DeviceInforTool getStatusBarHight]);
                    make.width.equalTo(self);
                    make.height.mas_equalTo(ceilf((SCREEN_WIDTH / 2) * 16 / 9));
                    make.centerX.equalTo(self);
                }];
                [self updatePKViewHidden:NO];
            } break;

            case PullRenderStatusTwoCoHost:
            case PullRenderStatusMultiCoHost: {
                [self.streamView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.right.equalTo(self);
                    make.height.mas_equalTo(ceilf((SCREEN_WIDTH)*16 / 9));
                    make.centerY.mas_equalTo(self);
                }];
                [self updatePKViewHidden:YES];
            } break;

            default:
                break;
        }
        self.streamView.alpha = 0;
        [UIView animateWithDuration:0.3
            delay:0.2
            options:UIViewAnimationOptionCurveEaseInOut
            animations:^{
                self.streamView.alpha = 1;
            } completion:^(BOOL finished) {
                self.streamView.alpha = 1;
            }];
        [self updateHostMic:self.curHostMic
                     camera:self.curHostCamera];
    }
}

#pragma mark - Publish Action

- (void)updateHostMic:(BOOL)mic camera:(BOOL)camera {
    self.curHostCamera = camera;
    self.curHostMic = mic;
    if (self.status == PullRenderStatusNone) {
        // Single anchor & audience mic mode
        self.emptyImageView.hidden = camera;
        self.streamView.hidden = !camera;
    } else {
        // PK mode
        self.emptyImageView.hidden = YES;
        self.streamView.hidden = NO;
    }
}

- (void)setHostUid:(NSString *)hostUid {
    _hostUid = hostUid;
    NSString *imageName = [BaseUserModel getAvatarNameWithUid:hostUid];
    self.emptyImageView.image = [UIImage imageNamed:imageName bundleName:ToolKitBundleName subBundleName:AvatarBundleName];
}

#pragma mark - Private Action

- (void)updatePKViewHidden:(BOOL)isHidden {
    self.iconImageView.hidden = isHidden;
    self.topMaskImageView.hidden = isHidden;
    self.coHostMaskView.hidden = isHidden;
}

#pragma mark - Getter

- (UILabel *)connectingLabel {
    if (!_connectingLabel) {
        _connectingLabel = [[UILabel alloc] init];
        _connectingLabel.font = [UIFont systemFontOfSize:12];
        _connectingLabel.textColor = [UIColor whiteColor];
        _connectingLabel.text = LocalizedString(@"co-host_connecting_message");
        _connectingLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _connectingLabel;
}

- (UIImageView *)emptyImageView {
    if (!_emptyImageView) {
        _emptyImageView = [[UIImageView alloc] init];
        _emptyImageView.contentMode = UIViewContentModeScaleAspectFill;
        _emptyImageView.clipsToBounds = YES;
        _emptyImageView.hidden = YES;
    }
    return _emptyImageView;
}

- (UIView *)streamView {
    if (!_streamView) {
        _streamView = [[UIView alloc] init];
        _streamView.backgroundColor = [UIColor clearColor];
    }
    return _streamView;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.image = [UIImage imageNamed:@"pk_room_bg" bundleName:HomeBundleName];
        _iconImageView.hidden = YES;
    }
    return _iconImageView;
}

- (UIImageView *)topMaskImageView {
    if (!_topMaskImageView) {
        _topMaskImageView = [[UIImageView alloc] init];
        _topMaskImageView.image = [UIImage imageNamed:@"pk_top_mask" bundleName:HomeBundleName];
        _topMaskImageView.hidden = YES;
    }
    return _topMaskImageView;
}

- (UIView *)coHostMaskView {
    if (!_coHostMaskView) {
        _coHostMaskView = [[UIView alloc] init];
        _coHostMaskView.backgroundColor = [UIColor colorFromHexString:@"#30394A"];
        _coHostMaskView.hidden = YES;
    }
    return _coHostMaskView;
}

@end
