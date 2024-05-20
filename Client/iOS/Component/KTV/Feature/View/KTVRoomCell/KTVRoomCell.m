// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "KTVRoomCell.h"
#import "KTVAvatarComponent.h"
#import "UIView+Fillet.h"

@interface KTVRoomCell ()

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UILabel *roomNameLabel;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIImageView *peopleNumImageView;
@property (nonatomic, strong) UILabel *peopleNumLabel;
@property (nonatomic, strong) UIView *peopleBgView;

@end

@implementation KTVRoomCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        [self createUIComponent];
    }
    return self;
}

- (void)setModel:(KTVRoomModel *)model {
    _model = model;
    [self setLineSpace:12 withText:model.roomName inLabel:self.roomNameLabel];
    self.peopleNumLabel.text = [NSString stringWithFormat:@"%ld", (long)(model.audienceCount + 1)];
    
    NSString *imageNamed = [BaseUserModel getAvatarNameWithUid:model.hostUid];
    self.avatarImageView.image = [UIImage imageNamed:imageNamed
                                          bundleName:ToolKitBundleName
                                       subBundleName:AvatarBundleName];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.peopleBgView filletWithRadius:4 corner:UIRectCornerBottomRight | UIRectCornerTopRight];
}

#pragma mark - Private Action

- (void)createUIComponent {
    [self.contentView addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(16);
        make.left.equalTo(self.contentView).offset(16);
        make.right.equalTo(self.contentView).offset(-16);
    }];
    
    [self.bgView addSubview:self.avatarImageView];
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(60);
        make.left.equalTo(self.bgView).offset(20);
        make.top.equalTo(self.bgView).offset(20);
        make.bottom.equalTo(self.bgView).offset(-20);
    }];
    
    [self.bgView addSubview:self.roomNameLabel];
    [self.roomNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.avatarImageView);
        make.left.equalTo(self.avatarImageView.mas_right).offset(16);
        make.right.mas_lessThanOrEqualTo(self.bgView.mas_right).offset(-16);
    }];
    
    [self.bgView addSubview:self.iconImageView];
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(50, 20));
        make.left.equalTo(self.avatarImageView.mas_right).offset(16);
        make.bottom.equalTo(self.avatarImageView).offset(-10);
    }];
    
    [self.bgView addSubview:self.peopleBgView];
    [self.bgView addSubview:self.peopleNumImageView];
    [self.peopleNumImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(12, 12));
        make.left.equalTo(self.iconImageView.mas_right).offset(6);
        make.centerY.equalTo(self.iconImageView);
    }];
    
    [self.bgView addSubview:self.peopleNumLabel];
    [self.peopleNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.peopleNumImageView.mas_right).offset(4);
        make.centerY.equalTo(self.peopleNumImageView);
    }];
    
    [self.peopleBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.iconImageView);
        make.left.equalTo(self.iconImageView.mas_right).offset(0);
        make.right.equalTo(self.peopleNumLabel).offset(6);
        make.height.equalTo(@20);
    }];

    [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView);
    }];
}

#pragma mark - Private Action

- (void)setLineSpace:(CGFloat)lineSpace withText:(NSString *)text inLabel:(UILabel *)label{
    if (!text || !label) {
        return;
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpace;
    paragraphStyle.lineBreakMode = label.lineBreakMode;
    paragraphStyle.alignment = label.textAlignment;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [text length])];
    label.attributedText = attributedString;
}

#pragma mark - getter

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.image = [UIImage imageNamed:@"room_list_live" bundleName:HomeBundleName];
    }
    return _iconImageView;
}

- (UIImageView *)peopleNumImageView {
    if (!_peopleNumImageView) {
        _peopleNumImageView = [[UIImageView alloc] init];
        _peopleNumImageView.image = [UIImage imageNamed:@"room_list_people" bundleName:HomeBundleName];
    }
    return _peopleNumImageView;
}

- (UILabel *)peopleNumLabel {
    if (!_peopleNumLabel) {
        _peopleNumLabel = [[UILabel alloc] init];
        _peopleNumLabel.textColor = [UIColor colorFromHexString:@"#0C0D0E"];
        _peopleNumLabel.font = [UIFont systemFontOfSize:12];
        _peopleNumLabel.numberOfLines = 1;
    }
    return _peopleNumLabel;
}

- (UILabel *)roomNameLabel {
    if (!_roomNameLabel) {
        _roomNameLabel = [[UILabel alloc] init];
        _roomNameLabel.textColor = [UIColor colorFromHexString:@"#002C47"];
        _roomNameLabel.font = [UIFont systemFontOfSize:16];
        _roomNameLabel.numberOfLines = 1;
    }
    return _roomNameLabel;
}

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarImageView.clipsToBounds = YES;
        _avatarImageView.layer.cornerRadius = 8;
        _avatarImageView.layer.masksToBounds = YES;
    }
    return _avatarImageView;
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor colorFromHexString:@"#FFFFFF"];
        _bgView.layer.cornerRadius = 20;
        _bgView.layer.masksToBounds = YES;
    }
    return _bgView;
}

- (UIView *)peopleBgView {
    if (!_peopleBgView) {
        _peopleBgView = [[UIView alloc] init];
        _peopleBgView.backgroundColor = [UIColor colorFromHexString:@"#DDE2E9"];
    }
    return _peopleBgView;
}

@end
