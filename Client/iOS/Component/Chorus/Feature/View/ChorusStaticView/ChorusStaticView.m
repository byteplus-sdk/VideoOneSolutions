// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "ChorusStaticView.h"
#import "ChorusPeopleNumView.h"
#import "ChorusRoomModel.h"

@interface ChorusStaticView ()

@property (nonatomic, strong) UIImageView *bgImageImageView;
@property (nonatomic, strong) UILabel *roomTitleLabel;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *roomIdLabel;
@property (nonatomic, strong) ChorusPeopleNumView *peopleNumView;
@property (nonatomic, strong) BaseButton *endButton;

@end

@implementation ChorusStaticView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubview:self.bgImageImageView];
        [self.bgImageImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [self addSubview:self.endButton];
        [self.endButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(24);
            make.right.equalTo(@-12);
            make.top.equalTo(self).offset([DeviceInforTool getSafeAreaInsets].bottom + 18);
        }];
        
        [self addSubview:self.peopleNumView];
        [self.peopleNumView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(24);
            make.right.equalTo(self.endButton.mas_left).offset(-10);
            make.centerY.equalTo(self.endButton);
        }];
        
        [self addSubview:self.avatarImageView];
        [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(32);
            make.left.mas_equalTo(14);
            make.centerY.equalTo(self.endButton);
        }];
        
        [self addSubview:self.roomTitleLabel];
        [self.roomTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(20);
            make.left.equalTo(self.avatarImageView.mas_right).offset(4);
            make.top.equalTo(self.avatarImageView).offset(-3);
            make.right.lessThanOrEqualTo(self.peopleNumView.mas_left);
        }];
        
        [self addSubview:self.roomIdLabel];
        [self.roomIdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(18);
            make.left.equalTo(self.roomTitleLabel);
            make.top.equalTo(self.roomTitleLabel.mas_bottom);
            make.right.lessThanOrEqualTo(self.peopleNumView.mas_left);
        }];
    }
    return self;
}

#pragma mark - Publish Action

- (void)setRoomModel:(ChorusRoomModel *)roomModel {
    _roomModel = roomModel;
    
    self.roomTitleLabel.text = roomModel.roomName;
    NSString *bgImageName = roomModel.extDic[@"background_image_name"];
    self.bgImageImageView.image = [UIImage imageNamed:[bgImageName stringByAppendingString:@".jpg"]];
    [self.peopleNumView updateTitleLabel:roomModel.audienceCount];
    self.roomIdLabel.text = [@"ID:" stringByAppendingFormat:@"%@", roomModel.roomID];
    
    self.avatarImageView.image = [UIImage avatarImageForUid:roomModel.hostUid];
}

- (void)updatePeopleNum:(NSInteger)count {
    [self.peopleNumView updateTitleLabel:count];
}

- (void)endButtonAction:(BaseButton *)sender {
    if (self.closeButtonDidClickBlock) {
        self.closeButtonDidClickBlock();
    }
}

#pragma mark - Getter

- (UIImageView *)bgImageImageView {
    if (!_bgImageImageView) {
        _bgImageImageView = [[UIImageView alloc] init];
        _bgImageImageView.contentMode = UIViewContentModeScaleAspectFill;
        _bgImageImageView.clipsToBounds = YES;
    }
    return _bgImageImageView;
}

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarImageView.clipsToBounds = YES;
        _avatarImageView.layer.cornerRadius = 16;
        _avatarImageView.layer.masksToBounds = YES;
    }
    return _avatarImageView;
}

- (UILabel *)roomTitleLabel {
    if (!_roomTitleLabel) {
        _roomTitleLabel = [[UILabel alloc] init];
        _roomTitleLabel.textColor = [UIColor whiteColor];
        _roomTitleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _roomTitleLabel;
}

- (UILabel *)roomIdLabel {
    if (!_roomIdLabel) {
        _roomIdLabel = [[UILabel alloc] init];
        _roomIdLabel.textColor = [UIColor colorFromHexString:@"#737A87"];
        _roomIdLabel.font = [UIFont systemFontOfSize:10 weight:UIFontWeightRegular];
    }
    return _roomIdLabel;
}

- (ChorusPeopleNumView *)peopleNumView {
    if (!_peopleNumView) {
        _peopleNumView = [[ChorusPeopleNumView alloc] init];
        _peopleNumView.backgroundColor = [UIColor colorFromRGBHexString:@"#000000" andAlpha:0.2 * 255];
        _peopleNumView.layer.cornerRadius = 16;
        _peopleNumView.layer.masksToBounds = YES;
    }
    return _peopleNumView;
}

- (BaseButton *)endButton {
    if (!_endButton) {
        _endButton = [[BaseButton alloc] init];
        [_endButton setImage:[UIImage imageNamed:@"room_bottom_end" bundleName:HomeBundleName] forState:UIControlStateNormal];
        [_endButton addTarget:self action:@selector(endButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _endButton;
}

@end
