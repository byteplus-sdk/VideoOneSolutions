// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveDuringPKView.h"
#import "LiveDuringPKUserView.h"
#import "LivePKTopView.h"

@interface LiveDuringPKView ()

@property (nonatomic, strong) LiveDuringPKUserView *userPKView;
@property (nonatomic, strong) BaseButton *endButton;
@property (nonatomic, strong) LivePKTopView *topSelectView;
@property (nonatomic, strong) UIImageView *topBackgroundImageView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, copy) NSArray<LiveUserModel *> *userList;

@end

@implementation LiveDuringPKView

- (instancetype)initWithUserList:(NSArray<LiveUserModel *> *)userList {
    self = [super init];
    if (self) {
        self.userList = userList;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];

        [self addSubview:self.topBackgroundImageView];
        [self addSubview:self.backgroundView];

        [self addSubview:self.contentView];
        [self addSubview:self.topSelectView];
        [self addSubview:self.userPKView];
        [self addSubview:self.endButton];

        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.bottom.left.mas_equalTo(0);
            make.height.mas_offset(180 + [DeviceInforTool getVirtualHomeHeight]);
        }];

        [self.topSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.bottom.equalTo(self.contentView.mas_top);
            make.height.mas_equalTo(50);
        }];

        [self.userPKView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(16);
            make.right.mas_equalTo(-16);
            make.height.mas_equalTo(80);
            make.top.equalTo(self.contentView).offset(20);
        }];

        [self.endButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(16);
            make.right.mas_equalTo(-16);
            make.height.mas_equalTo(48);
            make.bottom.equalTo(self.contentView).offset(-([DeviceInforTool getVirtualHomeHeight] + 2));
        }];

        [self.topBackgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self.topSelectView);
            make.height.mas_equalTo(143);
        }];

        [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self);
            make.top.equalTo(self.topBackgroundImageView.mas_bottom);
        }];
    }
    return self;
}

#pragma mark - Private Action

- (void)endButtonAction {
    if (self.clickEndBlock) {
        self.clickEndBlock();
    }
}

#pragma mark - Getter

- (LiveDuringPKUserView *)userPKView {
    if (!_userPKView) {
        _userPKView = [[LiveDuringPKUserView alloc] initWithUserList:self.userList];
    }
    return _userPKView;
}

- (UIImageView *)topBackgroundImageView {
    if (!_topBackgroundImageView) {
        _topBackgroundImageView = [[UIImageView alloc] init];
        _topBackgroundImageView.backgroundColor = [UIColor colorFromHexString:@"#161823"];
        _topBackgroundImageView.image = [UIImage imageNamed:@"pk_bg" bundleName:HomeBundleName];

        CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, 143);
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
        CAShapeLayer *layer = [[CAShapeLayer alloc] init];
        layer.frame = rect;
        layer.path = path.CGPath;
        _topBackgroundImageView.layer.mask = layer;
    }
    return _topBackgroundImageView;
}

- (BaseButton *)endButton {
    if (!_endButton) {
        _endButton = [[BaseButton alloc] init];
        _endButton.backgroundColor = [UIColor colorFromHexString:@"#F53F3F"];
        [_endButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _endButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_endButton addTarget:self action:@selector(endButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _endButton.layer.masksToBounds = YES;
        _endButton.layer.cornerRadius = 4;
        [_endButton setTitle:LocalizedString(@"pk_end") forState:UIControlStateNormal];
    }
    return _endButton;
}

- (LivePKTopView *)topSelectView {
    if (!_topSelectView) {
        _topSelectView = [[LivePKTopView alloc] init];
        _topSelectView.titleStr = LocalizedString(@"during_pk");
    }
    return _topSelectView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor clearColor];
    }
    return _contentView;
}

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = [UIColor colorFromHexString:@"#161823"];
    }
    return _backgroundView;
}

@end
