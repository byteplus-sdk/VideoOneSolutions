// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "KTVTextInputView.h"

@interface KTVTextInputView ()

@property (nonatomic, strong) UIView *inputMaskView;
@property (nonatomic, strong) UIImageView *borderImageView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) BaseButton *senderButton;

@end

@implementation KTVTextInputView

- (instancetype)initWithMessage:(NSString *)message {
    self = [super init];
    if (self) {
        [self addSubview:self.inputMaskView];
        [self.inputMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [self addSubview:self.senderButton];
        [self.senderButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(60, 28));
            make.right.mas_equalTo(-16);
            make.centerY.equalTo(self);
        }];
        
        [self addSubview:self.borderImageView];
        [self.borderImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(8);
            make.right.equalTo(self.senderButton.mas_left).offset(-12);
            make.centerY.equalTo(self);
        }];
        
        [self addSubview:self.textField];
        [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.borderImageView).offset(12);
            make.right.equalTo(self.borderImageView).offset(-12);
            make.height.top.equalTo(self.borderImageView);
        }];
        self.textField.text = message;
    }
    return self;
}

#pragma mark - Publish Action

- (void)show {
    [self.textField becomeFirstResponder];
}

- (void)dismiss:(void (^)(NSString *text))block {
    if (block) {
        block(self.textField.text);
    }
    [self.textField resignFirstResponder];
}

- (void)senderButtonAction {
    if (IsEmptyStr(self.textField.text)) {
        return;
    }
    if (self.clickSenderBlock) {
        self.clickSenderBlock(self.textField.text);
    }
    [self dismiss:^(NSString * _Nonnull text) {
        
    }];
}

#pragma mark - Getter

- (UIView *)inputMaskView {
    if (!_inputMaskView) {
        _inputMaskView = [[UIView alloc] init];
        _inputMaskView.backgroundColor = [UIColor colorFromRGBHexString:@"#0E0825" andAlpha:0.95 * 255];
    }
    return _inputMaskView;
}

- (UIImageView *)borderImageView {
    if (!_borderImageView) {
        _borderImageView = [[UIImageView alloc] init];
        _borderImageView.image = [UIImage imageNamed:@"KTV_textinput_border" bundleName:HomeBundleName];
    }
    return _borderImageView;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        [_textField setBackgroundColor:[UIColor clearColor]];
        [_textField setTextColor:[UIColor whiteColor]];
        _textField.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        NSAttributedString *attrString = [[NSAttributedString alloc]
                                          initWithString:LocalizedString(@"label_input_placeholder")
                                          attributes:
                                        @{NSForegroundColorAttributeName :
                                        [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.7 * 255]}];
        _textField.attributedPlaceholder = attrString;
    }
    return _textField;
}

- (BaseButton *)senderButton {
    if (!_senderButton) {
        _senderButton = [[BaseButton alloc] init];
        _senderButton.backgroundColor = [UIColor colorFromHexString:@"#1664FF"];
        [_senderButton setTitle:LocalizedString(@"button_input_send") forState:UIControlStateNormal];
        [_senderButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _senderButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_senderButton addTarget:self action:@selector(senderButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _senderButton.layer.cornerRadius = 14;
        _senderButton.layer.masksToBounds = YES;
    }
    return _senderButton;
}

@end
