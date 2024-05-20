// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "KTVMusicReverberationItemView.h"

@interface KTVMusicReverberationItemView ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIImageView *selectImageView;
@property (nonatomic, strong) UILabel *messageLabel;

@end

@implementation KTVMusicReverberationItemView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isSelect = NO;
        
        [self addSubview:self.iconImageView];
        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self);
            make.height.equalTo(@50);
        }];
        
        [self addSubview:self.selectImageView];
        [self.selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.iconImageView);
        }];
        
        [self addSubview:self.messageLabel];
        [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self.iconImageView.mas_bottom).offset(7.5);
            make.width.mas_lessThanOrEqualTo(50 + 18 + 18);
        }];
    }
    return self;
}

- (void)setMessage:(NSString *)message {
    _message = message;
    self.messageLabel.text = message;
}

- (void)setImageName:(NSString *)imageName {
    _imageName = imageName;
    
    self.iconImageView.image = [UIImage imageNamed:imageName bundleName:HomeBundleName];
}

- (void)setIsSelect:(BOOL)isSelect {
    _isSelect = isSelect;
    
    if (isSelect) {
        self.selectImageView.hidden = NO;
        self.messageLabel.textColor = [UIColor colorFromRGBHexString:@"#FF1764"];
    } else {
        self.selectImageView.hidden = YES;
        self.messageLabel.textColor = [UIColor colorFromRGBHexString:@"#FFFFFF"];
    }
}

#pragma mark - Getter

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.layer.cornerRadius = 25;
        _iconImageView.layer.masksToBounds = YES;
    }
    return _iconImageView;
}

- (UIImageView *)selectImageView {
    if (!_selectImageView) {
        _selectImageView = [[UIImageView alloc] init];
        _selectImageView.image = [UIImage imageNamed:@"reverberation_button_s" bundleName:HomeBundleName];
    }
    return _selectImageView;
}

- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.textColor = [UIColor whiteColor];
        _messageLabel.font = [UIFont systemFontOfSize:12];
        _messageLabel.userInteractionEnabled = NO;
        _messageLabel.numberOfLines = 2;
        _messageLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _messageLabel;
}

@end
