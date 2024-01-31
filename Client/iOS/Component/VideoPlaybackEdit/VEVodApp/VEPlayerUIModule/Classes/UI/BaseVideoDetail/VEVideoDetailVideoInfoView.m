//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "VEVideoDetailVideoInfoView.h"
#import "UIColor+String.h"
#import "UIImage+Bundle.h"
#import "VEVideoModel.h"
#import <Masonry/Masonry.h>

@interface VEVideoDetailVideoInfoView ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *infoLabel;

@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation VEVideoDetailVideoInfoView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    [self addSubview:self.titleLabel];
    [self addSubview:self.infoLabel];
    self.avatar = [UIImageView new];
    self.avatar.image = [UIImage imageNamed:@"fake_user"];
    self.nameLabel = [UILabel new];
    self.nameLabel.font = [UIFont systemFontOfSize:16];
    self.nameLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.avatar];
    [self addSubview:self.nameLabel];

    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top);
        make.left.mas_equalTo(self).offset(12);
        make.right.mas_equalTo(self).offset(-12);
    }];

    [self.infoLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom);
        make.left.right.mas_equalTo(self.titleLabel);
    }];

    [self.avatar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.infoLabel.mas_bottom).offset(10);
        make.left.mas_equalTo(self.titleLabel);
        make.size.equalTo(@(CGSizeMake(32, 32)));
        make.bottom.equalTo(self).offset(-8);
    }];
    self.avatar.layer.cornerRadius = 16;
    self.avatar.layer.masksToBounds = YES;

    [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.avatar.mas_centerY);
        make.left.mas_equalTo(self.avatar.mas_right).offset(10);
    }];
}

- (void)updateModel:(VEVideoModel *)videoModel {
    self.titleLabel.text = videoModel.title;
    self.infoLabel.text = [NSString stringWithFormat:@"%@ · %@", [videoModel playTimeToString], videoModel.createTime];
    self.avatar.image = [UIImage avatarImageForUid:videoModel.uid];
    self.nameLabel.text = videoModel.userName;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:18 weight:bold];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        _infoLabel.textColor = [UIColor colorFromRGBHexString:@"#73767A"];
        _infoLabel.numberOfLines = 0;
    }
    return _infoLabel;
}

@end
