// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveCreateRoomControlView.h"

@interface LiveCreateRoomControlView ()
@property (nonatomic, strong) UIButton *switchCameraButton;
@property (nonatomic, strong) UIButton *beautyButton;
@property (nonatomic, strong) UIButton *settingButton;

@property (nonatomic, strong) UILabel *switchCameraLabel;
@property (nonatomic, strong) UILabel *beautyLabel;
@property (nonatomic, strong) UILabel *settingLabel;
@property (nonatomic, assign) BOOL isSwitchIcon;
@end

@implementation LiveCreateRoomControlView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = 15;
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.beautyButton];
        [self.beautyButton mas_makeConstraints:^(MASConstraintMaker *make) {
          make.top.mas_equalTo(20);
          make.centerX.equalTo(self);
        }];
        [self addSubview:self.beautyLabel];
        [self.beautyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
          make.top.equalTo(self.beautyButton.mas_bottom).offset(8);
          make.centerX.equalTo(self.beautyButton);
        }];

        [self addSubview:self.switchCameraButton];
        [self.switchCameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
          make.right.equalTo(self.beautyButton.mas_left).offset(-47);
          make.centerY.equalTo(self.beautyButton);
        }];
        [self addSubview:self.switchCameraLabel];
        [self.switchCameraLabel mas_makeConstraints:^(MASConstraintMaker *make) {
          make.centerY.equalTo(self.beautyLabel);
          make.centerX.equalTo(self.switchCameraButton);
        }];

        [self addSubview:self.settingButton];
        [self.settingButton mas_makeConstraints:^(MASConstraintMaker *make) {
          make.left.equalTo(self.beautyButton.mas_right).offset(47);
          make.centerY.equalTo(self.beautyButton);
        }];
        [self addSubview:self.settingLabel];
        [self.settingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
          make.centerY.equalTo(self.beautyLabel);
          make.centerX.equalTo(self.settingButton);
        }];
        _isSwitchIcon = NO;
    }
    return self;
}

#pragma mark - Private Action
- (void)switchCameraButtonClicked:(UIButton *)sender {
    self.isSwitchIcon = !self.isSwitchIcon;
    if(self.isSwitchIcon) {
        [self.switchCameraButton
         setImage:[UIImage imageNamed:@"InteractiveLive_switch_camera"
                           bundleName:HomeBundleName]
         forState:UIControlStateNormal];
    } else {
        [self.switchCameraButton
         setImage:[UIImage imageNamed:@"InteractiveLive_switch_camera_before"
                           bundleName:HomeBundleName]
         forState:UIControlStateNormal];
    }
    if ([self.delegate respondsToSelector:@selector(liveCreateRoomControlView:didClickedSwitchCameraButton:)]) {
        [self.delegate liveCreateRoomControlView:self didClickedSwitchCameraButton:sender];
    }
}

- (void)beautyButtonClicked:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(liveCreateRoomControlView:didClickedBeautyButton:)]) {
        [self.delegate liveCreateRoomControlView:self didClickedBeautyButton:sender];
    }
}

- (void)settingButtonClicked:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(liveCreateRoomControlView:didClickedSettingButton:)]) {
        [self.delegate liveCreateRoomControlView:self didClickedSettingButton:sender];
    }
}

#pragma mark - Getter

- (UIButton *)switchCameraButton {
    if (!_switchCameraButton) {
        _switchCameraButton = [[UIButton alloc] init];
        [_switchCameraButton setImage:[UIImage imageNamed:@"InteractiveLive_switch_camera_before" bundleName:HomeBundleName] forState:UIControlStateNormal];
        [_switchCameraButton addTarget:self action:@selector(switchCameraButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchCameraButton;
}

- (UIButton *)beautyButton {
    if (!_beautyButton) {
        _beautyButton = [[UIButton alloc] init];
        [_beautyButton setImage:[UIImage imageNamed:@"InteractiveLive_beauty" bundleName:HomeBundleName] forState:UIControlStateNormal];
        [_beautyButton addTarget:self action:@selector(beautyButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _beautyButton;
}

- (UIButton *)settingButton {
    if (!_settingButton) {
        _settingButton = [[UIButton alloc] init];
        [_settingButton setImage:[UIImage imageNamed:@"InteractiveLive_setting" bundleName:HomeBundleName] forState:UIControlStateNormal];
        [_settingButton addTarget:self action:@selector(settingButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _settingButton;
}

- (UILabel *)switchCameraLabel {
    if (!_switchCameraLabel) {
        _switchCameraLabel = [[UILabel alloc] init];
        _switchCameraLabel.font = [UIFont systemFontOfSize:12];
        _switchCameraLabel.textColor = [UIColor whiteColor];
        _switchCameraLabel.text = LocalizedString(@"flip");
    }
    return _switchCameraLabel;
}

- (UILabel *)beautyLabel {
    if (!_beautyLabel) {
        _beautyLabel = [[UILabel alloc] init];
        _beautyLabel.font = [UIFont systemFontOfSize:12];
        _beautyLabel.textColor = [UIColor whiteColor];
        _beautyLabel.text = LocalizedString(@"effect_button_message");
    }
    return _beautyLabel;
}

- (UILabel *)settingLabel {
    if (!_settingLabel) {
        _settingLabel = [[UILabel alloc] init];
        _settingLabel.font = [UIFont systemFontOfSize:12];
        _settingLabel.textColor = [UIColor whiteColor];
        _settingLabel.text = LocalizedString(@"settings");
    }
    return _settingLabel;
}
@end
