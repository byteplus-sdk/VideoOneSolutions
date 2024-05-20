// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "KTVPickSongTopView.h"

@interface KTVPickSongTopView ()

@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIButton *onlineButton;
@property (nonatomic, strong) UIButton *pickedButton;
@property (nonatomic, strong) UIView *selectedView;

@end

@implementation KTVPickSongTopView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
        
        [self buttonClick:self.onlineButton];
    }
    return self;
}

- (void)setupViews {
    [self addSubview:self.lineView];
    [self addSubview:self.onlineButton];
    [self addSubview:self.pickedButton];
    [self addSubview:self.selectedView];
    
    [self.onlineButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self);
        make.left.equalTo(@(16));
        make.height.mas_equalTo(48);
    }];
    
    [self.pickedButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self);
        make.left.equalTo(self.onlineButton.mas_right).offset(24);
        make.height.mas_equalTo(48);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.bottom.equalTo(self.pickedButton);
        make.height.mas_equalTo(1);
    }];
}

#pragma mark - action
- (void)buttonClick:(UIButton *)button {
    NSInteger index = 0;
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    if (button == self.onlineButton) {
        [self.pickedButton setTitleColor:[UIColor colorFromHexString:@"#737A87"] forState:UIControlStateNormal];
    } else {
        index = 1;
        [self.onlineButton setTitleColor:[UIColor colorFromHexString:@"#737A87"] forState:UIControlStateNormal];
    }
    [self.selectedView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(button);
        make.bottom.equalTo(self.onlineButton).offset(0);
        make.size.mas_equalTo(CGSizeMake(64, 2));
    }];
    
    if (self.selectedChangedBlock) {
        self.selectedChangedBlock(index);
    }
}

- (void)updatePickedSongCount:(NSInteger)count {
    if (count == 0) {
        [_pickedButton setTitle:LocalizedString(@"button_karaoke_station_pick_song") forState:UIControlStateNormal];
    } else {
        [_pickedButton setTitle:[NSString stringWithFormat:LocalizedString(@"button_karaoke_station_pick_song_%@"), @(count).stringValue] forState:UIControlStateNormal];
    }
}

- (void)changedSelectIndex:(NSInteger)index {
    UIButton *button = index == 0 ? self.onlineButton : self.pickedButton;
    [self buttonClick:button];
}

#pragma mark - Getter

- (UIButton *)onlineButton {
    if (!_onlineButton) {
        _onlineButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _onlineButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_onlineButton setTitle:LocalizedString(@"button_music_list_title") forState:UIControlStateNormal];
        [_onlineButton setTitleColor:[UIColor colorFromHexString:@"#4080FF"] forState:UIControlStateNormal];
        [_onlineButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _onlineButton;
}

- (UIButton *)pickedButton {
    if (!_pickedButton) {
        _pickedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _pickedButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_pickedButton setTitle:LocalizedString(@"button_karaoke_station_pick_song") forState:UIControlStateNormal];
        [_pickedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_pickedButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pickedButton;
}

- (UIView *)selectedView {
    if (!_selectedView) {
        _selectedView = [[UIView alloc] init];
        _selectedView.backgroundColor = [UIColor colorFromHexString:@"#FFFFFF"];
    }
    return _selectedView;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor colorFromHexString:@"#2A2441"];
    }
    return _lineView;
}

@end
