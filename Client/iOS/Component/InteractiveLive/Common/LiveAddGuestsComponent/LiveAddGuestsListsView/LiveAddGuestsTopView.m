// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveAddGuestsTopView.h"

@interface LiveAddGuestsTopView ()

@property (nonatomic, strong) BaseButton *basicButton;
@property (nonatomic, strong) BaseButton *realTimeButton;
@property (nonatomic, strong) BaseButton *tipButton;
@property (nonatomic, strong) UIView *selectLineView;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIView *tipView;

@end

@implementation LiveAddGuestsTopView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];

        [self addSubview:self.basicButton];
        [self addSubview:self.realTimeButton];
        [self addSubview:self.tipButton];
        [self addSubview:self.selectLineView];
        [self addSubview:self.lineView];
        [self addSubview:self.tipView];

        [self addConstraints];
    }
    return self;
}

#pragma mark - Publish Action

- (void)simulateClick:(NSInteger)row {
    if (row == 1) {
        [self realTimeButtonAction];
    }
}

- (void)setIsUnread:(BOOL)isUnread {
    _isUnread = isUnread;
    self.tipView.hidden = isUnread ? NO : YES;
}

#pragma mark - Private Action

- (void)addConstraints {
    [self.basicButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.height.equalTo(self);
        make.left.mas_equalTo(16);
    }];

    [self.realTimeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.height.equalTo(self);
        make.left.equalTo(self.basicButton.mas_right).offset(24);
    }];

    [self.tipButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(22, 22));
        make.top.mas_equalTo(self).offset(12);
        make.right.mas_equalTo(self).offset(-16);
    }];

    [self.selectLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(2);
        make.bottom.mas_equalTo(-2);
        make.centerX.equalTo(self.basicButton);
    }];

    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.bottom.mas_equalTo(-1);
        make.height.mas_equalTo(1);
    }];

    [self.tipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(8, 8));
        make.top.equalTo(self.realTimeButton.titleLabel);
        make.left.equalTo(self.realTimeButton.mas_right);
    }];
}

- (void)basicButtonAction {
    [self.basicButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.realTimeButton setTitleColor:[UIColor colorFromHexString:@"#80838A"] forState:UIControlStateNormal];
    self.basicButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
    self.realTimeButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];

    [UIView animateWithDuration:0.25 animations:^{
        [self.selectLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(40);
            make.height.mas_equalTo(2);
            make.bottom.mas_equalTo(-2);
            make.centerX.equalTo(self.basicButton);
        }];
        [self.selectLineView.superview layoutIfNeeded];
    }];

    if ([self.delegate respondsToSelector:@selector(LiveAddGuestsTopView:clickSwitchItem:)]) {
        [self.delegate LiveAddGuestsTopView:self clickSwitchItem:0];
    }
}

- (void)realTimeButtonAction {
    [self.realTimeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.basicButton setTitleColor:[UIColor colorFromHexString:@"#80838A"] forState:UIControlStateNormal];
    self.basicButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    self.realTimeButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];

    [UIView animateWithDuration:0.25 animations:^{
        [self.selectLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(40);
            make.height.mas_equalTo(2);
            make.bottom.mas_equalTo(-2);
            make.centerX.equalTo(self.realTimeButton);
        }];
        [self.selectLineView.superview layoutIfNeeded];
    }];

    if ([self.delegate respondsToSelector:@selector(LiveAddGuestsTopView:clickSwitchItem:)]) {
        [self.delegate LiveAddGuestsTopView:self clickSwitchItem:1];
    }
}

- (void)tipButtonAction {
    self.tipButton.userInteractionEnabled = NO;
    __weak __typeof(self) wself = self;
    [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"media_error_message") block:^(BOOL result) {
        wself.tipButton.userInteractionEnabled = YES;
    }];
}

#pragma mark - Getter

- (UIView *)tipView {
    if (!_tipView) {
        _tipView = [[UIView alloc] init];
        _tipView.backgroundColor = [UIColor colorFromHexString:@"#F5B433"];
        _tipView.layer.cornerRadius = 4;
        _tipView.layer.masksToBounds = YES;
        _tipView.hidden = YES;
    }
    return _tipView;
}

- (BaseButton *)basicButton {
    if (!_basicButton) {
        _basicButton = [[BaseButton alloc] init];
        _basicButton.backgroundColor = [UIColor clearColor];
        [_basicButton setTitle:LocalizedString(@"co-host") forState:UIControlStateNormal];
        [_basicButton setTitleColor:[UIColor colorFromHexString:@"#FFFFFF"] forState:UIControlStateNormal];
        _basicButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
        [_basicButton addTarget:self action:@selector(basicButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _basicButton;
}

- (BaseButton *)realTimeButton {
    if (!_realTimeButton) {
        _realTimeButton = [[BaseButton alloc] init];
        _realTimeButton.backgroundColor = [UIColor clearColor];
        [_realTimeButton setTitle:LocalizedString(@"co-host_application") forState:UIControlStateNormal];
        [_realTimeButton setTitleColor:[UIColor colorFromHexString:@"#80838A"] forState:UIControlStateNormal];
        _realTimeButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_realTimeButton addTarget:self action:@selector(realTimeButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _realTimeButton;
}

- (BaseButton *)tipButton {
    if (!_tipButton) {
        _tipButton = [[BaseButton alloc] init];
        _tipButton.backgroundColor = [UIColor clearColor];
        UIImage *imageIcon = [UIImage imageNamed:@"co-host_question_mark_circle" bundleName:HomeBundleName];
        [_tipButton setImage:imageIcon forState:UIControlStateNormal];
        [_tipButton addTarget:self action:@selector(tipButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _tipButton;
}

- (UIView *)selectLineView {
    if (!_selectLineView) {
        _selectLineView = [[UIView alloc] init];
        _selectLineView.backgroundColor = [UIColor whiteColor];
    }
    return _selectLineView;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.15 * 255];
    }
    return _lineView;
}

@end
