//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "VEInterfaceSocialButton+Extension.h"
#import <Masonry/Masonry.h>

@implementation VEInterfaceSocialButton

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame axis:UILayoutConstraintAxisHorizontal];
}

- (instancetype)initWithFrame:(CGRect)frame axis:(UILayoutConstraintAxis)axis {
    self = [super initWithFrame:frame];
    if (self) {
        self.axis = axis;
        if (self.axis == UILayoutConstraintAxisVertical) {
            [self addSubview:self.titleLabel];
            [self addSubview:self.imageView];
            [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.leading.trailing.equalTo(self);
                make.size.mas_equalTo(40);
            }];
            [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.imageView.mas_bottom).offset(2);
                make.bottom.centerX.equalTo(self);
                make.height.mas_equalTo(20);
            }];
        } else {
            [self addSubview:self.imageView];
            [self addSubview:self.titleLabel];
            [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
                make.size.mas_equalTo(40);
            }];
            [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(self.imageView).offset(22);
                make.bottom.equalTo(self.imageView).offset(-8);
            }];
        }
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    ((UIImageView *)(self.imageView)).image = image;
}

- (UIImage *)image {
    return ((UIImageView *)(self.imageView)).image;
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
    if (self.axis == UILayoutConstraintAxisVertical) {
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            if (title.length > 0) {
                make.top.equalTo(self.imageView.mas_bottom).offset(2);
                make.height.mas_equalTo(20);
            } else {
                make.top.equalTo(self.imageView.mas_bottom).offset(0);
                make.height.mas_equalTo(0);
            }
        }];
    }
}

- (NSString *)title {
    return self.titleLabel.text;
}

#pragma mark----- Lazy Load
- (UIView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines = 1;
        if (self.axis == UILayoutConstraintAxisVertical) {
            _titleLabel.font = [UIFont systemFontOfSize:14];
        } else {
            _titleLabel.font = [UIFont systemFontOfSize:10 weight:UIFontWeightBold];
        }
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}

@end
