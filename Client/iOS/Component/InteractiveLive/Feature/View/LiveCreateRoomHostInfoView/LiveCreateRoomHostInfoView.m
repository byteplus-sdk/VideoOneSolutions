// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveCreateRoomHostInfoView.h"

@interface LiveCreateRoomHostInfoView ()

@property (nonatomic, strong) UIImageView *hostAvatar;

@property (nonatomic, strong) UILabel *labelView;

@end

@implementation LiveCreateRoomHostInfoView

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *userId = [LocalUserComponent userModel].uid;
        self.hostAvatar.image = [UIImage imageNamed:[LiveUserModel getAvatarNameWithUid:userId] bundleName:ToolKitBundleName subBundleName:AvatarBundleName];
        self.labelView.text = [NSString stringWithFormat:LocalizedString(@"%@_live"), [LocalUserComponent userModel].name];

        [self addSubview:self.hostAvatar];
        [self.hostAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(56, 56));
            make.top.left.mas_equalTo(self).offset(6);
        }];
        [self addSubview:self.labelView];
        [self.labelView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(180, 20));
            make.left.mas_equalTo(self.hostAvatar.mas_right).offset(12);
            make.top.mas_equalTo(self).offset(10);
        }];
    }
    return self;
}

#pragma - Getter

- (UIImageView *)hostAvatar {
    if (!_hostAvatar) {
        _hostAvatar = [[UIImageView alloc] init];
        _hostAvatar.layer.cornerRadius = 8;
        _hostAvatar.layer.masksToBounds = YES;
    }
    return _hostAvatar;
}

- (UILabel *)labelView {
    if (!_labelView) {
        _labelView = [[UILabel alloc] init];
        _labelView.textColor = [UIColor whiteColor];
        _labelView.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    }
    return _labelView;
}

@end
