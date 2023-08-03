// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveCreateRoomTipView.h"

@interface LiveCreateRoomTipView ()

@property (nonatomic, strong) UIImageView *tipImageView;
@property (nonatomic, strong) UILabel *tipLabel;
@end

@implementation LiveCreateRoomTipView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubview:self.tipImageView];
        [self.tipImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(12, 12));
            make.left.mas_equalTo(self).offset(8);
            make.centerY.mas_equalTo(self);
        }];

        [self addSubview:self.tipLabel];
        [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.tipImageView.mas_right).offset(6);
            make.right.mas_equalTo(self);
            make.top.mas_equalTo(self).offset(5);
            make.bottom.mas_equalTo(self).offset(-5);
        }];
    }
    return self;
}

- (void)setMessage:(NSString *)message {
    _message = message;
    self.tipLabel.text = message;
}

#pragma mark - Getter

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.font = [UIFont systemFontOfSize:12];
        _tipLabel.numberOfLines = 0;
        _tipLabel.textColor = [UIColor whiteColor];
    }
    return _tipLabel;
}

- (UIImageView *)tipImageView {
    if (!_tipImageView) {
        _tipImageView = [[UIImageView alloc] init];
        _tipImageView.image = [UIImage imageNamed:@"create_live_tip" bundleName:HomeBundleName];
        _tipImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _tipImageView;
}

@end
