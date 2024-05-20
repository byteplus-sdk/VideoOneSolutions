// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELSettingsButtonView.h"
@interface VELSettingsButtonView ()
@property (nonatomic, strong) VELUIButton *button;
@property (nonatomic, strong) UIView *pointView;
@property (nonatomic, strong) UIView *btnContainer;
@property (nonatomic, strong) UIImageView *accessoryView;
@end

@implementation VELSettingsButtonView
- (void)setModel:(VELSettingsButtonViewModel *)model {
    if (![model isKindOfClass:VELSettingsButtonViewModel.class]) {
        return;
    }
    [super setModel:model];
}

- (void)initSubviewsInContainer:(UIView *)container {
    [container addSubview:self.btnContainer];
    [container addSubview:self.accessoryView];
}

- (void)layoutSubViewWithModel {
    [super layoutSubViewWithModel];
    if (self.model.rightAccessory == nil) {
        [self.btnContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.container).mas_offset(self.model.insets.top);
            make.left.equalTo(self.container).mas_offset(self.model.insets.left);
            make.bottom.equalTo(self.container).mas_offset(-self.model.insets.bottom);
            make.right.equalTo(self.container).mas_offset(-self.model.insets.right);
        }];
        [self.accessoryView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(self.model.accessorySize);
        }];
    } else {
        [self.btnContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.container).mas_offset(self.model.insets.top);
            make.left.equalTo(self.container).mas_offset(self.model.insets.left);
            make.bottom.equalTo(self.container).mas_offset(-self.model.insets.bottom);
        }];
        
        [self.accessoryView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.container);
            make.size.mas_equalTo(self.model.accessorySize);
            make.left.greaterThanOrEqualTo(self.btnContainer.mas_right).offset(8);
            make.right.equalTo(self.container).mas_offset(-self.model.insets.right);
        }];
    }
    
    if (self.model.showPoint) {
        [self.button mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.btnContainer);
            if (self.model.containerSize.width > 0) {
                make.width.mas_equalTo(self.model.containerSize.width).priorityMedium();
            }
        }];
        [self.pointView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.button.mas_bottom).mas_offset(self.model.spacingBetweenImageTitleAndPoint);
            make.centerX.equalTo(self.btnContainer);
            make.bottom.equalTo(self.btnContainer);
            make.size.mas_equalTo(self.model.pointSize);
        }];
    } else {
        [self.button mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.btnContainer);
            if (self.model.containerSize.width > 0) {
                make.width.mas_equalTo(self.model.containerSize.width).priorityMedium();
            }
        }];
        [self.pointView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(self.model.pointSize);
        }];
    }
}

- (void)updateSubViewStateWithModel {
    [super updateSubViewStateWithModel];
    [self.button setContentHorizontalAlignment:self.model.alignment];
    self.button.contentMode = self.model.contentMode;
    self.button.imageSize = self.model.imageSize;
    self.button.imagePosition = (VELUIButtonImagePosition)self.model.imagePosition;
    [self.button setImage:self.model.image forState:(UIControlStateNormal)];
    [self.button setImage:self.model.selectImage ?: self.model.image forState:(UIControlStateSelected)];
    NSAttributedString *attributeTitle = [[NSAttributedString alloc] initWithString:self.model.title?:@"" attributes:self.model.titleAttributes];
    [self.button setAttributedTitle:attributeTitle forState:(UIControlStateNormal)];
    attributeTitle = [[NSAttributedString alloc] initWithString:self.model.selectTitle?:self.model.title?:@"" attributes:self.model.selectTitleAttributes];
    [self.button setAttributedTitle:attributeTitle forState:(UIControlStateSelected)];
    self.button.spacingBetweenImageAndTitle = self.model.spacingBetweenImageAndTitle;
    self.pointView.hidden = !self.model.showPoint;
    self.pointView.backgroundColor = self.model.pointColor;
    self.pointView.layer.cornerRadius = self.model.pointSize.width * 0.5;
    self.pointView.clipsToBounds = YES;
    self.accessoryView.hidden = self.model.rightAccessory == nil;
    self.accessoryView.image = self.model.rightAccessory;
    self.button.selected = self.model.isSelected;
    self.pointView.hidden = !(self.model.showPoint && self.model.isSelected);
    self.button.userInteractionEnabled = self.model.userInteractionEnabled;
}

- (void)buttonClick {
    self.button.selected = !self.button.isSelected;
    self.model.isSelected = self.button.isSelected;
    if (self.model.selectedBlock) {
        self.model.selectedBlock(self.model, 0);
    }
    [self updateSubViewStateWithModel];
}

- (UIView *)btnContainer {
    if (!_btnContainer) {
        _btnContainer = [[UIView alloc] init];
        [_btnContainer addSubview:self.button];
        [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.bottom.equalTo(_btnContainer);
        }];
        [_btnContainer addSubview:self.pointView];
    }
    return _btnContainer;
}

- (VELUIButton *)button {
    if (!_button) {
        _button = [[VELUIButton alloc] init];
        _button.preventsTouchEvent = YES;
        _button.titleLabel.numberOfLines = 0;
        _button.userInteractionEnabled = NO;
        [_button addTarget:self action:@selector(buttonClick) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _button;
}

- (UIView *)pointView {
    if (!_pointView) {
        _pointView = [[UIView alloc] init];
        _pointView.hidden = YES;
    }
    return _pointView;
}

- (UIImageView *)accessoryView {
    if (!_accessoryView) {
        _accessoryView = [[UIImageView alloc] init];
        _accessoryView.hidden = YES;
    }
    return _accessoryView;
}
@end
