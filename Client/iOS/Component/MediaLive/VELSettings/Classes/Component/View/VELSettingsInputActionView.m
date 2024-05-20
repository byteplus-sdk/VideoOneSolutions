// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELSettingsInputActionView.h"
#import <MediaLive/VELCommon.h>
#import <ToolKit/Localizator.h>

@interface VELSettingsInputActionView () <UITextFieldDelegate>
@property (nonatomic, strong) VELUILabel *titleLabel;
@property (nonatomic, strong) VELUILabel *leftLabel;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) VELUIButton *sendButton;
@property (nonatomic, strong) VELUIButton *qrButton;
@property (nonatomic, strong) UIView *textFiledContainer;
@end
@implementation VELSettingsInputActionView

- (void)initSubviewsInContainer:(UIView *)container {
    [container addSubview:self.leftLabel];
    
    UIView *textFiledContainer = [[UIView alloc] init];
    self.textFiledContainer = textFiledContainer;
    textFiledContainer.backgroundColor = VELColorWithHexString(@"#535552");
    textFiledContainer.layer.cornerRadius = 5;
    textFiledContainer.clipsToBounds = YES;
    [textFiledContainer addSubview:self.textField];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(textFiledContainer);
    }];
    [textFiledContainer addSubview:self.qrButton];
    [self.qrButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(textFiledContainer);
        make.left.equalTo(self.textField.mas_right).mas_offset(3);
        make.right.equalTo(textFiledContainer).mas_offset(-3);
    }];
    [container addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(container);
    }];
    [container addSubview:textFiledContainer];
    [textFiledContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(container);
        make.bottom.lessThanOrEqualTo(container);
        make.top.equalTo(self.titleLabel.mas_bottom).mas_offset(12);
        make.height.mas_equalTo(35);
    }];
    [container addSubview:self.sendButton];
    [self.sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(textFiledContainer);
        make.left.equalTo(textFiledContainer.mas_right).mas_offset(5);
        make.right.equalTo(container);
        make.size.mas_equalTo(CGSizeMake(50, 27));
    }];
}

- (void)layoutSubViewWithModel {
    [super layoutSubViewWithModel];
    if (!VEL_IS_EMPTY_STRING(self.model.title)) {
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.container).mas_offset(self.model.insets.top);
            make.left.equalTo(self.container).mas_offset(self.model.insets.left);
            make.right.equalTo(self.container).mas_offset(-self.model.insets.right);
        }];
    } else {
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.container.mas_top).mas_offset(-self.model.insets.top);
            make.left.equalTo(self.container).mas_offset(self.model.insets.left);
        }];
    }
    
    self.leftLabel.hidden = VEL_IS_EMPTY_STRING(self.model.leftTitle);
    [self.leftLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.top.equalTo(self.titleLabel.mas_bottom).mas_offset(self.model.spacingBetweenTitleAndInput);
        make.bottom.lessThanOrEqualTo(self.container).mas_offset(-self.model.insets.bottom);
        make.height.mas_equalTo(self.model.textFieldHeight);
        if (VEL_IS_EMPTY_STRING(self.model.leftTitle)) {
            make.width.mas_equalTo(1);
        }
    }];
    
    self.qrButton.hidden = !self.model.showQRScan;
    if (self.model.showQRScan) {
        [self.qrButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.textFiledContainer);
            make.left.equalTo(self.textField.mas_right).mas_offset(3);
            make.right.equalTo(self.textFiledContainer).mas_offset(-3);
        }];
    } else {
        [self.qrButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.textFiledContainer);
            make.left.equalTo(self.textField.mas_right).mas_offset(3);
            make.left.equalTo(self.textFiledContainer.mas_right).mas_offset(0);
        }];
    }
    
    [self.textFiledContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.leftLabel.isHidden) {
            make.left.equalTo(self.leftLabel.mas_right);
        } else {
            make.left.equalTo(self.leftLabel.mas_right).mas_offset(8);
        }
        make.top.equalTo(self.titleLabel.mas_bottom).mas_offset(self.model.spacingBetweenTitleAndInput);
        make.bottom.lessThanOrEqualTo(self.container).mas_offset(-self.model.insets.bottom);
        make.height.mas_equalTo(self.model.textFieldHeight);
    }];
    
    self.sendButton.hidden = !self.model.showActionBtn;
    [self.sendButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.textFiledContainer);
        make.left.equalTo(self.textFiledContainer.mas_right).mas_offset(5);
        make.right.equalTo(self.container).mas_offset(-self.model.insets.right);
        if (self.model.showActionBtn) {
            make.size.mas_equalTo(self.model.btnSize);
        } else {
            make.size.mas_equalTo(CGSizeMake(1, self.model.btnSize.height));
        }
    }];
}

- (void)updateSubViewStateWithModel {
    UIColor *backGroundColor = self.model.isSelected ? self.model.containerSelectBackgroundColor : self.model.containerBackgroundColor;
    UIColor *borderColor = self.model.isSelected ? self.model.selectedBorderColor : self.model.borderColor;
    [super updateSubViewStateWithModel];
    self.textFiledContainer.backgroundColor = self.model.textFiledContainerBgColor;
    [self.sendButton setBackgroundColor:self.model.actionBtnBgColor];
    self.container.backgroundColor = self.model.showVisualEffect ? UIColor.clearColor : backGroundColor;
    self.titleLabel.hidden = VEL_IS_EMPTY_STRING(self.model.title);
    self.titleLabel.textAttributes = self.model.titleAttribute;
    self.titleLabel.text = self.model.title;
    
    self.leftLabel.hidden = VEL_IS_EMPTY_STRING(self.model.leftTitle);
    self.leftLabel.textAttributes = self.model.leftTitleAttribute;
    self.leftLabel.text = self.model.leftTitle;
    
    self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.model.placeHolder?:@"" attributes:self.model.placeHolderAttribute?:@{}];
    self.textField.font = self.model.textAttribute[NSFontAttributeName];
    self.textField.textColor = self.model.textAttribute[NSForegroundColorAttributeName];
    self.textField.text = self.model.text;
    self.textField.keyboardType = self.model.keyboardType;
    if (self.model.hasBorder) {
        self.textField.layer.borderColor = borderColor.CGColor;
        self.textField.layer.borderWidth = self.model.borderWidth;
        self.textField.clipsToBounds = YES;
    }
    
    self.qrButton.hidden = !self.model.showQRScan;
    if (self.model.showQRScan) {
        if (self.model.qrScanSize.width > 0 && self.model.qrScanSize.height > 0) {
            self.qrButton.imageSize = self.model.qrScanSize;
        }
        [self.qrButton setImage:self.model.qrScanIcon forState:(UIControlStateNormal)];
        if (VEL_IS_NOT_EMPTY_STRING(self.model.qrScanTip)) {
            NSAttributedString *attributeTitle = [[NSAttributedString alloc] initWithString:self.model.qrScanTip?:@"" attributes:self.model.qrScanTipAttribute];
            [self.qrButton setAttributedTitle:attributeTitle forState:(UIControlStateNormal)];
        }
    }
    if (VEL_IS_NOT_EMPTY_STRING(self.model.btnTitle)) {
        NSAttributedString *attributeTitle = [[NSAttributedString alloc] initWithString:self.model.btnTitle?:@"" attributes:self.model.btnTitleAttributes?:@{}];
        [self.sendButton setAttributedTitle:attributeTitle forState:(UIControlStateNormal)];
    }
    if (VEL_IS_NOT_EMPTY_STRING(self.model.selectBtnTitle)) {
        NSAttributedString *attributeTitle = [[NSAttributedString alloc] initWithString:self.model.selectBtnTitle?:@"" attributes:self.model.selectBtnTitleAttributes?:@{}];
        [self.sendButton setAttributedTitle:attributeTitle forState:(UIControlStateSelected)];
    }
    [self.sendButton setSelected:self.model.isSelected];
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.model.text = textField.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return [textField endEditing:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    textField.tintColor = UIColor.clearColor;
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        UITextPosition *position = [textField endOfDocument];
        [textField setSelectedTextRange:[textField textRangeFromPosition:position toPosition:position]];
        textField.tintColor = nil;
    }];
    [CATransaction commit];
}

- (void)qrButtonClick {
    if (self.model.qrScanActionBlock) {
        self.model.qrScanActionBlock(self.model);
        return;
    }
    __weak __typeof__(self)weakSelf = self;
    [VELQRScanViewController showFromVC:nil completion:^(VELQRScanViewController * _Nonnull vc, NSString * _Nonnull result) {
        __strong __typeof__(weakSelf)self = weakSelf;
        self.textField.text = [result vel_trim];
        self.model.text = [result vel_trim];
        [vc hide];
    }];
}

- (void)sendButtonAction {
    self.model.text = self.textField.text;
    if (VEL_IS_EMPTY_STRING(self.model.text) && !self.model.disableTextCheck) {
        [VELUIToast showText:LocalizedStringFromBundle(@"medialive_please_input", @"MediaLive") inView:UIApplication.sharedApplication.keyWindow];
        return;
    }
    self.model.isSelected = !self.model.isSelected;
    [self.sendButton setSelected:self.model.isSelected];
    if (self.model.sendBtnActionBlock) {
        self.model.sendBtnActionBlock(self.model, self.model.isSelected);
    }
}

- (VELUIButton *)qrButton {
    if (!_qrButton) {
        _qrButton = [[VELUIButton alloc] init];
        [_qrButton setContentCompressionResistancePriority:(UILayoutPriorityRequired) forAxis:(UILayoutConstraintAxisHorizontal)];
        _qrButton.contentMode = UIViewContentModeLeft;
        _qrButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _qrButton.imagePosition = VELUIButtonImagePositionLeft;
        _qrButton.spacingBetweenImageAndTitle = 10;
        [_qrButton setImage:[VELUIImageMake(@"vel_qr_scan") vel_imageByTintColor:UIColor.whiteColor] forState:(UIControlStateNormal)];
        [_qrButton addTarget:self action:@selector(qrButtonClick) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _qrButton;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.delegate = self;
        _textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 10)];
        _textField.leftViewMode = UITextFieldViewModeAlways;
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textField.textColor = [UIColor whiteColor];
        _textField.tintColor = UIColor.whiteColor;
        _textField.font = [UIFont systemFontOfSize:14];
        _textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"" attributes:@{
            NSFontAttributeName : [UIFont systemFontOfSize:14],
            NSForegroundColorAttributeName : [[UIColor whiteColor] colorWithAlphaComponent:0.7]
        }];
    }
    return _textField;
}

- (VELUIButton *)sendButton {
    if (!_sendButton) {
        _sendButton = [[VELUIButton alloc] init];
        _sendButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_sendButton setTitleColor:UIColor.whiteColor forState:(UIControlStateNormal)];
        [_sendButton setBackgroundColor:VELColorWithHexString(@"#535552")];
        _sendButton.cornerRadius = 5;
        [_sendButton addTarget:self action:@selector(sendButtonAction) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _sendButton;
}
- (VELUILabel *)leftLabel {
    if (!_leftLabel) {
        _leftLabel = [[VELUILabel alloc] init];
        [_leftLabel setContentCompressionResistancePriority:(UILayoutPriorityRequired) forAxis:(UILayoutConstraintAxisHorizontal)];
        _leftLabel.textAttributes = @{
            NSFontAttributeName : [UIFont systemFontOfSize:14],
            NSForegroundColorAttributeName : UIColor.whiteColor
        };
    }
    return _leftLabel;
}
- (VELUILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[VELUILabel alloc] init];
        _titleLabel.textAttributes = @{
            NSFontAttributeName : [UIFont systemFontOfSize:14],
            NSForegroundColorAttributeName : UIColor.whiteColor
        };
    }
    return _titleLabel;
}
@end
