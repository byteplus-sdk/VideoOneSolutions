// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveAddGuestsItemView.h"
#import "LiveAvatarView.h"
#import "LiveStateIconView.h"

@interface LiveAddGuestsItemView ()

@property (nonatomic, strong) BaseButton *maskButton;
@property (nonatomic, strong) BaseButton *moreButton;
@property (nonatomic, strong) UIImageView *shadowImageView;
@property (nonatomic, strong) UIImageView *micImageView;
@property (nonatomic, strong) UILabel *userNameLabel;
@property (nonatomic, strong) LiveRTCRenderView *renderView;
@property (nonatomic, strong) UIImageView *addImageView;
@property (nonatomic, strong) UIView *addView;
@property (nonatomic, strong) UILabel *addLabel;
@property (nonatomic, assign) LiveAddGuestsItemStatus itemStatus;

@end

@implementation LiveAddGuestsItemView

- (instancetype)initWithStatus:(LiveAddGuestsItemStatus)status {
    self = [super init];
    if (self) {
        self.itemStatus = status;
        if (status == LiveAddGuestsItemStatusTwoPlayerHost ||
            status == LiveAddGuestsItemStatusTwoPlayerGuests) {
            self.layer.cornerRadius = 4;
            self.layer.masksToBounds = YES;
        }
        self.backgroundColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.1 * 255];
        
        [self addSubview:self.renderView];
        [self.renderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [self addSubview:self.shadowImageView];
        [self.shadowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.equalTo(self);
            make.height.mas_equalTo(30);
        }];
        
        [self addSubview:self.micImageView];
        [self.micImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(16, 16));
            make.left.mas_equalTo(4);
            make.bottom.mas_equalTo(-6);
        }];
        
        [self addSubview:self.userNameLabel];
        [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(4);
            make.centerY.equalTo(self.micImageView);
            make.right.mas_lessThanOrEqualTo(self.mas_right).offset(-2);
        }];
        
        [self addSubview:self.addView];
        [self.addView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.centerY.equalTo(self);
        }];
        
        [self.addView addSubview:self.addImageView];
        [self.addImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.addView);
            make.size.mas_equalTo(CGSizeMake(25, 25));
            make.centerX.equalTo(self);
        }];
        
        [self.addView addSubview:self.addLabel];
        [self.addLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.addImageView.mas_bottom).offset(8);
            make.centerX.equalTo(self);
            make.bottom.equalTo(self.addView);
        }];
        
        [self addSubview:self.maskButton];
        [self.maskButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [self addSubview:self.moreButton];
        [self.moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(24, 24));
            make.top.mas_equalTo(0);
            make.right.mas_equalTo(-4);
        }];
    }
    return self;
}

- (void)setUserModel:(LiveUserModel *)userModel {
    _userModel = userModel;
    
    if (self.itemStatus == LiveAddGuestsItemStatusTwoPlayerHost ||
        self.itemStatus == LiveAddGuestsItemStatusMultiPlayer) {
        self.moreButton.hidden = YES;
    } else {
        self.moreButton.hidden = NO;
    }
    if (NOEmptyStr(userModel.uid)) {
        self.addLabel.hidden = YES;
        self.addImageView.hidden = YES;
        self.userNameLabel.hidden = NO;
        self.renderView.hidden = NO;
        self.shadowImageView.hidden = NO;
        self.renderView.uid = userModel.uid;
        self.renderView.isCamera = userModel.camera;
        
        if([userModel.uid isEqualToString:[LocalUserComponent userModel].uid]) {
            self.userNameLabel.text = [userModel.name stringByAppendingString:LocalizedString(@"self_tag")];
        } else {
            self.userNameLabel.text = userModel.name;
        }
        self.micImageView.hidden = userModel.mic;
        [self.userNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.micImageView.hidden ? 4 : 22);
        }];
        
    } else {
        self.userNameLabel.hidden = YES;
        self.micImageView.hidden = YES;
        self.renderView.hidden = YES;
        self.shadowImageView.hidden = YES;
        self.addLabel.hidden = NO;
        self.addImageView.hidden = NO;
    }
}

- (void)setIsHost:(BOOL)isHost {
    if(!isHost) {
        self.addLabel.hidden = YES;
        self.addImageView.hidden = YES;
        self.backgroundColor = [UIColor clearColor];
    }
}

- (void)moreButtonAction {
    if (self.clickMoreBlock) {
        self.clickMoreBlock(self.userModel);
    }
}

- (void)maskButtonAction {
    if (self.clickMaskBlock) {
        self.clickMaskBlock(self.userModel);
    }
}

- (void)updateNetworkQuality:(LiveNetworkQualityStatus)status {
    
}

- (void)updateAddTitle:(NSString *)title {
    self.addLabel.text = title;
}

#pragma mark - Getter

- (UIImageView *)shadowImageView {
    if (!_shadowImageView) {
        _shadowImageView = [[UIImageView alloc] init];
        _shadowImageView.image = [UIImage imageNamed:@"guests_bottom" bundleName:HomeBundleName];
        _shadowImageView.hidden = YES;
    }
    return _shadowImageView;
}

- (UIView *)addView {
    if (!_addView) {
        _addView = [[UIView alloc] init];
        _addView.backgroundColor = [UIColor clearColor];
    }
    return _addView;
}

- (UIImageView *)addImageView {
    if (!_addImageView) {
        _addImageView = [[UIImageView alloc] init];
        _addImageView.image = [UIImage imageNamed:@"add_guest" bundleName:HomeBundleName];
    }
    return _addImageView;
}

- (UILabel *)addLabel {
    if (!_addLabel) {
        _addLabel = [[UILabel alloc] init];
        _addLabel.textColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.2 * 255];
        _addLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    }
    return _addLabel;
}

- (BaseButton *)moreButton {
    if (!_moreButton) {
        _moreButton = [[BaseButton alloc] init];
        _moreButton.backgroundColor = [UIColor clearColor];
        [_moreButton addTarget:self action:@selector(moreButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_moreButton setImage:[UIImage imageNamed:@"render_more" bundleName:HomeBundleName] forState:UIControlStateNormal];
        _moreButton.hidden = YES;
    }
    return _moreButton;
}

- (BaseButton *)maskButton {
    if (!_maskButton) {
        _maskButton = [[BaseButton alloc] init];
        _maskButton.backgroundColor = [UIColor clearColor];
        [_maskButton addTarget:self action:@selector(maskButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _maskButton;
}

- (UIImageView *)micImageView {
    if (!_micImageView) {
        _micImageView = [[UIImageView alloc] init];
        _micImageView.image = [UIImage imageNamed:@"guests_mic" bundleName:HomeBundleName];
    }
    return _micImageView;
}

- (UILabel *)userNameLabel {
    if (!_userNameLabel) {
        _userNameLabel = [[UILabel alloc] init];
        _userNameLabel.textColor = [UIColor whiteColor];
        _userNameLabel.font = [UIFont systemFontOfSize:11];
    }
    return _userNameLabel;
}

- (LiveRTCRenderView *)renderView {
    if (!_renderView) {
        _renderView = [[LiveRTCRenderView alloc] init];
    }
    return _renderView;
}

@end
