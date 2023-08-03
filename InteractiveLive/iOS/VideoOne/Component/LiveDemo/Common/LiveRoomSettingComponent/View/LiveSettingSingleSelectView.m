// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveSettingSingleSelectView.h"

@interface LiveSettingSingleSelectView ()

@property (nonatomic, strong) UILabel *leftLabel;

@property (nonatomic, strong) UIButton *selectedButton;

@property (nonatomic, strong) UIImageView *moreImageView;

@end

@implementation LiveSettingSingleSelectView

- (instancetype)initWithTitle:(NSString *)title {
    if (self = [super init]) {
        self.leftLabel.text = title;
        [self addSubview:self.leftLabel];
        [self.leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(60);
            make.left.mas_equalTo(16);
            make.centerY.equalTo(self);
        }];
        
        [self addSubview:self.moreImageView];
        [self.moreImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(24, 28));
            make.right.mas_equalTo(-16);
            make.centerY.equalTo(self);
        }];
        
        [self addSubview:self.selectedButton];
        [self.selectedButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.moreImageView.mas_left);
            make.centerY.equalTo(self);
        }];
    }
    return self;
}


#pragma mark - Publish Action

- (void)setValueString:(NSString *)valueString {
    _valueString = valueString;
    [self.selectedButton setTitle:valueString forState:UIControlStateNormal];
}

- (void)selectedButtonAction {
    if (self.itemClickBlock) {
        self.itemClickBlock();
    }
}

#pragma mark - Getter

- (UIButton *)selectedButton {
    if (!_selectedButton) {
        _selectedButton = [[UIButton alloc] init];
        _selectedButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        [_selectedButton setTitleColor:[UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.75 * 255] forState:UIControlStateNormal];
        [_selectedButton addTarget:self action:@selector(selectedButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectedButton;
}

- (UILabel *)leftLabel {
    if (!_leftLabel) {
        _leftLabel = [[UILabel alloc] init];
        _leftLabel.textColor = [UIColor colorFromHexString:@"#FFFFFF"];
        _leftLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
        _leftLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _leftLabel;
}

- (UIImageView *)moreImageView {
    if (!_moreImageView) {
        _moreImageView = [[UIImageView alloc] init];
        _moreImageView.image = [UIImage imageNamed:@"setting_more" bundleName:HomeBundleName];
    }
    return _moreImageView;
}

@end
