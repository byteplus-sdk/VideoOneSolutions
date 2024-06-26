// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "KTVCreateRoomTipView.h"

@interface KTVCreateRoomTipView ()

@property (nonatomic, strong) UIImageView *tipImageView;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UIView *contentView;

@end

@implementation KTVCreateRoomTipView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];

        [self addSubview:self.contentView];
        [self addSubview:self.tipLabel];
        [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(26);
            make.top.mas_equalTo(6);
            make.right.mas_lessThanOrEqualTo(-6);
        }];

        [self addSubview:self.tipImageView];
        [self.tipImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(8);
            make.width.height.mas_equalTo(12);
            make.top.mas_equalTo(8);
        }];

        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.top.equalTo(self.tipLabel).offset(-6);
            make.bottom.equalTo(self.tipLabel).offset(6);
        }];
    }
    return self;
}

- (void)setMessage:(NSString *)message {
    _message = message;

    self.tipLabel.text = message;

    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView);
    }];
}

#pragma mark - getter

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.font = [UIFont systemFontOfSize:12];
        _tipLabel.numberOfLines = 0;
        _tipLabel.textColor = [UIColor whiteColor];
    }
    return _tipLabel;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor colorFromRGBHexString:@"#FDFDFD" andAlpha:0.1 * 255];
        _contentView.layer.cornerRadius = 10;
        _contentView.layer.masksToBounds = YES;
    }
    return _contentView;
}

- (UIImageView *)tipImageView {
    if (!_tipImageView) {
        _tipImageView = [[UIImageView alloc] init];
        _tipImageView.image = [UIImage imageNamed:@"voicechar_waring" bundleName:HomeBundleName];
    }
    return _tipImageView;
}

@end
