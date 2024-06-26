// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import "ChorusNetworkQualityView.h"

@interface ChorusNetworkQualityView ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *messageLabel;

@end

@implementation ChorusNetworkQualityView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorFromRGBHexString:@"#000000" andAlpha:0.3 * 255];
        self.layer.cornerRadius = 4;
        self.layer.masksToBounds = YES;
        
        [self addSubview:self.iconImageView];
        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(8, 8));
            make.left.mas_equalTo(6);
            make.centerY.equalTo(self);
        }];

        [self addSubview:self.messageLabel];
        [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconImageView.mas_right).offset(4);
            make.centerY.equalTo(self);
            make.right.equalTo(self).offset(-6);
        }];
        
        [self updateNetworkQualityStstus:ChorusNetworkQualityStatusGood];
    }
    return self;
}

- (void)updateNetworkQualityStstus:(ChorusNetworkQualityStatus)status {
    switch (status) {
        case ChorusNetworkQualityStatusGood:
        case ChorusNetworkQualityStatusNone:
            self.messageLabel.text = LocalizedString(@"label_net_good");
            self.iconImageView.image = [UIImage imageNamed:@"chorus_net_good" bundleName:HomeBundleName];
            break;
        case ChorusNetworkQualityStatusPoor:
            self.messageLabel.text = LocalizedString(@"label_net_stuck");
            self.iconImageView.image = [UIImage imageNamed:@"chorus_net_bad" bundleName:HomeBundleName];
            break;
        case ChorusNetworkQualityStatusBad:
            self.messageLabel.text = LocalizedString(@"label_net_disconnect");
            self.iconImageView.image = [UIImage imageNamed:@"chorus_net_dis" bundleName:HomeBundleName];
            break;
            
        default:
            break;
    }
}

#pragma mark - getter

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
    }
    return _messageLabel;
}

@end
