// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "ChorusEmptyComponent.h"

@interface ChorusEmptyComponent ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *messageLabel;

@end

@implementation ChorusEmptyComponent

- (instancetype)initWithView:(UIView *)view
                        rect:(CGRect)rect
                       image:(UIImage *)image
                     message:(NSString *)message {
    self = [super init];
    if (self) {
        [view addSubview:self.iconImageView];
        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(rect.size);
            make.top.equalTo(@(rect.origin.y));
            make.centerX.equalTo(view);
        }];
        
        [view addSubview:self.messageLabel];
        [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.iconImageView.mas_bottom).offset(12);
            make.centerX.equalTo(view);
            make.width.mas_lessThanOrEqualTo(SCREEN_WIDTH - 24);
        }];
        
        if (image) {
            self.iconImageView.image = image;
        } else {
            self.iconImageView.image = [UIImage imageNamed:@"room_list_empty" bundleName:HomeBundleName];
        }
        self.messageLabel.text = message;
        [self dismiss];
    }
    return self;
}

#pragma mark - Publish Action

- (void)updateMessageLabelTextColor:(UIColor *)color {
    self.messageLabel.textColor = color;
}

- (void)show {
    self.messageLabel.hidden = NO;
    self.iconImageView.hidden = NO;
}

- (void)dismiss {
    self.messageLabel.hidden = YES;
    self.iconImageView.hidden = YES;
}

#pragma mark - Getter

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
    }
    return _iconImageView;
}

- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.font = [UIFont systemFontOfSize:16];
        _messageLabel.textColor = [UIColor colorFromHexString:@"#000000"];
        _messageLabel.numberOfLines = 0;
        _messageLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _messageLabel;
}


@end
