// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LivePeopleNumView.h"

@interface LivePeopleNumView ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation LivePeopleNumView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.iconImageView];
        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(11, 11));
            make.left.mas_equalTo(8);
            make.centerY.equalTo(self);
        }];

        [self addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(self.iconImageView.mas_right).offset(8);
        }];

        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.titleLabel.mas_right).offset(8);
        }];
    }
    return self;
}

- (void)updateTitleLabel:(NSInteger)num {
    NSString *str = [NSString stringWithFormat:@"%ld", (long)num];
    if (num >= 10000) {
        CGFloat value = floorf(num / 1000.0);
        str = [NSString stringWithFormat:@"%.1fW", value / 10];
    } else if (num >= 1000) {
        CGFloat value = floorf(num / 100.0);
        str = [NSString stringWithFormat:@"%.1fk", value / 10];
    }
    self.titleLabel.text = str;
}

#pragma mark - Getter

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightBold];
        _titleLabel.alpha = 0.75;
    }
    return _titleLabel;
}

- (UIImageView *)iconImageView {
    if (_iconImageView == nil) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.image = [UIImage imageNamed:@"InteractiveLive_people_num" bundleName:HomeBundleName];
    }
    return _iconImageView;
}

@end
