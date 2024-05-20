// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELSettingsPullInputView.h"
#import "VELSettingsTableView.h"
#import "VELSettingsButtonViewModel.h"
#import "VELPullABRSettingViewController.h"
#import <ToolKit/Localizator.h>
@interface VELSettingsPullInputView () <UITextViewDelegate>
@property (nonatomic, strong) VELUITextView *textView;
@property (nonatomic, strong) VELUILabel *titleLabel;
@property (nonatomic, strong) VELUIButton *qrButton;
@property (nonatomic, strong) UIView *textContainer;
@property (nonatomic, strong) CALayer *shadowLayer;
@property (nonatomic, assign) BOOL hasShadow;
@property (nonatomic, assign) BOOL hasBorder;
@property (nonatomic, strong) UIView *abrBtnContainer;
@property (nonatomic, strong) VELUIButton *addABRBtn;
@property (nonatomic, strong) VELUIButton *clearABRBtn;
@property (nonatomic, strong) VELSettingsTableView *abrListView;
@end
@implementation VELSettingsPullInputView
- (void)setModel:(VELSettingsPullInputViewModel *)model {
    if (![model isKindOfClass:VELSettingsPullInputViewModel.class]) {
        return;
    }
    [super setModel:model];
}

- (void)initSubviewsInContainer:(UIView *)container {
    [container addSubview:self.titleLabel];
    
    [container addSubview:self.textContainer];
    [container addSubview:self.abrListView];
    [self.abrListView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.textContainer);
    }];
    [container addSubview:self.qrButton];
    self.abrBtnContainer = [[UIView alloc] init];
    [container addSubview:self.abrBtnContainer];
    [self.abrBtnContainer addSubview:self.clearABRBtn];
    [self.abrBtnContainer addSubview:self.addABRBtn];
    [self.clearABRBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.equalTo(self.abrBtnContainer);
        make.height.mas_equalTo(35);
    }];
    [self.addABRBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.equalTo(self.abrBtnContainer);
        make.left.equalTo(self.clearABRBtn.mas_right).mas_offset(8);
        make.height.mas_equalTo(35);
    }];
    
    [self.abrBtnContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.textContainer);
        make.centerY.equalTo(self.qrButton);
    }];
}

- (void)layoutSubViewWithModel {
    [super layoutSubViewWithModel];
    
    if (!VEL_IS_EMPTY_STRING(self.model.title)) {
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.container).mas_offset(self.model.insets.top);
            make.left.equalTo(self.container).mas_offset(self.model.insets.left);
            make.right.lessThanOrEqualTo(self.container).mas_offset(-self.model.insets.right);
        }];
        [self.textContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).mas_offset(self.model.spacingBetweenTitleAndInput);
            make.left.equalTo(self.container).mas_offset(self.model.insets.left);
            make.right.equalTo(self.container).mas_offset(-self.model.insets.right);
            if (!self.model.showQRScan) {
                make.bottom.equalTo(self.container).mas_offset(-self.model.insets.bottom);
            }
        }];
    } else {
        [self.textContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.container).mas_offset(self.model.insets.top);
            make.left.equalTo(self.container).mas_offset(self.model.insets.left);
            make.right.equalTo(self.container).mas_offset(-self.model.insets.right);
            if (!self.model.showQRScan && !self.model.enableABRConfig) {
                make.bottom.equalTo(self.container).mas_offset(-self.model.insets.bottom);
            }
        }];
    }

    [self.textView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.textContainer).mas_offset(self.model.textInset);
    }];
    
    [self.abrListView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.textContainer).mas_offset(self.model.textInset);
    }];
    
    if (self.model.showQRScan) {
        [self.qrButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.textContainer.mas_bottom).mas_offset(self.model.spacingBetweenQRAndInput);
            make.left.equalTo(self.textContainer);
            make.right.lessThanOrEqualTo(self.textContainer);
            make.bottom.equalTo(self.container).mas_offset(-self.model.insets.bottom);
        }];
    } else {
        [self.qrButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.textContainer.mas_bottom).mas_offset(self.model.spacingBetweenQRAndInput);
            make.left.equalTo(self.textContainer);
        }];
    }
    if (self.model.enableABRConfig) {
        [self.abrBtnContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.textContainer);
            make.top.equalTo(self.textContainer.mas_bottom).mas_offset(self.model.spacingBetweenQRAndInput);
            make.bottom.equalTo(self.container).mas_offset(-self.model.insets.bottom);
        }];
    } else {
        [self.abrBtnContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.textContainer);
            make.top.equalTo(self.textContainer.mas_bottom).mas_offset(self.model.spacingBetweenQRAndInput);
        }];
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
    self.textView.keyboardType = UIKeyboardTypeURL;
    if (self.model.enableABRConfig) {
        self.textView.text = nil;
    } else {
        self.textView.text = self.model.mainUrlConfig.url;
    }
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
        NSAttributedString *attributeTitle = [[NSAttributedString alloc] initWithString:self.model.qrScanTip attributes:self.model.qrScanTipAttribute];
        [self.qrButton setAttributedTitle:attributeTitle forState:(UIControlStateNormal)];
    }
    
    self.qrButton.hidden = self.model.enableABRConfig;
    self.textContainer.userInteractionEnabled = !self.model.enableABRConfig;
    self.abrBtnContainer.hidden = !self.model.enableABRConfig;
    self.abrListView.hidden = !self.model.enableABRConfig;
    self.textView.hidden = self.model.enableABRConfig && self.model.currentUrlConfig.abrUrlConfigs.count > 0;
    [self setupListViewModels];
}

- (void)setupListViewModels {
    if (!self.model.enableABRConfig) {
        return;
    }
    NSArray <VELPullABRUrlConfig *>* configs = self.model.currentUrlConfig.abrUrlConfigs;
    NSMutableArray <VELSettingsButtonViewModel *>* models = [NSMutableArray arrayWithCapacity:configs.count];
    [configs enumerateObjectsUsingBlock:^(VELPullABRUrlConfig * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        VELSettingsButtonViewModel *model = [[VELSettingsButtonViewModel alloc] init];
        model.title = [obj shortDescription];
        model.size = CGSizeMake(VELAutomaticDimension, 33);
        model.extraInfo[@"URL_CONFIG"] = obj;
        model.alignment = UIControlContentHorizontalAlignmentLeft;
        model.containerBackgroundColor = [UIColor whiteColor];
        model.backgroundColor = [UIColor whiteColor];
        model.containerSelectBackgroundColor = [UIColor whiteColor];
        [models addObject:model];
    }];
    self.abrListView.models = models;
}

- (void)didClickWithUrlConfig:(VELSettingsButtonViewModel *)btnModel urlConfig:(VELPullABRUrlConfig *)urlConfig {
    if (urlConfig == nil) {
        return;
    }
    if (self.model.didClickAbrConfigBlock) {
        self.model.didClickAbrConfigBlock(self.model, btnModel, urlConfig);
    }
}

- (void)didDeleteWithUrlConfig:(VELSettingsButtonViewModel *)btnModel urlConfig:(VELPullABRUrlConfig *)urlConfig {
    if (urlConfig == nil) {
        return;
    }
    if (self.model.deleteAbrConfigBlock) {
        self.model.deleteAbrConfigBlock(self.model, btnModel, urlConfig);
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
    [VELDeviceHelper sendFeedback];
    [self.textView endEditing:YES];
    if (self.model.qrScanActionBlock) {
        self.model.qrScanActionBlock(self.model);
    }
}

- (void)addABRBtnClick {
    [VELDeviceHelper sendFeedback];
    [self.textView endEditing:YES];
    if (self.model.addAbrActionBlock) {
        self.model.addAbrActionBlock(self.model);
    }
}

- (void)clearABRBtnClick {
    [VELDeviceHelper sendFeedback];
    [self.textView endEditing:YES];
    if (self.model.clearAbrActionBlock) {
        self.model.clearAbrActionBlock(self.model);
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

- (VELUIButton *)addABRBtn {
    if (!_addABRBtn) {
        _addABRBtn = [[VELUIButton alloc] init];
        _addABRBtn.cornerRadius = 6;
        [_addABRBtn setTitle:LocalizedStringFromBundle(@"medialive_add_abr_gear", @"MediaLive") forState:(UIControlStateNormal)];
        [_addABRBtn setBackgroundColor:VELColorWithHexString(@"#1C5DFD")];
        _addABRBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _addABRBtn.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        [_addABRBtn setTitleColor:UIColor.whiteColor forState:(UIControlStateNormal)];
        [_addABRBtn addTarget:self action:@selector(addABRBtnClick) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _addABRBtn;
}

- (VELUIButton *)clearABRBtn {
    if (!_clearABRBtn) {
        _clearABRBtn = [[VELUIButton alloc] init];
        [_clearABRBtn setTitle:LocalizedStringFromBundle(@"medialive_clear_abr_gear", @"MediaLive") forState:(UIControlStateNormal)];
        _clearABRBtn.cornerRadius = 6;
        _clearABRBtn.layer.borderColor = VELColorWithHexString(@"#1C5DFD").CGColor;
        _clearABRBtn.layer.borderWidth = 1;
        _clearABRBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _clearABRBtn.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        [_clearABRBtn setTitleColor:VELColorWithHexString(@"#1C5DFD") forState:(UIControlStateNormal)];
        [_clearABRBtn addTarget:self action:@selector(clearABRBtnClick) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _clearABRBtn;
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

- (VELSettingsTableView *)abrListView {
    if (!_abrListView) {
        _abrListView = [[VELSettingsTableView alloc] init];
        _abrListView.backgroundColor = [UIColor clearColor];
        _abrListView.allowSelection = YES;
        _abrListView.allowDelete = YES;
        __weak __typeof__(self)weakSelf = self;
        [_abrListView setSelectedItemBlock:^(__kindof VELSettingsBaseViewModel * _Nonnull model, NSInteger index) {
            __strong __typeof__(weakSelf)self = weakSelf;
            [self didClickWithUrlConfig:model urlConfig:model.extraInfo[@"URL_CONFIG"]];
        }];
        [_abrListView setDeleteItemBlock:^(__kindof VELSettingsBaseViewModel * _Nonnull model, NSInteger index) {
            __strong __typeof__(weakSelf)self = weakSelf;
            [self didDeleteWithUrlConfig:model urlConfig:model.extraInfo[@"URL_CONFIG"]];
        }];
    }
    return _abrListView;
}

- (VELUITextView *)textView {
    if (!_textView) {
        _textView = [[VELUITextView alloc] init];
        _textView.delegate = self;
    }
    return _textView;
}

@end
