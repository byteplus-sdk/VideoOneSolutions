// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "KTVHostAvatarView.h"
#import "GCDTimer.h"
#import "KTVSongModel.h"

@interface KTVHostAvatarView ()

@property (nonatomic, strong) UIView *animationView;
@property (nonatomic, strong) UIImageView *avatarBgImageView;
@property (nonatomic, strong) UILabel *userNameLabel;
@property (nonatomic, strong) UIImageView *centerImageView;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIImageView *singerImageView;

@property (nonatomic, strong) GCDTimer *timer;
@property (nonatomic, strong) NSNumber *volume;
@property (nonatomic, strong) KTVSongModel *songModel;

@end

@implementation KTVHostAvatarView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.clipsToBounds = NO;
        
        [self addSubviewAndConstraints];
        __weak __typeof(self) wself = self;
        [self.timer start:1.1 block:^(BOOL result) {
            [wself timerMethod];
        }];
    }
    return self;
}

- (void)setUserModel:(KTVUserModel *)userModel {
    _userModel = userModel;
    if (userModel) {
        self.avatarBgImageView.image = [UIImage imageNamed:userModel.avatarName
                                                bundleName:ToolKitBundleName
                                             subBundleName:AvatarBundleName];
        
        if (userModel.mic) {
            self.centerImageView.hidden = YES;
            self.maskView.hidden = YES;
            self.animationView.hidden = userModel.isSpeak ? NO : YES;
        } else {
            self.centerImageView.hidden = NO;
            self.maskView.hidden = NO;
            self.animationView.hidden = YES;
        }
        [self updateUserNameUI];
    }
}

- (void)updateUserNameUI {
    if (_userModel) {
        if ([_songModel.pickedUserID isEqualToString:_userModel.uid]) {
            self.singerImageView.hidden = NO;
        } else {
            self.singerImageView.hidden = YES;
        }
        self.userNameLabel.text = _userModel.name;
    }
}

- (void)updateHostVolume:(NSNumber *)volume {
    _volume = volume;
}

- (void)updateHostMic:(KTVUserMic)userMic {
    KTVUserModel *tempModel = self.userModel;
    tempModel.mic = userMic;
    self.userModel = tempModel;
}

- (void)updateCurrentSongModel:(KTVSongModel *)songModel {
    self.songModel = songModel;
    [self updateUserNameUI];
}

#pragma mark - Private Action

- (void)timerMethod {
    KTVUserModel *tempModel = self.userModel;
    tempModel.volume = _volume.floatValue;
    self.userModel = tempModel;
}

- (void)addSubviewAndConstraints {
    [self addSubview:self.animationView];
    [self addSubview:self.avatarBgImageView];
    [self addSubview:self.userNameLabel];
    [self addSubview:self.maskView];
    [self addSubview:self.centerImageView];
    [self addSubview:self.singerImageView];
    
    [self.avatarBgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(32, 32));
        make.top.mas_equalTo(5);
        make.centerX.equalTo(self);
    }];
    
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.avatarBgImageView);
    }];
    
    [self.animationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.avatarBgImageView);
        make.width.height.mas_equalTo(42);
    }];
    
    [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.bottom.equalTo(self);
        make.left.greaterThanOrEqualTo(self);
        make.right.lessThanOrEqualTo(self);
    }];
    
    [self.centerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(12, 12));
        make.center.equalTo(self.avatarBgImageView);
    }];
    
    [self.singerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(37, 14));
        make.centerX.equalTo(self.avatarBgImageView.mas_centerX);
        make.bottom.equalTo(self.avatarBgImageView.mas_top).offset(-2);
    }];
}

- (void)addWiggleAnimation:(UIView *)view {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    animation.values = @[@(0.81), @(1.0), @(1.0)];
    animation.keyTimes = @[@(0), @(0.27), @(1.0)];
    
    CAKeyframeAnimation *animation2 = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    animation2.values = @[@(0), @(0.2), @(0.4), @(0.2)];
    animation2.keyTimes = @[@(0), @(0.27), @(0.27), @(1.0)];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[animation,animation2];
    group.duration = 1.1;
    group.repeatCount = MAXFLOAT;
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    [view.layer addAnimation:group forKey:@"transformKey"];
}

#pragma mark - getter

- (UIImageView *)singerImageView {
    if (!_singerImageView) {
        _singerImageView = [[UIImageView alloc] init];
        _singerImageView.image = [UIImage imageNamed:@"seat_singer" bundleName:HomeBundleName];
        _singerImageView.hidden = YES;
    }
    return _singerImageView;
}

- (UIView *)animationView {
    if (!_animationView) {
        _animationView = [[UIView alloc] init];
        _animationView.backgroundColor = [UIColor colorFromRGBHexString:@"#F93D89"];
        _animationView.layer.cornerRadius = 42 / 2;
        _animationView.layer.masksToBounds = YES;
        _animationView.hidden = YES;
        [self addWiggleAnimation:_animationView];
    }
    return _animationView;
}

- (UIImageView *)avatarBgImageView {
    if (!_avatarBgImageView) {
        _avatarBgImageView = [[UIImageView alloc] init];
        _avatarBgImageView.image = [UIImage imageNamed:@"KTV_small_bg" bundleName:HomeBundleName];
        _avatarBgImageView.layer.cornerRadius = 32 / 2;
        _avatarBgImageView.layer.masksToBounds = YES;
    }
    return _avatarBgImageView;
}

- (UILabel *)userNameLabel {
    if (!_userNameLabel) {
        _userNameLabel = [[UILabel alloc] init];
        _userNameLabel.textColor = [UIColor colorFromHexString:@"#F2F3F5"];
        _userNameLabel.font = [UIFont systemFontOfSize:12];
    }
    return _userNameLabel;
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] init];
        _maskView.backgroundColor = [UIColor colorFromRGBHexString:@"#040404" andAlpha:0.8 * 255];
        _maskView.layer.cornerRadius = 16;
        _maskView.layer.masksToBounds = YES;
        _maskView.hidden = YES;
    }
    return _maskView;
}

- (UIImageView *)centerImageView {
    if (!_centerImageView) {
        _centerImageView = [[UIImageView alloc] init];
        _centerImageView.image = [UIImage imageNamed:@"seat_mic_s" bundleName:HomeBundleName];
        _centerImageView.hidden = YES;
    }
    return _centerImageView;
}

- (GCDTimer *)timer {
    if (!_timer) {
        _timer = [[GCDTimer alloc] init];
    }
    return _timer;
}

@end
