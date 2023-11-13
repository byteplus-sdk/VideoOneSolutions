// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEInterfaceSlideButtonCell.h"
#import "Masonry.h"
#import "UIView+VEElementDescripition.h"
#import "VEInterfaceElementDescription.h"

@implementation VEInterfaceSlideButtonCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initializeElements];
    }
    return self;
}

- (void)initializeElements {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.button];
    [self.contentView addSubview:self.titleLabel];
    
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView);
        make.leading.equalTo(self.contentView);
        make.size.equalTo(@(CGSizeMake(24+14, 24+12)));
    }];
    self.button.contentEdgeInsets = UIEdgeInsetsMake(0, 7, 6, 7);
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.button.mas_bottom);
        make.centerX.equalTo(self.button);
    }];
    [self.button addTarget:self action:@selector(onButtonPressed) forControlEvents:UIControlEventTouchUpInside];
}

- (void)onButtonPressed {
    if (self.elementDescription.elementNotify) {
        self.elementDescription.elementNotify(self.button, @"button", @(YES));
    }
}

#pragma mark ----- Lazy Load
- (UIButton *)button {
    if (!_button) {
        _button = [UIButton new];
    }
    return _button;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.highlighted = YES;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:12.0];
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}
@end
