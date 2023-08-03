// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveGiftTrackView.h"

@interface LiveGiftTrackView ()

@property (nonatomic, strong) UIImageView *trackContentView;

@property (nonatomic, strong) UIImageView *userAvatarView;

@property (nonatomic, strong) UILabel *userNameView;

@property (nonatomic, strong) UILabel *giftMessageView;

@property (nonatomic, strong) UIImageView *giftIconView;

@property (nonatomic, strong) UIView *giftSendCountView;

@property (nonatomic, strong) UILabel *sendNumView;


@end

@implementation LiveGiftTrackView

- (instancetype)initWithModel:(LiveGiftEffectModel *)model withDuration:(float)duration {
    self = [super init];
    if(self) {
        [self setConstraints];
        self.duration = duration;
        self.userAvatarView.image = [UIImage imageNamed:model.userAvatar
                                             bundleName:HomeBundleName
                                          subBundleName:AvatarBundleName];
        self.userNameView.text = model.userName;
        self.giftMessageView.text = model.sendMessage;
        self.giftIconView.image = [UIImage imageNamed:model.giftIcon bundleName:HomeBundleName];
        if(model.count > 0) {
            self.sendNumView.text = [NSString stringWithFormat:@"%ld", model.count];
        } else {
            self.sendNumView.text = @"";
        }
    }
    return self;
}

- (void) setConstraints {
    [self addSubview:self.trackContentView];
    [self.trackContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(174, 44));
        make.top.mas_equalTo(self);
        make.left.mas_equalTo(self);
    }];
    
    [self.trackContentView addSubview:self.userAvatarView];
    [self.userAvatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(36, 36));
        make.left.mas_equalTo(self.trackContentView).offset(4);
        make.top.mas_equalTo(self.trackContentView).offset(4);
    }];
    
    [self.trackContentView addSubview:self.userNameView];
    [self.userNameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(82, 20));
        make.top.mas_equalTo(self.trackContentView).offset(5);
        make.left.mas_equalTo(self.trackContentView).offset(44);
    }];
    
    [self.trackContentView addSubview:self.giftMessageView];
    [self.giftMessageView  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(84, 16));
        make.bottom.mas_equalTo(self).offset(-4);
        make.left.mas_equalTo(self).offset(44);
    }];
    
    [self.trackContentView addSubview:self.giftIconView];
    [self.giftIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(44, 44));
        make.top.mas_equalTo(self.trackContentView);
        make.right.mas_equalTo(self.trackContentView);
    }];
    
    [self addSubview:self.giftSendCountView];
    [self.giftSendCountView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(44, 28));
        make.right.mas_equalTo(self);
        make.bottom.mas_equalTo(self);
    }];

    [self.giftSendCountView addSubview:self.sendNumView];
    [self.sendNumView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(32, 28));
        make.left.mas_equalTo(self.giftSendCountView).offset(12);
        make.bottom.mas_equalTo(self.giftSendCountView).offset(-2);
    }];
}

- (void)decrease:(float)delta {
    self.duration = self.duration - delta;
}

#pragma mark - Getter

- (UIImageView *)userAvatarView {
    if(!_userAvatarView) {
        _userAvatarView = [[UIImageView alloc] init];
        _userAvatarView.layer.cornerRadius = 18;
        _userAvatarView.layer.masksToBounds = YES;
    }
    return _userAvatarView;
}

- (UILabel *)userNameView {
    if(!_userNameView) {
        _userNameView = [[UILabel alloc] init];
        _userNameView.textColor = [UIColor colorFromRGBHexString:@"#FFFFFF"];
        _userNameView.font = [UIFont systemFontOfSize:14 weight:500];
    }
    return _userNameView;
}

- (UILabel *)giftMessageView {
    if(!_giftMessageView) {
        _giftMessageView = [[UILabel alloc] init];
        _giftMessageView.textColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.75 * 255];
        _giftMessageView.font = [UIFont systemFontOfSize:12];
    }
    return _giftMessageView;
}

- (UIImageView *)giftIconView {
    if(!_giftIconView) {
        _giftIconView = [[UIImageView alloc] init];
    }
    
    return _giftIconView;
}

- (UIView *)giftSendCountView {
    if(!_giftSendCountView) {
        _giftSendCountView  = [[UIView alloc] init];
        
        UILabel *tempLabel = [[UILabel alloc] init];
        tempLabel.textColor = [UIColor colorFromRGBHexString:@"#FFFFFF"];
        tempLabel.font = [UIFont systemFontOfSize:18 weight:700];
        tempLabel.text = @"x";
        [_giftSendCountView addSubview:tempLabel];
        [tempLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(10, 18));
            make.left.mas_equalTo(_giftSendCountView);
            make.bottom.mas_equalTo(_giftSendCountView);
        }];
        tempLabel.transform = CGAffineTransformMake(1, 0, tanf(-10 * (CGFloat)M_PI / 180), 1, 0, 0);
    }
    return _giftSendCountView;
}

- (UIImageView *)trackContentView {
    if(!_trackContentView) {
        _trackContentView = [[UIImageView alloc] init];
        _trackContentView.image = [UIImage imageNamed:@"gift_track_background" bundleName:HomeBundleName];
        _trackContentView.layer.cornerRadius = 24;
        _trackContentView.layer.masksToBounds = YES;
    }
    return _trackContentView;
}

- (UILabel *)sendNumView {
    if(!_sendNumView) {
        _sendNumView = [[UILabel alloc] init];
        _sendNumView.textColor = [UIColor colorFromRGBHexString:@"#FFFFFF"];
        _sendNumView.font = [UIFont systemFontOfSize:28 weight:700 ];
        _sendNumView.transform = CGAffineTransformMake(1, 0, tanf(-10 * (CGFloat)M_PI / 180), 1, 0, 0);
    }
    return  _sendNumView;
}


@end

