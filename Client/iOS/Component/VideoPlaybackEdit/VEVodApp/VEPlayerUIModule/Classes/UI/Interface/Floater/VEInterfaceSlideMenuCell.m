// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEInterfaceSlideMenuCell.h"
#import "Masonry.h"
#import "UIView+VEElementDescripition.h"
#import "VEInterfaceElementDescription.h"
#import <ToolKit/UIColor+String.h>

@implementation VEInterfaceSlideMenuCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initializeElements];
    }
    return self;
}

- (void)initializeElements {
    self.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.leftButton];
    [self.contentView addSubview:self.rightButton];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(8);
        make.leading.equalTo(self.contentView);
    }];

    [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView);
        make.trailing.equalTo(self.contentView.mas_centerX).offset(-3);
        make.bottom.equalTo(self).offset(-8);
        make.height.equalTo(@(40.0));
    }];

    [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.contentView);
        make.leading.equalTo(self.contentView.mas_centerX).offset(3);
        make.height.equalTo(@(40.0));
        make.bottom.equalTo(self.leftButton);
    }];
    [self highlightLeftButton:YES];
    [self.leftButton addTarget:self action:@selector(onLeftButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.rightButton addTarget:self action:@selector(onRightButtonPressed) forControlEvents:UIControlEventTouchUpInside];
}

- (void)highlightLeftButton:(BOOL)left {
    self.leftButton.backgroundColor = left ? [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.12 * 255] : [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.04 * 255];
    self.rightButton.backgroundColor = !left ? [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.12 * 255] : [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.04 * 255];
    self.leftButton.layer.borderWidth = left ? 1 : 0;
    self.rightButton.layer.borderWidth = !left ? 1 : 0;
}

- (void)onLeftButtonPressed {
    if (self.elementDescription.elementNotify) {
        self.elementDescription.elementNotify(self.leftButton, @"leftButton", @(YES));
    }
    [self highlightLeftButton:YES];
}

- (void)onRightButtonPressed {
    if (self.elementDescription.elementNotify) {
        self.elementDescription.elementNotify(self.rightButton, @"rightButton", @(NO));
    }
    [self highlightLeftButton:NO];
}

#pragma mark----- Lazy Load

- (UIButton *)leftButton {
    if (!_leftButton) {
        _leftButton = [UIButton new];
        _leftButton.layer.cornerRadius = 6;
        _leftButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _leftButton.layer.borderColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.3 * 255].CGColor;
    }
    return _leftButton;
}

- (UIButton *)rightButton {
    if (!_rightButton) {
        _rightButton = [UIButton new];
        _rightButton.layer.cornerRadius = 6;
        _rightButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _rightButton.layer.borderColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.3 * 255].CGColor;
    }
    return _rightButton;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.highlighted = YES;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:12.0];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.tintColor = [UIColor lightGrayColor];
    }
    return _titleLabel;
}

@end
