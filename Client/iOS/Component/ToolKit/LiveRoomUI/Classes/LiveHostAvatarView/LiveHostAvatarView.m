// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveHostAvatarView.h"
#import <ToolKit/ToolKit.h>
#import <Masonry/Masonry.h>

@interface LiveHostAvatarView ()

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation LiveHostAvatarView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.avatarView];
        [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(32, 32));
            make.left.mas_equalTo(2);
            make.centerY.equalTo(self);
        }];

        [self addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(self.avatarView.mas_right).offset(8);
        }];

        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.titleLabel.mas_right).offset(8);
        }];
    }
    return self;
}

- (void)setAvatarName:(NSString *)avatarName {
    _avatarName = avatarName;
    self.avatarView.image = [UIImage imageNamed:avatarName bundleName:ToolKitBundleName subBundleName:AvatarBundleName];
}

- (void)setUserName:(NSString *)userName {
    _userName = userName;
    self.titleLabel.text = userName;
}

#pragma mark - Getter

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
    }
    return _titleLabel;
}

- (UIImageView *)avatarView {
    if (_avatarView == nil) {
        _avatarView = [[UIImageView alloc] init];
        _avatarView.layer.masksToBounds = YES;
        _avatarView.layer.cornerRadius = 16;
    }
    return _avatarView;
}

@end
