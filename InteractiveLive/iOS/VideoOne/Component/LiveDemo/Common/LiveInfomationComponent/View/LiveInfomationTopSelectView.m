// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveInfomationTopSelectView.h"

@interface LiveInfomationTopSelectView ()

@property (nonatomic, strong) BaseButton *basicButton;
@property (nonatomic, strong) BaseButton *realTimeButton;
@property (nonatomic, strong) UIView *selectLineView;
@property (nonatomic, strong) UIView *lineView;

@end

@implementation LiveInfomationTopSelectView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];

        [self addSubview:self.basicButton];
        [self addSubview:self.realTimeButton];
        [self addSubview:self.selectLineView];
        [self addSubview:self.lineView];

        [self addConstraints];
    }
    return self;
}

- (void)addConstraints {
    [self.basicButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.height.equalTo(self);
        make.left.mas_equalTo(16);
    }];

    [self.realTimeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.height.equalTo(self);
        make.left.equalTo(self.basicButton.mas_right).offset(24);
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
}

- (void)basicButtonAction {
    [self.basicButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.realTimeButton setTitleColor:[UIColor colorFromHexString:@"#80838A"] forState:UIControlStateNormal];
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.selectLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
          make.width.mas_equalTo(40);
          make.height.mas_equalTo(2);
          make.bottom.mas_equalTo(-2);
          make.centerX.equalTo(self.basicButton);
        }];
        [self.selectLineView.superview layoutIfNeeded];
    }];

    if ([self.delegate respondsToSelector:@selector(LiveInfomationTopSelectView:clickSwitchItem:)]) {
        [self.delegate LiveInfomationTopSelectView:self clickSwitchItem:0];
    }
}

- (void)realTimeButtonAction {
    [self.realTimeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.basicButton setTitleColor:[UIColor colorFromHexString:@"#80838A"] forState:UIControlStateNormal];

    [UIView animateWithDuration:0.25 animations:^{
        [self.selectLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
          make.width.mas_equalTo(40);
          make.height.mas_equalTo(2);
          make.bottom.mas_equalTo(-2);
          make.centerX.equalTo(self.realTimeButton);
        }];
        [self.selectLineView.superview layoutIfNeeded];
    }];
    

    if ([self.delegate respondsToSelector:@selector(LiveInfomationTopSelectView:clickSwitchItem:)]) {
        [self.delegate LiveInfomationTopSelectView:self clickSwitchItem:1];
    }
}

#pragma mark - Getter

- (BaseButton *)basicButton {
    if (!_basicButton) {
        _basicButton = [[BaseButton alloc] init];
        _basicButton.backgroundColor = [UIColor clearColor];
        [_basicButton setTitle:LocalizedString(@"Basic information") forState:UIControlStateNormal];
        [_basicButton setTitleColor:[UIColor colorFromHexString:@"#FFFFFF"] forState:UIControlStateNormal];
        _basicButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_basicButton addTarget:self action:@selector(basicButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _basicButton;
}

- (BaseButton *)realTimeButton {
    if (!_realTimeButton) {
        _realTimeButton = [[BaseButton alloc] init];
        _realTimeButton.backgroundColor = [UIColor clearColor];
        [_realTimeButton setTitle:LocalizedString(@"Real-time information") forState:UIControlStateNormal];
        [_realTimeButton setTitleColor:[UIColor colorFromHexString:@"#80838A"] forState:UIControlStateNormal];
        _realTimeButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_realTimeButton addTarget:self action:@selector(realTimeButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _realTimeButton;
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
