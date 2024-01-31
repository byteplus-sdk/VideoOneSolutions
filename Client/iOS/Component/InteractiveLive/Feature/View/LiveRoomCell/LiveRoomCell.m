// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveRoomCell.h"
#import "LiveAvatarView.h"

@interface LiveRoomCell ()

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) LiveAvatarView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *livingImageView;

@end

@implementation LiveRoomCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        [self createUIComponent];
    }
    return self;
}

- (void)setModel:(LiveRoomInfoModel *)model {
    _model = model;
    self.nameLabel.text = [NSString stringWithFormat:LocalizedString(@"%@'s_live_room"), model.anchorUserName];
    self.avatarView.url = [LiveUserModel getAvatarNameWithUid:model.anchorUserID];
}

#pragma mark - Private Action

- (void)createUIComponent {
    [self.contentView addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(8);
        make.height.mas_equalTo(100);
        make.left.equalTo(self.contentView).offset(16);
        make.right.equalTo(self.contentView).offset(-16);
    }];

    [self.bgView addSubview:self.avatarView];
    [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(60);
        make.centerY.equalTo(self.contentView);
        make.left.mas_equalTo(22);
    }];

    [self.bgView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.avatarView);
        make.left.equalTo(self.avatarView.mas_right).offset(19);
        make.right.mas_lessThanOrEqualTo(self.bgView.mas_right).offset(-15);
    }];

    [self addSubview:self.livingImageView];
    [self.livingImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel.mas_left).offset(0);
        make.top.equalTo(self.nameLabel.mas_bottom).offset(6);
    }];
}

#pragma mark - Getter

- (LiveAvatarView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[LiveAvatarView alloc] init];
        _avatarView.layer.cornerRadius = 8;
        _avatarView.layer.masksToBounds = YES;
    }
    return _avatarView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [UIColor colorFromHexString:@"#002C47"];
        _nameLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
    }
    return _nameLabel;
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor whiteColor];
        _bgView.layer.cornerRadius = 16;
        _bgView.layer.masksToBounds = YES;
    }
    return _bgView;
}

- (UIImageView *)livingImageView {
    if (!_livingImageView) {
        _livingImageView = [[UIImageView alloc] init];
        _livingImageView.image = [UIImage imageNamed:@"live_cell_status_live" bundleName:HomeBundleName];
    }
    return _livingImageView;
}

@end
