// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "AvatarView.h"
#import "Masonry.h"
#import "ToolKit.h"
#import <SDWebImage/SDWebImage.h>

@interface AvatarView ()

@property (nonatomic, strong) UILabel *avatarLabel;
@property (nonatomic, strong) UIImageView *avatarIconView;

@end

@implementation AvatarView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubview:self.avatarIconView];
        [self.avatarIconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.centerX.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(80, 80));
        }];

        [self addSubview:self.avatarLabel];
        [self.avatarLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.avatarIconView.mas_bottom).mas_offset(10);
            make.left.right.bottom.equalTo(self);
        }];
    }
    return self;
}

- (void)setFontSize:(NSInteger)fontSize {
    _fontSize = fontSize;

    self.avatarLabel.font = [UIFont systemFontOfSize:fontSize weight:UIFontWeightMedium];
}

- (void)setText:(NSString *)text {
    _text = text.copy;
    self.avatarLabel.text = text;
}

- (void)setIconUrl:(NSString *)iconUrl {
    if (NOEmptyStr(iconUrl) && ![_iconUrl isEqualToString:iconUrl]) {
        _iconUrl = iconUrl.copy;
        if (_iconUrl != nil && [_iconUrl hasPrefix:@"http"]) {
            [self.avatarIconView sd_setImageWithURL:[NSURL URLWithString:iconUrl] placeholderImage:nil];
        } else {
            self.avatarIconView.image = [UIImage imageNamed:iconUrl bundleName:ToolKitBundleName subBundleName:AvatarBundleName];
            ;
        }
    }
}

#pragma mark - Getter

- (UIImageView *)avatarIconView {
    if (!_avatarIconView) {
        _avatarIconView = [[UIImageView alloc] init];
        _avatarIconView.layer.cornerRadius = 40;
        _avatarIconView.clipsToBounds = YES;
        _avatarIconView.contentMode = UIViewContentModeScaleAspectFit;
        _avatarIconView.backgroundColor = [UIColor colorFromHexString:@"#D9D9D9"];
    }
    return _avatarIconView;
}

- (UILabel *)avatarLabel {
    if (!_avatarLabel) {
        _avatarLabel = [[UILabel alloc] init];
        _avatarLabel.textAlignment = NSTextAlignmentCenter;
        _avatarLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _avatarLabel.textColor = [UIColor colorFromHexString:@"#1D2129"];
        _avatarLabel.font = [UIFont fontWithName:@"Roboto" size:20] ?: [UIFont systemFontOfSize:20 weight:700];
    }
    return _avatarLabel;
}

@end
