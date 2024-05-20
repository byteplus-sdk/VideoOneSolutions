// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "KTVRoomTopSelectView.h"

@interface KTVRoomTopSelectView ()

@property (nonatomic, strong) BaseButton *onlineButton;
@property (nonatomic, strong) BaseButton *appleButton;
@property (nonatomic, strong) UIView *selectLineView;
@property (nonatomic, strong) UIImageView *redImageView;
@property (nonatomic, strong) UIView *lineView;

@end

@implementation KTVRoomTopSelectView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorFromRGBHexString:@"#000000"];
        
        [self addSubview:self.onlineButton];
        [self addSubview:self.appleButton];
        [self addSubview:self.selectLineView];
        
        [self addConstraints];
        [self onlineButtonAction];
    }
    return self;
}

- (void)addConstraints {
    [self.onlineButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(16));
        make.bottom.height.equalTo(self);
    }];
    
    [self.appleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.onlineButton.mas_right).offset(16);
        make.bottom.height.equalTo(self);
    }];
    
    [self.selectLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(2);
        make.bottom.mas_equalTo(0);
        make.centerX.equalTo(self.onlineButton);
    }];
    
    [self addSubview:self.redImageView];
    [self.redImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(10, 10));
        make.top.mas_equalTo(12);
        make.centerX.equalTo(self.appleButton.mas_right);
    }];
    
    [self addSubview:self.lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.height.mas_equalTo(1);
        make.bottom.mas_equalTo(0);
    }];

}

- (void)setTitleStr:(NSString *)titleStr {
    _titleStr = titleStr;
    if (NOEmptyStr(titleStr)) {
        self.onlineButton.hidden = YES;
        self.appleButton.hidden = YES;
        self.selectLineView.hidden = YES;
    } else {
        self.onlineButton.hidden = NO;
        self.appleButton.hidden = NO;
        self.selectLineView.hidden = NO;
    }
}

- (void)onlineButtonAction {
    [self.onlineButton setTitleColor:[UIColor colorFromHexString:@"#FFFFFF"] forState:UIControlStateNormal];
    [self.appleButton setTitleColor:[UIColor colorFromHexString:@"#737A87"] forState:UIControlStateNormal];
    
    [self.selectLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(2);
        make.bottom.mas_equalTo(0);
        make.centerX.equalTo(self.onlineButton);
    }];
    
    if ([self.delegate respondsToSelector:@selector(KTVRoomTopSelectView:clickSwitchItem:)]) {
        [self.delegate KTVRoomTopSelectView:self clickSwitchItem:NO];
    }
}

- (void)appleButtonAction {
    [self.onlineButton setTitleColor:[UIColor colorFromHexString:@"#737A87"] forState:UIControlStateNormal];
    [self.appleButton setTitleColor:[UIColor colorFromHexString:@"#FFFFFF"] forState:UIControlStateNormal];
    
    [self.selectLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(2);
        make.bottom.mas_equalTo(0);
        make.centerX.equalTo(self.appleButton);
    }];
    
    if ([self.delegate respondsToSelector:@selector(KTVRoomTopSelectView:clickSwitchItem:)]) {
        [self.delegate KTVRoomTopSelectView:self clickSwitchItem:YES];
    }
}

- (void)cancelButtonAction {
    if ([self.delegate respondsToSelector:@selector(KTVRoomTopSelectView:clickCancelAction:)]) {
        [self.delegate KTVRoomTopSelectView:self clickCancelAction:@""];
    }
}

- (void)updateWithRed:(BOOL)isRed {
    self.redImageView.hidden = !isRed;
}

- (void)updateSelectItem:(BOOL)isLeft {
    if (isLeft) {
        [self.onlineButton setTitleColor:[UIColor colorFromHexString:@"#FFFFFF"] forState:UIControlStateNormal];
        [self.appleButton setTitleColor:[UIColor colorFromHexString:@"#737A87"] forState:UIControlStateNormal];
        [self.selectLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(40);
            make.height.mas_equalTo(2);
            make.bottom.mas_equalTo(0);
            make.centerX.equalTo(self.onlineButton);
        }];
    } else {
        [self.onlineButton setTitleColor:[UIColor colorFromHexString:@"#737A87"] forState:UIControlStateNormal];
        [self.appleButton setTitleColor:[UIColor colorFromHexString:@"#FFFFFF"] forState:UIControlStateNormal];
        [self.selectLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(40);
            make.height.mas_equalTo(2);
            make.bottom.mas_equalTo(0);
            make.centerX.equalTo(self.appleButton);
        }];
    }
}

#pragma mark - getter

- (BaseButton *)onlineButton {
    if (!_onlineButton) {
        _onlineButton = [[BaseButton alloc] init];
        _onlineButton.backgroundColor = [UIColor clearColor];
        [_onlineButton setTitle:LocalizedString(@"button_user_list_title") forState:UIControlStateNormal];
        [_onlineButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _onlineButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_onlineButton addTarget:self action:@selector(onlineButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _onlineButton;
}

- (BaseButton *)appleButton {
    if (!_appleButton) {
        _appleButton = [[BaseButton alloc] init];
        _appleButton.backgroundColor = [UIColor clearColor];
        [_appleButton setTitle:LocalizedString(@"button_raise_hand_list_title") forState:UIControlStateNormal];
        [_appleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _appleButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_appleButton addTarget:self action:@selector(appleButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _appleButton;
}

- (UIView *)selectLineView {
    if (!_selectLineView) {
        _selectLineView = [[UIView alloc] init];
        _selectLineView.backgroundColor = [UIColor colorFromRGBHexString:@"#FFFFFF"];
    }
    return _selectLineView;
}

- (UIImageView *)redImageView {
    if (!_redImageView) {
        _redImageView = [[UIImageView alloc] init];
        _redImageView.image = [UIImage imageNamed:@"KTV_bottom_red" bundleName:HomeBundleName];
        _redImageView.hidden = YES;
    }
    return _redImageView;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.15 * 255];
    }
    return _lineView;
}

@end
