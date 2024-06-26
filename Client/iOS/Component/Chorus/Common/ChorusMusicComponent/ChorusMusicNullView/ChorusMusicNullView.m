// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "ChorusMusicNullView.h"

@interface ChorusMusicNullView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) BaseButton *button;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation ChorusMusicNullView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [self addSubview:self.button];
        [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(110, 110));
            make.centerX.equalTo(self);
            make.top.equalTo(self).offset(0);
        }];
        
        [self addSubview:self.titleLabel];
        
        self.titleLabel.text = LocalizedString(@"label_no_singing_audience_tip");
        self.button.hidden = NO;
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self.button.mas_bottom).offset(-8);
        }];
    }
    return self;
}

#pragma mark - Getter

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        _titleLabel.textColor = [UIColor colorFromHexString:@"#C7CCD6"];
        _titleLabel.userInteractionEnabled = NO;
    }
    return _titleLabel;
}

- (BaseButton *)button {
    if (!_button) {
        _button = [[BaseButton alloc] init];
        [_button setBackgroundColor:[UIColor clearColor]];
        [_button setImage:[UIImage imageNamed:@"music_null_play" bundleName:HomeBundleName] forState:UIControlStateNormal];
        _button.hidden = YES;
        _button.userInteractionEnabled = NO;
    }
    return _button;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.image = [UIImage imageNamed:@"music_null_bg" bundleName:HomeBundleName];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

@end
