// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveAddGuestsUserListtCell.h"
#import "LiveAvatarView.h"
#import "LiveRTCManager.h"

@interface LiveAddGuestsUserListtCell ()

@property (nonatomic, strong) UILabel *numLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) BaseButton *rejectButton;
@property (nonatomic, strong) BaseButton *agreeButton;
@property (nonatomic, strong) UIButton *grayButton;
@property (nonatomic, strong) BaseButton *micButton;
@property (nonatomic, strong) BaseButton *cameraButton;
@property (nonatomic, strong) BaseButton *cancelButton;

@end

@implementation LiveAddGuestsUserListtCell

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

- (void)setOnlineUserModel:(LiveUserModel *)onlineUserModel {
    _onlineUserModel = onlineUserModel;

    [self showOnlineStatus:YES];
    self.nameLabel.text = onlineUserModel.name;
    self.avatarImageView.image = [UIImage imageNamed:onlineUserModel.avatarName bundleName:ToolKitBundleName subBundleName:AvatarBundleName];
    self.micButton.status = onlineUserModel.mic ? ButtonStatusNone : ButtonStatusIllegal;
    self.cameraButton.status = onlineUserModel.camera ? ButtonStatusNone : ButtonStatusIllegal;
}

- (void)setApplicationUserModel:(LiveUserModel *)applicationUserModel {
    _applicationUserModel = applicationUserModel;

    [self showOnlineStatus:NO];
    self.nameLabel.text = applicationUserModel.name;
    self.avatarImageView.image = [UIImage imageNamed:applicationUserModel.avatarName bundleName:ToolKitBundleName subBundleName:AvatarBundleName];
}

- (void)setIndexStr:(NSString *)indexStr {
    _indexStr = indexStr;

    self.numLabel.text = indexStr;
}

#pragma mark - Private Action
- (void)agreeButtonAction:(BaseButton *)sender {
    if ([self.delegate respondsToSelector:@selector(liveAddGuestsCell:clickAgreeButton:)]) {
        [self.delegate liveAddGuestsCell:self clickAgreeButton:self.applicationUserModel];
    }
}
- (void)rejectButtonAction {
    if ([self.delegate respondsToSelector:@selector(liveAddGuestsCell:clickRejectButton:)]) {
        [self.delegate liveAddGuestsCell:self
                       clickRejectButton:self.applicationUserModel];
    }
}
- (void)cancelButtonAction {
    if ([self.delegate respondsToSelector:@selector(liveAddGuestsCell:clickDisconnectButton:)]) {
        [self.delegate liveAddGuestsCell:self
                   clickDisconnectButton:self.onlineUserModel];
    }
}
- (void)micButtonAction:(BaseButton *)sender {
    if (sender.status == ButtonStatusIllegal) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(liveAddGuestsCell:clickMicButton:)]) {
        [self.delegate liveAddGuestsCell:self
                          clickMicButton:self.onlineUserModel];
    }
}
- (void)cameraButtonAction:(BaseButton *)sender {
    if (sender.status == ButtonStatusIllegal) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(liveAddGuestsCell:clickCameraButton:)]) {
        [self.delegate liveAddGuestsCell:self
                       clickCameraButton:self.onlineUserModel];
    }
}

- (void)showOnlineStatus:(BOOL)isOnline {
    self.agreeButton.hidden = isOnline ? YES : NO;
    self.rejectButton.hidden = isOnline ? YES : NO;

    self.micButton.hidden = isOnline ? NO : YES;
    self.cameraButton.hidden = isOnline ? NO : YES;
    self.cancelButton.hidden = isOnline ? NO : YES;
}

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

    [self.contentView addSubview:self.agreeButton];
    [self.agreeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(64);
        make.height.mas_equalTo(24);
        make.right.mas_equalTo(-16);
        make.centerY.equalTo(self.avatarImageView);
    }];

    [self.contentView addSubview:self.grayButton];
    [self.grayButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(64);
        make.height.mas_equalTo(24);
        make.right.mas_equalTo(-16);
        make.centerY.equalTo(self.avatarImageView);
    }];

    [self.contentView addSubview:self.rejectButton];
    [self.rejectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(64, 24));
        make.right.equalTo(self.agreeButton.mas_left).offset(-12);
        make.centerY.equalTo(self.agreeButton);
    }];

    [self.contentView addSubview:self.cancelButton];
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(24, 24));
        make.right.mas_equalTo(-16);
        make.centerY.equalTo(self.avatarImageView);
    }];

    [self.contentView addSubview:self.cameraButton];
    [self.cameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(24, 24));
        make.right.equalTo(self.cancelButton.mas_left).offset(-12);
        make.centerY.equalTo(self.avatarImageView);
    }];

    [self.contentView addSubview:self.micButton];
    [self.micButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(24, 24));
        make.right.equalTo(self.cameraButton.mas_left).offset(-12);
        make.centerY.equalTo(self.avatarImageView);
    }];

    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avatarImageView.mas_right).mas_offset(8);
        make.centerY.equalTo(self.avatarImageView);
        make.right.mas_lessThanOrEqualTo(self.micButton.mas_left).offset(-8);
    }];
}

#pragma mark - Getter

- (BaseButton *)micButton {
    if (!_micButton) {
        _micButton = [[BaseButton alloc] init];
        _micButton.backgroundColor = [UIColor clearColor];
        [_micButton bingImage:[UIImage imageNamed:@"co-host_mic" bundleName:HomeBundleName] status:ButtonStatusNone];
        [_micButton bingImage:[UIImage imageNamed:@"co-host_mic_invalid" bundleName:HomeBundleName] status:ButtonStatusIllegal];
        [_micButton addTarget:self action:@selector(micButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _micButton;
}

- (BaseButton *)cameraButton {
    if (!_cameraButton) {
        _cameraButton = [[BaseButton alloc] init];
        _cameraButton.backgroundColor = [UIColor clearColor];
        [_cameraButton bingImage:[UIImage imageNamed:@"co-host_camera" bundleName:HomeBundleName] status:ButtonStatusNone];
        [_cameraButton bingImage:[UIImage imageNamed:@"co-host_camera_invalid" bundleName:HomeBundleName] status:ButtonStatusIllegal];
        [_cameraButton addTarget:self action:@selector(cameraButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraButton;
}

- (BaseButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [[BaseButton alloc] init];
        _cancelButton.backgroundColor = [UIColor clearColor];
        [_cancelButton setImage:[UIImage imageNamed:@"co-host_cancel" bundleName:HomeBundleName] forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (BaseButton *)rejectButton {
    if (!_rejectButton) {
        _rejectButton = [[BaseButton alloc] init];
        CGRect rect = CGRectMake(0, 0, 64, 24);
        [_rejectButton setTitle:LocalizedString(@"reject") forState:UIControlStateNormal];
        _rejectButton.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
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
        _rejectButton.hidden = YES;
    }
    return _rejectButton;
}

- (void)setIsApplyDisable:(BOOL)isApplyDisable {
    _isApplyDisable = isApplyDisable;
    self.agreeButton.hidden = isApplyDisable;
    self.grayButton.hidden = !isApplyDisable;
    self.rejectButton.hidden = isApplyDisable;
}

- (BaseButton *)agreeButton {
    if (!_agreeButton) {
        _agreeButton = [[BaseButton alloc] init];
        _agreeButton.layer.cornerRadius = 2;
        _agreeButton.layer.masksToBounds = YES;
        [_agreeButton addTarget:self action:@selector(agreeButtonAction:) forControlEvents:UIControlEventTouchUpInside];

        CGRect rect = CGRectMake(0, 0, 64, 24);
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
        label.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
        label.userInteractionEnabled = NO;
        [_agreeButton addSubview:label];
        _agreeButton.hidden = YES;
    }
    return _agreeButton;
}

- (UIButton *)grayButton {
    if (!_grayButton) {
        _grayButton = [[UIButton alloc] init];
        _grayButton.backgroundColor = [UIColor colorFromHexString:@"#80838A"];
        [_grayButton setTitle:LocalizedString(@"agree") forState:UIControlStateDisabled];
        [_grayButton setTitleColor:[UIColor colorFromHexString:@"#C7CCD6"] forState:UIControlStateNormal];
        _grayButton.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
        _grayButton.layer.cornerRadius = 2;
        _grayButton.layer.masksToBounds = YES;
        _grayButton.enabled = NO;
        _grayButton.hidden = YES;
    }
    return _grayButton;
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
