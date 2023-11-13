// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveStateIconView.h"
#import "ToolKit.h"

@interface LiveStateIconView ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *messageLabel;

@end

@implementation LiveStateIconView

- (instancetype)initWithState:(LiveIconState)state {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];

        [self addSubview:self.iconImageView];
        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(15, 15));
            make.left.mas_equalTo(0);
            make.centerY.equalTo(self);
        }];

        [self addSubview:self.messageLabel];
        [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconImageView.mas_right).offset(4);
            make.right.centerY.equalTo(self);
        }];

        [self updateUI:state];
    }
    return self;
}

- (void)updateState:(LiveIconState)state {
    [self updateUI:state];
}

- (void)updateUI:(LiveIconState)state {
    CGFloat itemWidth = 0;
    switch (state) {
        case LiveIconStateHidden:
            self.messageLabel.text = nil;
            self.iconImageView.image = nil;
            break;
        case LiveIconStateNetQuality:
            self.messageLabel.text = LocalizedString(@"net_excellent");
            self.iconImageView.image = [UIImage imageNamed:@"InteractiveLive_net" bundleName:HomeBundleName];
            itemWidth = 15;
            break;
        case LiveIconStateNetQualityBad:
            self.messageLabel.text = LocalizedString(@"net_stuck_stopped");
            self.iconImageView.image = [UIImage imageNamed:@"InteractiveLive_net_bad" bundleName:HomeBundleName];
            itemWidth = 15;
            break;
        case LiveIconStateMic:
            self.messageLabel.text = LocalizedString(@"mic_off");
            self.iconImageView.image = [UIImage imageNamed:@"InteractiveLive_mic_icon" bundleName:HomeBundleName];
            itemWidth = 12;
            break;
        case LiveIconStateCamera:
            self.messageLabel.text = LocalizedString(@"camera_closed");
            self.iconImageView.image = [UIImage imageNamed:@"InteractiveLive_camera_icon" bundleName:HomeBundleName];
            itemWidth = 12;
            break;
        default:
            break;
    }

    [self.iconImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(itemWidth, itemWidth));
    }];

    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.messageLabel.mas_right);
    }];
}

#pragma mark - Getter

- (UIImageView *)iconImageView {
    if (_iconImageView == nil) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _iconImageView;
}

- (UILabel *)messageLabel {
    if (_messageLabel == nil) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.textColor = [UIColor whiteColor];
        _messageLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        _messageLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _messageLabel;
}

@end
