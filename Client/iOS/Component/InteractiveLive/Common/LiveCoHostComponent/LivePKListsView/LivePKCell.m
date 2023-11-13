// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LivePKCell.h"

@interface LivePKCell ()

@property (nonatomic, strong) UILabel *numLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) BaseButton *rightButton;
@property (nonatomic, strong) UIImageView *avatarImageView;

@end

@implementation LivePKCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        [self createUIComponent];
    }
    return self;
}

#pragma mark - Publish Action

- (void)setModel:(LiveUserModel *)model {
    _model = model;
    self.nameLabel.text = model.name;
    self.avatarImageView.image = [UIImage imageNamed:model.avatarName bundleName:ToolKitBundleName subBundleName:AvatarBundleName];
}

- (void)setIndexStr:(NSString *)indexStr {
    _indexStr = indexStr;

    self.numLabel.text = indexStr;
}

- (void)rightButtonAction:(BaseButton *)sender {
    if ([self.delegate respondsToSelector:@selector(LivePKCell:clickButton:)]) {
        [self.delegate LivePKCell:self clickButton:self.model];
    }
}

#pragma mark - Private Action

- (void)createUIComponent {
    [self.contentView addSubview:self.numLabel];
    [self.numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(16);
        make.centerY.equalTo(self.contentView);
    }];

    [self.contentView addSubview:self.avatarImageView];
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.left.equalTo(self.numLabel).offset(16);
        make.centerY.equalTo(self.contentView);
    }];

    [self.contentView addSubview:self.rightButton];
    [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(64);
        make.height.mas_equalTo(24);
        make.right.mas_equalTo(-16);
        make.centerY.equalTo(self.avatarImageView);
    }];

    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avatarImageView.mas_right).mas_offset(8);
        make.centerY.equalTo(self.avatarImageView);
        make.right.mas_lessThanOrEqualTo(self.rightButton.mas_left).offset(-8);
    }];
}

#pragma mark - Getter

- (BaseButton *)rightButton {
    if (!_rightButton) {
        _rightButton = [[BaseButton alloc] init];
        _rightButton.layer.cornerRadius = 2;
        _rightButton.layer.masksToBounds = YES;
        [_rightButton addTarget:self action:@selector(rightButtonAction:) forControlEvents:UIControlEventTouchUpInside];

        CGRect rect = CGRectMake(0, 0, 64, 24);
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = rect;
        gradient.colors = @[(id)[UIColor colorFromHexString:@"#FF1764"].CGColor,
                            (id)[UIColor colorFromHexString:@"#ED3596"].CGColor];
        gradient.startPoint = CGPointMake(0, 0.5);
        gradient.endPoint = CGPointMake(1, 0.5);
        [_rightButton.layer addSublayer:gradient];

        UILabel *label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        label.frame = rect;
        label.text = LocalizedString(@"invite");
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
        label.userInteractionEnabled = NO;
        [_rightButton addSubview:label];
    }
    return _rightButton;
}

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.layer.cornerRadius = 20;
        _avatarImageView.layer.masksToBounds = YES;
        _avatarImageView.layer.borderWidth = 1;
        _avatarImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    return _avatarImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [UIColor colorFromHexString:@"#FFFFFF"];
        _nameLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    }
    return _nameLabel;
}

- (UILabel *)numLabel {
    if (!_numLabel) {
        _numLabel = [[UILabel alloc] init];
        _numLabel.textColor = [UIColor colorFromHexString:@"#80838A"];
        _numLabel.font = [UIFont systemFontOfSize:12];
    }
    return _numLabel;
}

@end
