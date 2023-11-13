// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveListEmptyView.h"

@interface LiveListEmptyView ()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *messageLabel;

@property (nonatomic, strong) UILabel *describeLabel;

@end

@implementation LiveListEmptyView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.imageView];
        [self addSubview:self.messageLabel];
        [self addSubview:self.describeLabel];

        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100, 100));
            make.top.equalTo(self);
            make.centerX.equalTo(self);
        }];

        [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self.imageView.mas_bottom).offset(2);
        }];

        [self.describeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self.messageLabel.mas_bottom).offset(4);
            make.bottom.equalTo(self);
        }];
    }
    return self;
}

#pragma mark - Publish Action

- (void)setMessageString:(NSString *)messageString {
    _messageString = messageString;
    self.messageLabel.text = messageString;
}

- (void)setDescribeString:(NSString *)describeString {
    _describeString = describeString;
    self.describeLabel.text = describeString;
}

#pragma mark - Getter

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.image = [UIImage imageNamed:@"list_empty" bundleName:HomeBundleName];
    }
    return _imageView;
}

- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.textColor = [UIColor whiteColor];
        _messageLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
    }
    return _messageLabel;
}

- (UILabel *)describeLabel {
    if (!_describeLabel) {
        _describeLabel = [[UILabel alloc] init];
        _describeLabel.textColor = [UIColor colorFromHexString:@"#80838A"];
        _describeLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    }
    return _describeLabel;
}

@end
