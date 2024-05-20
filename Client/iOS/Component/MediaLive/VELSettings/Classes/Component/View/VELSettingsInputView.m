// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELSettingsInputView.h"
@interface VELSettingsInputView () <UITextViewDelegate>
@property (nonatomic, strong) VELUITextView *textView;
@property (nonatomic, strong) VELUILabel *titleLabel;
@property (nonatomic, strong) VELUIButton *qrButton;
@property (nonatomic, strong) UIView *textContainer;
@property (nonatomic, strong) CALayer *shadowLayer;
@property (nonatomic, assign) BOOL hasShadow;
@property (nonatomic, assign) BOOL hasBorder;
@end
@implementation VELSettingsInputView
- (void)setModel:(VELSettingsInputViewModel *)model {
    if (![model isKindOfClass:VELSettingsInputViewModel.class]) {
        return;
    }
    [super setModel:model];
}

- (void)initSubviewsInContainer:(UIView *)container {
    [container addSubview:self.titleLabel];
    [container addSubview:self.textContainer];
    [container addSubview:self.qrButton];
}

- (void)layoutSubViewWithModel {
    [super layoutSubViewWithModel];
    
    if (!VEL_IS_EMPTY_STRING(self.model.title)) {
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.container).mas_offset(self.model.insets.top);
            make.left.equalTo(self.container).mas_offset(self.model.insets.left);
            make.right.equalTo(self.container).mas_offset(-self.model.insets.right);
        }];
        [self.textContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).mas_offset(self.model.spacingBetweenTitleAndInput);
            make.left.equalTo(self.container).mas_offset(self.model.insets.left);
            make.right.equalTo(self.container).mas_offset(-self.model.insets.right);
            if (!self.model.showQRScan || self.model.qRScanInContainer) {
                make.bottom.equalTo(self.container).mas_offset(-self.model.insets.bottom);
            }
        }];
    } else {
        [self.textContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.container).mas_offset(self.model.insets.top);
            make.left.equalTo(self.container).mas_offset(self.model.insets.left);
            make.right.equalTo(self.container).mas_offset(-self.model.insets.right);
            if (!self.model.showQRScan || self.model.qRScanInContainer) {
                make.bottom.equalTo(self.container).mas_offset(-self.model.insets.bottom);
            }
        }];
    }

    [self.textView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.textContainer).mas_offset(self.model.textInset);
    }];
    
    if (self.model.showQRScan) {
        if (self.model.qRScanInContainer) {
            [self.qrButton removeFromSuperview];
            [self.textContainer addSubview:self.qrButton];
            [self.textView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.textContainer).mas_offset(self.model.textInset.top);
                make.left.equalTo(self.textContainer).mas_offset(self.model.textInset.left);
                make.right.equalTo(self.textContainer).mas_offset(-self.model.textInset.right);
            }];
            [self.qrButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.textView.mas_bottom).mas_offset(self.model.spacingBetweenQRAndInput);
                make.left.equalTo(self.textView);
                make.right.lessThanOrEqualTo(self.textView);
                make.bottom.equalTo(self.textContainer).mas_offset(-self.model.textInset.bottom);;
            }];
        } else {
            [self.qrButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.textContainer.mas_bottom).mas_offset(self.model.spacingBetweenQRAndInput);
                make.left.equalTo(self.textContainer);
                make.right.lessThanOrEqualTo(self.textContainer);
                make.bottom.equalTo(self.container).mas_offset(-self.model.insets.bottom);
            }];
        }
    }
}

- (void)updateSubViewStateWithModel {
    self.hasShadow = self.model.hasShadow;
    self.hasBorder = self.model.hasBorder;
    UIColor *backGroundColor = self.model.isSelected ? self.model.containerSelectBackgroundColor : self.model.containerBackgroundColor;
    UIColor *borderColor = self.model.isSelected ? self.model.selectedBorderColor : self.model.borderColor;
    self.model.hasShadow = NO;
    self.model.hasBorder = NO;
    [super updateSubViewStateWithModel];
    self.container.backgroundColor = UIColor.clearColor;
    self.titleLabel.hidden = VEL_IS_EMPTY_STRING(self.model.title);
    self.titleLabel.textAttributes = self.model.titleAttribute;
    self.titleLabel.text = self.model.title;
    
    self.textView.placeholderColor = self.model.placeHolderAttribute[NSForegroundColorAttributeName];
    self.textView.placeholder = self.model.placeHolder;
    self.textView.font = self.model.textAttribute[NSFontAttributeName];
    self.textView.textColor = self.model.textAttribute[NSForegroundColorAttributeName];
    self.textView.text = self.model.text;
    self.textView.backgroundColor = UIColor.clearColor;
    if (self.hasBorder) {
        self.textContainer.layer.borderColor = borderColor.CGColor;
        self.textContainer.layer.borderWidth = self.model.borderWidth;
        self.textContainer.clipsToBounds = YES;
    }
    
    if (self.hasShadow) {
        [self.shadowLayer removeFromSuperlayer];
        [self.container.layer insertSublayer:self.shadowLayer below:self.textContainer.layer];
    }
    self.textContainer.backgroundColor = backGroundColor;
    
    self.qrButton.hidden = !self.model.showQRScan;
    if (self.model.showQRScan) {
        if (self.model.qrScanSize.width > 0 && self.model.qrScanSize.height > 0) {
            self.qrButton.imageSize = self.model.qrScanSize;
        }
        [self.qrButton setImage:self.model.qrScanIcon forState:(UIControlStateNormal)];
        if (VEL_IS_NOT_EMPTY_STRING(self.model.qrScanTip)) {
            NSAttributedString *attributeTitle = [[NSAttributedString alloc] initWithString:self.model.qrScanTip attributes:self.model.qrScanTipAttribute];
            [self.qrButton setAttributedTitle:attributeTitle forState:(UIControlStateNormal)];
        }
    }
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.model.text = textView.text;
    if (self.model.textDidChangedBlock) {
        self.model.textDidChangedBlock(self.model, textView.text);
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    textView.tintColor = UIColor.clearColor;
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        UITextPosition *position = [textView endOfDocument];
        [textView setSelectedTextRange:[textView textRangeFromPosition:position toPosition:position]];
        textView.tintColor = nil;
    }];
    [CATransaction commit];
    return YES;
}

- (void)qrButtonClick {
    if (self.model.qrScanActionBlock) {
        self.model.qrScanActionBlock(self.model);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.hasShadow) {
        self.shadowLayer.frame = self.textContainer.frame;
    }
}

- (VELUIButton *)qrButton {
    if (!_qrButton) {
        _qrButton = [[VELUIButton alloc] init];
        _qrButton.contentMode = UIViewContentModeLeft;
        _qrButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _qrButton.imagePosition = VELUIButtonImagePositionLeft;
        _qrButton.spacingBetweenImageAndTitle = 10;
        [_qrButton addTarget:self action:@selector(qrButtonClick) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _qrButton;
}

- (VELUILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[VELUILabel alloc] init];
    }
    return _titleLabel;
}

- (UIView *)textContainer {
    if (!_textContainer) {
        _textContainer = [[UIView alloc] init];
        [_textContainer addSubview:self.textView];
        [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_textContainer).mas_offset(UIEdgeInsetsMake(16, 16, 16, 16));
        }];
    }
    return _textContainer;
}

- (VELUITextView *)textView {
    if (!_textView) {
        _textView = [[VELUITextView alloc] init];
        _textView.delegate = self;
    }
    return _textView;
}
@end
