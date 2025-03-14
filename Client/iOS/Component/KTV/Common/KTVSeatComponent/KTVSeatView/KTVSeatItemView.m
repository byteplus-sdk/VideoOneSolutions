// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "KTVSeatItemView.h"
#import "KTVSeatModel.h"
#import "KTVSongModel.h"

typedef NS_ENUM(NSInteger, KTVSeatItemStatue) {
    KTVSeatItemStatueNull = 0,
    KTVSeatItemStatueLock,
    KTVSeatItemStatueUser,
    KTVSeatItemStatueUserAndSpeak,
    KTVSeatItemStatueMuteMic,
};

@interface KTVSeatItemView ()

@property (nonatomic, strong) UIView *animationView;
@property (nonatomic, strong) UIImageView *avatarBgImageView;
@property (nonatomic, strong) UILabel *userNameLabel;
@property (nonatomic, strong) UIImageView *centerImageView;
@property (nonatomic, strong) UIView *itemMaskView;
@property (nonatomic, strong) UIImageView *singerImageView;

@property (nonatomic, strong) KTVSongModel *songModel;

@end

@implementation KTVSeatItemView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubview:self.animationView];
        [self addSubview:self.avatarBgImageView];
        [self addSubview:self.userNameLabel];
        [self addSubview:self.itemMaskView];
        [self addSubview:self.centerImageView];
        [self addSubview:self.singerImageView];
        
        [self.avatarBgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(32, 32));
            make.top.mas_equalTo(5);
            make.centerX.equalTo(self);
        }];
        
        [self.itemMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
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
        
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)setSeatModel:(KTVSeatModel *)seatModel {
    _seatModel = seatModel;
    if (seatModel) {
        if (seatModel.status == 1) {
            //unlock
            if (NOEmptyStr(seatModel.userModel.uid)) {
                if (seatModel.userModel.mic == KTVUserMicOn) {
                    if (seatModel.userModel.isSpeak) {
                        [self updateUI:KTVSeatItemStatueUserAndSpeak seatModel:seatModel];
                    } else {
                        [self updateUI:KTVSeatItemStatueUser seatModel:seatModel];
                    }
                } else {
                    [self updateUI:KTVSeatItemStatueMuteMic seatModel:seatModel];
                }
            } else {
                [self updateUI:KTVSeatItemStatueNull seatModel:seatModel];
            }
        } else {
            //lock
            [self updateUI:KTVSeatItemStatueLock seatModel:seatModel];
        }
    } else {
        [self updateUI:KTVSeatItemStatueNull seatModel:seatModel];
    }
}

- (void)updateUI:(KTVSeatItemStatue)statue
       seatModel:(KTVSeatModel *)seatModel {
    self.animationView.hidden = YES;
    self.itemMaskView.hidden = YES;
    
    if (statue == KTVSeatItemStatueNull) {
        self.avatarBgImageView.image = [UIImage imageNamed:@"seat_bg_null" bundleName:HomeBundleName];
        self.centerImageView.image = [UIImage imageNamed:@"seat_null" bundleName:HomeBundleName];
        self.centerImageView.hidden = NO;
        self.userNameLabel.text = [NSString stringWithFormat:@"%ld", (long)(seatModel.index)];
    } else if (statue == KTVSeatItemStatueLock) {
        self.avatarBgImageView.image = [UIImage imageNamed:@"seat_bg_null" bundleName:HomeBundleName];
        self.centerImageView.image = [UIImage imageNamed:@"KTV_seat_lock" bundleName:HomeBundleName];
        self.centerImageView.hidden = NO;
        self.userNameLabel.text = [NSString stringWithFormat:@"%ld", (long)(seatModel.index)];
    } else if (statue == KTVSeatItemStatueUser) {
        self.avatarBgImageView.image = [UIImage imageNamed:seatModel.userModel.avatarName
                                                bundleName:ToolKitBundleName
                                             subBundleName:AvatarBundleName];
        self.centerImageView.hidden = YES;
    } else if (statue == KTVSeatItemStatueUserAndSpeak) {
        self.avatarBgImageView.image = [UIImage imageNamed:seatModel.userModel.avatarName
                                                bundleName:ToolKitBundleName
                                             subBundleName:AvatarBundleName];
        self.centerImageView.hidden = YES;
        self.animationView.hidden = NO;
    } else if (statue == KTVSeatItemStatueMuteMic) {
        self.avatarBgImageView.image = [UIImage imageNamed:seatModel.userModel.avatarName
                                                bundleName:ToolKitBundleName
                                             subBundleName:AvatarBundleName];
        self.centerImageView.image = [UIImage imageNamed:@"seat_mic_s" bundleName:HomeBundleName];
        self.centerImageView.hidden = NO;
        self.itemMaskView.hidden = NO;
    } else {
        //error
    }
    [self updateUserNameUI];
}

- (void)updateUserNameUI {
    if (NOEmptyStr(_seatModel.userModel.uid)) {
        if ([_seatModel.userModel.uid isEqualToString:_songModel.pickedUserID]) {
            self.singerImageView.hidden = NO;
        } else {
            self.singerImageView.hidden = YES;
        }
        self.userNameLabel.text = _seatModel.userModel.name;
    } else {
        self.singerImageView.hidden = YES;
    }
}

- (void)updateCurrentSongModel:(KTVSongModel *)songModel {
    self.songModel = songModel;
    [self updateUserNameUI];
}

- (void)tapAction {
    if (self.clickBlock) {
        self.clickBlock(self.seatModel);
    }
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

- (UIView *)itemMaskView {
    if (!_itemMaskView) {
        _itemMaskView = [[UIView alloc] init];
        _itemMaskView.backgroundColor = [UIColor colorFromRGBHexString:@"#040404" andAlpha:0.8 * 255];
        _itemMaskView.layer.cornerRadius = 16;
        _itemMaskView.layer.masksToBounds = YES;
        _itemMaskView.hidden = YES;
    }
    return _itemMaskView;
}

- (UIImageView *)centerImageView {
    if (!_centerImageView) {
        _centerImageView = [[UIImageView alloc] init];
    }
    return _centerImageView;
}

@end
