// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveEndView.h"
#import "LiveAvatarView.h"
#import "LiveRTCManager.h"
#import "LiveInfoItemView.h"
@interface LiveEndView ()
@property (nonatomic, strong) UIView *renderView;
@property (nonatomic, strong) LiveAvatarView *avatarView;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *contentTitle;
@property (nonatomic, strong) LiveInfoItemView *viewersItem;
@property (nonatomic, strong) LiveInfoItemView *likesItem;
@property (nonatomic, strong) LiveInfoItemView *giftsItem;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UIButton *backToHomeButton;
@property (nonatomic, strong) UIButton *backButton;

@end

@implementation LiveEndView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubview:self.renderView];
        [self.renderView mas_makeConstraints:^(MASConstraintMaker *make) {
          make.edges.equalTo(self);
        }];
        [self addSubview:self.bgView];
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];

        [self.bgView addSubview:self.avatarView];
        [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(120);
            make.top.equalTo(self.bgView).mas_offset(96);
            make.centerX.equalTo(self.bgView);
        }];
        
        [self.bgView addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.avatarView.mas_bottom).mas_offset(12);
            make.left.mas_greaterThanOrEqualTo(16);
            make.right.mas_lessThanOrEqualTo(-16);
            make.centerX.equalTo(self.avatarView);
        }];
        
        [self.bgView addSubview:self.durationLabel];
        [self.durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.nameLabel.mas_bottom).mas_offset(2);
            make.left.mas_greaterThanOrEqualTo(16);
            make.right.mas_lessThanOrEqualTo(-16);
            make.centerX.equalTo(self.nameLabel);
        }];
        
        [self.bgView addSubview:self.contentView];
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.durationLabel.mas_bottom).mas_offset(32);
            make.left.equalTo(self.bgView).mas_offset(16);
            make.right.equalTo(self.bgView).mas_offset(-16);
            make.height.mas_equalTo(166);
            make.centerX.equalTo(self.bgView);
        }];
        
        [self.contentView addSubview:self.contentTitle];
        [self.contentTitle  mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView).offset(16);
            make.left.mas_equalTo(self.contentView).offset(12);
            make.right.mas_equalTo(self.contentView).offset(-12);
            make.height.mas_equalTo(24);
        }];
        
        [self.contentView  addSubview:self.viewersItem];
        [self.viewersItem mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.contentView).offset(12);
            make.top.mas_equalTo(self.contentTitle.mas_bottom).offset(12);
            make.size.mas_equalTo(CGSizeMake(140,  44));
        }];
        
        [self.contentView addSubview:self.likesItem];
        [self.likesItem mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.viewersItem.mas_right).offset(12);
            make.top.mas_equalTo(self.contentTitle.mas_bottom).offset(12);
            make.size.mas_equalTo(CGSizeMake(140,  44));
        }];
        
        [self.contentView addSubview:self.giftsItem];
        [self.giftsItem mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.contentView).offset(12);
            make.top.mas_equalTo(self.viewersItem.mas_bottom).offset(10);
            make.size.mas_equalTo(CGSizeMake(140,  44));
        }];
        
        [self.bgView addSubview:self.backToHomeButton];
        [self.backToHomeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(174);
            make.height.mas_equalTo(44);
            make.centerX.equalTo(self.bgView);
            make.top.equalTo(self.contentView.mas_bottom).mas_offset(32);
        }];
        
        [self.bgView addSubview:self.backButton];
        [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(20);
            make.height.mas_equalTo(20);
            make.top.equalTo(self.bgView).mas_offset(56);
            make.left.equalTo(self.bgView).mas_offset(16);
        }];
    }
    return self;
}
- (void)setupLocalRenderView {
    [[LiveRTCManager shareRtc] switchVideoCapture:YES];
    [[LiveRTCManager shareRtc] switchAudioCapture:YES];
    [[LiveRTCManager shareRtc] bindCanvasViewToUid:[LocalUserComponent userModel].uid];

    UIView *rtcStreamView = [[LiveRTCManager shareRtc] getStreamViewWithUid:[LocalUserComponent userModel].uid];
    rtcStreamView.hidden = NO;
    [self.renderView addSubview:rtcStreamView];
    [rtcStreamView mas_remakeConstraints:^(MASConstraintMaker *make) {
      make.edges.equalTo(self.renderView);
    }];
}

#pragma mark - Setter

- (void)setModel:(LiveEndLiveModel *)model {
    if(model.userAvatarImageUrl) {
        self.avatarView.url = model.userAvatarImageUrl;
    } else {
        self.avatarView.url = [LiveUserModel getAvatarNameWithUid:[LocalUserComponent userModel].uid];
    }
    
    if(model.userName) {
        self.nameLabel.text = [NSString stringWithFormat:@"%@%@", model.userName, LocalizedString(@"end_live_s_live_show")];
    } else {
        self.nameLabel.text = [LocalUserComponent userModel].name;
    }
    
    if(model.duration) {
        NSNumber *value = [NSNumber numberWithUnsignedLong:model.duration];
        float minutes = value.floatValue / 1000 / 60;
        self.durationLabel.text = [NSString stringWithFormat:@"%@%ld%@",
                                   LocalizedString(@"end_live_duration"), (long)minutes ,
                                   LocalizedString(@"end_live_mins")];
    } else {
        self.durationLabel.text = [NSString stringWithFormat:@"%@%ld%@",
                                   LocalizedString(@"end_live_duration"), (long)0,
                                   LocalizedString(@"end_live_mins")];
    }
    
    self.viewersItem.value = [NSNumber numberWithUnsignedLong:model.viewers];
    self.likesItem.value = [NSNumber numberWithUnsignedLong:model.likes];
    self.giftsItem.value = [NSNumber numberWithUnsignedLong:model.gifts];
}

#pragma mark - Touch Action
- (void)backToHomeButtonAction:(UIButton *)sender {
    sender.userInteractionEnabled = NO;
    if (self.backToHomeBlock) {
        self.backToHomeBlock();
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.userInteractionEnabled = YES;
    });
}

#pragma mark - Getter
- (UIView *)renderView {
    if (!_renderView) {
        _renderView = [[UIView alloc] init];
    }
    return _renderView;
}

- (UIView *) bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor colorFromRGBHexString:@"#000000" andAlpha:0.7*255];
    }
    return _bgView;
}

- (UIView *) contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.12*255];
        _contentView.layer.cornerRadius = 4;
    }
    return _contentView;
}

- (UILabel *)contentTitle {
    if(!_contentTitle) {
        _contentTitle   = [[UILabel alloc] init];
        _contentTitle.textColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.9*255];
        _contentTitle.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        _contentTitle.text = LocalizedString(@"end_live_view_overview");
    }
    return  _contentTitle;
}

- (LiveInfoItemView *)viewersItem {
    if(!_viewersItem) {
        _viewersItem = [[LiveInfoItemView alloc] init];
        _viewersItem.title = LocalizedString(@"end_live_view_viewers");
    }
    return _viewersItem;
}

- (LiveInfoItemView *)likesItem {
    if(!_likesItem) {
        _likesItem = [[LiveInfoItemView alloc] init];
        _likesItem.title = LocalizedString(@"end_live_view_likes");
    }
    return  _likesItem;
}

- (LiveInfoItemView *)giftsItem {
    if(!_giftsItem) {
        _giftsItem = [[LiveInfoItemView alloc] init];
        _giftsItem.title = LocalizedString(@"end_live_view_gifts");
    }
    return  _giftsItem;
}

- (LiveAvatarView *) avatarView {
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
        _nameLabel.textColor = [UIColor colorFromHexString:@"#FFFFFF"];
        _nameLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightMedium];
        _nameLabel.text = [NSString stringWithFormat:@"%@%@", @"xxx", LocalizedString(@"end_live_s_live_show")];
    }
    return _nameLabel;
}

- (UILabel *)durationLabel {
    if (!_durationLabel) {
        _durationLabel = [[UILabel alloc] init];
        _durationLabel.textColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.9*255];
        _durationLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        _durationLabel.text = [NSString stringWithFormat:@"%@%@%@", LocalizedString(@"end_live_duration"), @"0", LocalizedString(@"end_live_mins")];
    }
    return _durationLabel;
}

- (UIButton *)backToHomeButton {
    if (!_backToHomeButton) {
        _backToHomeButton = [[UIButton alloc] init];
        _backToHomeButton.backgroundColor = [UIColor clearColor];
        [_backToHomeButton addTarget:self action:@selector(backToHomeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _backToHomeButton.layer.cornerRadius = 4;
        _backToHomeButton.layer.masksToBounds = YES;
        _backToHomeButton.layer.borderWidth = 1;
        _backToHomeButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _backToHomeButton.titleLabel.font = [UIFont systemFontOfSize:16 weight: UIFontWeightMedium];
        [_backToHomeButton setTitle:LocalizedString(@"end_live_back_to_homepage") forState:UIControlStateNormal];
    }
    return _backToHomeButton;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [[UIButton alloc] init];
        _backButton.backgroundColor = [UIColor clearColor];
        [_backButton addTarget:self action:@selector(backToHomeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_backButton setImage:[UIImage imageNamed:@"InteractiveLive_end_view_back" bundleName:HomeBundleName] forState:UIControlStateNormal];
    }
    return _backButton;
}

@end
