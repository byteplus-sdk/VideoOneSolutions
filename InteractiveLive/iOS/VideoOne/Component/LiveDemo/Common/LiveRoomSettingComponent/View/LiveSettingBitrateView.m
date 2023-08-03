// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveSettingBitrateView.h"

@interface LiveSettingBitrateView ()

@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UILabel *bitrateLabel;
@property (nonatomic, strong) UILabel *rightLabel;
@property (nonatomic, strong) UISlider *slider;

@end

@implementation LiveSettingBitrateView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.leftLabel];
        [self.leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
          make.top.mas_equalTo(0);
          make.left.mas_equalTo(16);
        }];

        [self addSubview:self.rightLabel];
        [self.rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
          make.centerY.equalTo(self.leftLabel);
          make.right.mas_equalTo(-16);
        }];

        [self addSubview:self.bitrateLabel];
        [self.bitrateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
          make.centerY.equalTo(self.leftLabel);
          make.right.equalTo(self.rightLabel.mas_left).offset(-8);
        }];

        [self addSubview:self.slider];
        [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
          make.top.equalTo(self.leftLabel.mas_bottom).offset(16);
          make.left.mas_equalTo(16);
          make.right.mas_equalTo(-16);
        }];
    }
    return self;
}

- (void)setBitrate:(NSInteger)bitrate {
    _bitrate = bitrate;
    self.slider.value = (_bitrate - self.minBitrate) * 1.0 / (self.maxBitrate - self.minBitrate);
    self.bitrateLabel.text = [NSString stringWithFormat:@"%ld", bitrate];
}

- (void)sliderValueChanged:(UISlider *)slider {
    NSInteger bitrate = slider.value * (self.maxBitrate - self.minBitrate) + self.minBitrate;
    self.bitrate = bitrate;

    if (self.bitrateDidChangedBlock) {
        self.bitrateDidChangedBlock(bitrate);
    }
}

#pragma mark - Getter

- (UILabel *)leftLabel {
    if (!_leftLabel) {
        _leftLabel = [[UILabel alloc] init];
        _leftLabel.text = LocalizedString(@"video_bitrate");
        _leftLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
        _leftLabel.textColor = [UIColor whiteColor];
    }
    return _leftLabel;
}

- (UILabel *)rightLabel {
    if (!_rightLabel) {
        _rightLabel = [[UILabel alloc] init];
        _rightLabel.text = @"kpbs";
        _rightLabel.font = [UIFont systemFontOfSize:14];
        _rightLabel.textColor = [UIColor colorFromHexString:@"#80838A"];
    }
    return _rightLabel;
}

- (UISlider *)slider {
    if (!_slider) {
        _slider = [[UISlider alloc] init];
        [_slider setTintColor:[UIColor colorFromHexString:@"#FF1764"]];
        [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _slider;
}

- (UILabel *)bitrateLabel {
    if (!_bitrateLabel) {
        _bitrateLabel = [[UILabel alloc] init];
        _bitrateLabel.text = @"";
        _bitrateLabel.font = [UIFont systemFontOfSize:14];
        _bitrateLabel.textColor = [UIColor colorFromHexString:@"#FFFFFF"];
    }
    return _bitrateLabel;
}
@end
