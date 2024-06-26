// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveInvitePKView.h"
#import "GCDTimer.h"
#import <ToolKit/ToolKit.h>

@interface LiveInvitePKView ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) BaseButton *rejectButton;
@property (nonatomic, strong) BaseButton *agreeButton;
@property (nonatomic, strong) UIView *fromeView;
@property (nonatomic, strong) UILabel *fromeNameLabel;
@property (nonatomic, strong) UIImageView *fromeAvatarImageView;
@property (nonatomic, strong) GCDTimer *timer;

@end

@implementation LiveInvitePKView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubview:self.contentView];
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.messageLabel];
        [self.contentView addSubview:self.rejectButton];
        [self.contentView addSubview:self.agreeButton];
        [self.contentView addSubview:self.fromeView];
        [self.fromeView addSubview:self.fromeNameLabel];
        [self.fromeView addSubview:self.fromeAvatarImageView];

        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(322, 401));
            make.center.equalTo(self);
        }];

        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];

        [self.fromeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView);
            make.top.mas_equalTo(208);
            make.height.mas_equalTo(32);
        }];

        [self.fromeAvatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(32, 32));
            make.left.equalTo(self.fromeView);
            make.top.equalTo(self.fromeView);
        }];

        [self.fromeNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.fromeAvatarImageView.mas_right).offset(8);
            make.right.equalTo(self.fromeView);
            make.centerY.equalTo(self.fromeView);
        }];

        [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView);
            make.top.equalTo(self.fromeAvatarImageView.mas_bottom).offset(8);
        }];

        [self.rejectButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(136, 44));
            make.left.mas_equalTo(16);
            make.bottom.equalTo(self.contentView).offset(-45);
        }];

        [self.agreeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(136, 44));
            make.right.mas_equalTo(-16);
            make.bottom.equalTo(self.contentView).offset(-45);
        }];
    }
    return self;
}

- (void)dismissDelayAfterTenSeconds {
    __weak __typeof(self) wself = self;
    dispatch_after(dispatch_walltime(NULL, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        VOLogI(VOInteractiveLive,@"10s is over");
        if (wself && wself.superview) {
            [wself rejectButtonAction];
        }
    });
}

#pragma mark - Publish Action

- (void)setFromUserModel:(LiveUserModel *)fromUserModel {
    _fromUserModel = fromUserModel;

    self.fromeAvatarImageView.image = [UIImage imageNamed:fromUserModel.avatarName bundleName:ToolKitBundleName subBundleName:AvatarBundleName];
    self.fromeNameLabel.text = [NSString stringWithFormat:LocalizedString(@"from_%@"), fromUserModel.name];
}

#pragma mark - Private Action

- (void)rejectButtonAction {
    if (self.clickRejectBlcok) {
        self.clickRejectBlcok();
    }
}

- (void)agreeButtonAction {
    if (self.clickAgreeBlcok) {
        self.clickAgreeBlcok();
    }
}

#pragma mark - Getter

- (GCDTimer *)timer {
    if (!_timer) {
        _timer = [[GCDTimer alloc] init];
    }
    return _timer;
}

- (UIView *)fromeView {
    if (!_fromeView) {
        _fromeView = [[UIView alloc] init];
        _fromeView.backgroundColor = [UIColor clearColor];
    }
    return _fromeView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor colorFromHexString:@"#001741"];
        _contentView.layer.cornerRadius = 8;
        _contentView.layer.masksToBounds = YES;
    }
    return _contentView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.image = [UIImage imageNamed:@"pk_invite" bundleName:HomeBundleName];
    }
    return _imageView;
}

- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.textColor = [UIColor whiteColor];
        _messageLabel.text = LocalizedString(@"pk_invitation_title");
        _messageLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
    }
    return _messageLabel;
}

- (UILabel *)fromeNameLabel {
    if (!_fromeNameLabel) {
        _fromeNameLabel = [[UILabel alloc] init];
        _fromeNameLabel.textColor = [UIColor whiteColor];
        _fromeNameLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    }
    return _fromeNameLabel;
}

- (UIImageView *)fromeAvatarImageView {
    if (!_fromeAvatarImageView) {
        _fromeAvatarImageView = [[UIImageView alloc] init];
        _fromeAvatarImageView.layer.cornerRadius = 32 / 2;
        _fromeAvatarImageView.layer.masksToBounds = YES;
        _fromeAvatarImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        _fromeAvatarImageView.layer.borderWidth = 2;
    }
    return _fromeAvatarImageView;
}

- (BaseButton *)rejectButton {
    if (!_rejectButton) {
        _rejectButton = [[BaseButton alloc] init];
        CGRect rect = CGRectMake(0, 0, 136, 44);
        [_rejectButton setTitle:LocalizedString(@"reject") forState:UIControlStateNormal];
        _rejectButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
        [_rejectButton addTarget:self action:@selector(rejectButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_rejectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(4, 4)];
        CAShapeLayer *layer = [[CAShapeLayer alloc] init];
        layer.lineWidth = 2;
        layer.strokeColor = [UIColor whiteColor].CGColor;
        layer.frame = rect;
        layer.fillColor = [UIColor clearColor].CGColor;
        layer.path = path.CGPath;
        [_rejectButton.layer addSublayer:layer];
    }
    return _rejectButton;
}

- (BaseButton *)agreeButton {
    if (!_agreeButton) {
        _agreeButton = [[BaseButton alloc] init];
        [_agreeButton addTarget:self action:@selector(agreeButtonAction) forControlEvents:UIControlEventTouchUpInside];

        _agreeButton.layer.cornerRadius = 4;
        _agreeButton.layer.masksToBounds = YES;
        CGRect rect = CGRectMake(0, 0, 136, 44);
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = rect;
        gradient.colors = @[(id)[UIColor colorFromHexString:@"#FF1764"].CGColor,
                            (id)[UIColor colorFromHexString:@"#ED3596"].CGColor];
        gradient.startPoint = CGPointMake(0, 0.5);
        gradient.endPoint = CGPointMake(1, 0.5);
        [_agreeButton.layer addSublayer:gradient];

        UILabel *label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        label.frame = rect;
        label.text = LocalizedString(@"agree");
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
        label.userInteractionEnabled = NO;
        [_agreeButton addSubview:label];
    }
    return _agreeButton;
}

@end
