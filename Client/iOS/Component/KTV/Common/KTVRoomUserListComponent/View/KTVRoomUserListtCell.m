// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "KTVRoomUserListtCell.h"
#import "KTVAvatarComponent.h"

@interface KTVRoomUserListtCell ()

@property (nonatomic, strong) UILabel *numberLabel;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) BaseButton *rightButton;
@property (nonatomic, strong) UIView *rightButtonMaskView;

@end

@implementation KTVRoomUserListtCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        [self createUIComponent];
    }
    return self;
}

- (void)setModel:(KTVUserModel *)model {
    _model = model;
    self.nameLabel.text = model.name;
    self.avatarImageView.image = [UIImage imageNamed:model.avatarName
                                          bundleName:ToolKitBundleName
                                       subBundleName:AvatarBundleName];
    
    if (model.status == KTVUserStatusActive) {
        [self.rightButton setTitle:LocalizedString(@"button_user_list_guest") forState:UIControlStateNormal];
        self.rightButton.backgroundColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.2 * 255];
        [self.rightButton setTitleColor:[UIColor colorFromRGBHexString:@"#737A87"] forState:UIControlStateNormal];
        self.rightButton.hidden = NO;
        self.rightButton.layer.borderWidth = 0;
        self.rightButtonMaskView.hidden = YES;
    } else if (model.status == KTVUserStatusApply) {
        [self.rightButton setTitle:LocalizedString(@"button_user_list_accept") forState:UIControlStateNormal];
        self.rightButton.backgroundColor = [UIColor clearColor];
        [self.rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.rightButton.hidden = NO;
        self.rightButton.layer.borderColor = [UIColor whiteColor].CGColor;
        self.rightButton.layer.borderWidth = 1;
        self.rightButtonMaskView.hidden = YES;
    } else if (model.status == KTVUserStatusInvite) {
        [self.rightButton setTitle:LocalizedString(@"button_user_list_invited") forState:UIControlStateNormal];
        self.rightButton.backgroundColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.2 * 255];
        [self.rightButton setTitleColor:[UIColor colorFromRGBHexString:@"#737A87"] forState:UIControlStateNormal];
        self.rightButton.hidden = NO;
        self.rightButton.layer.borderWidth = 0;
        self.rightButtonMaskView.hidden = YES;
    } else if (model.status == KTVUserStatusDefault) {
        [self.rightButton setTitle:LocalizedString(@"button_user_list_invited_guest") forState:UIControlStateNormal];
        self.rightButton.backgroundColor = [UIColor clearColor];
        [self.rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.rightButton.hidden = NO;
        self.rightButton.layer.borderWidth = 0;
        self.rightButtonMaskView.hidden = NO;
    } else {
        self.rightButton.hidden = YES;
    }
}

- (void)setIndexRow:(NSInteger)indexRow {
    _indexRow = indexRow;
    
    self.numberLabel.text = @(indexRow + 1).stringValue;
}

- (void)createUIComponent {
    [self.contentView addSubview:self.numberLabel];
    [self.contentView addSubview:self.avatarImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.rightButtonMaskView];
    [self.contentView addSubview:self.rightButton];
    
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.left.equalTo(self.numberLabel.mas_right).offset(16);
        make.top.equalTo(self.contentView);
    }];
    
    [self.numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@16);
        make.centerY.equalTo(self.avatarImageView);
    }];
    
    [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(64);
        make.height.mas_equalTo(24);
        make.right.mas_equalTo(-16);
        make.centerY.equalTo(self.avatarImageView);
    }];
    
    [self.rightButtonMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.rightButton);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avatarImageView.mas_right).mas_offset(8);
        make.centerY.equalTo(self.avatarImageView);
        make.right.mas_lessThanOrEqualTo(self.rightButton.mas_left).offset(-8);
    }];
}

- (void)rightButtonAction:(BaseButton *)sender {
    if ([self.delegate respondsToSelector:@selector(KTVRoomUserListtCell:clickButton:)]) {
        [self.delegate KTVRoomUserListtCell:self clickButton:self.model];
    }
}

#pragma mark - getter

- (BaseButton *)rightButton {
    if (!_rightButton) {
        _rightButton = [[BaseButton alloc] init];
        _rightButton.layer.cornerRadius = 2;
        _rightButton.layer.masksToBounds = YES;
        _rightButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_rightButton addTarget:self action:@selector(rightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightButton;
}

- (UIView *)rightButtonMaskView {
    if (!_rightButtonMaskView) {
        _rightButtonMaskView = [[UIView alloc] init];
        _rightButtonMaskView.backgroundColor = [UIColor clearColor];
        _rightButtonMaskView.layer.cornerRadius = 2;
        _rightButtonMaskView.layer.masksToBounds = YES;
        
        CAGradientLayer *pickButtonLayer = [CAGradientLayer layer];
        pickButtonLayer.colors = @[
            (__bridge id)[UIColor colorFromRGBHexString:@"#FF1764"].CGColor,
            (__bridge id)[UIColor colorFromRGBHexString:@"#ED3596"].CGColor
        ];
        pickButtonLayer.frame = CGRectMake(0, 0, 64, 24);
        pickButtonLayer.startPoint = CGPointMake(0.25, 0.5);
        pickButtonLayer.endPoint = CGPointMake(0.75, 0.5);
        
        [_rightButtonMaskView.layer addSublayer:pickButtonLayer];
    }
    return _rightButtonMaskView;
}

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.layer.cornerRadius = 20;
        _avatarImageView.layer.masksToBounds = YES;
        _avatarImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        _avatarImageView.layer.borderWidth = 1;
    }
    return _avatarImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [UIColor colorFromHexString:@"#FFFFFF"];
        _nameLabel.font = [UIFont systemFontOfSize:14];
    }
    return _nameLabel;
}

- (UILabel *)numberLabel {
    if (!_numberLabel) {
        _numberLabel = [[UILabel alloc] init];
        _numberLabel.textColor = [UIColor colorFromHexString:@"#737A87"];
        _numberLabel.font = [UIFont systemFontOfSize:12];
    }
    return _numberLabel;
}

@end
