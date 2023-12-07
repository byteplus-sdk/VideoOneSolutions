// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "TextInputView.h"
#import "Localizator.h"
#import "UIColor+String.h"
#import <Masonry/Masonry.h>

@interface TextInputView () <UITextFieldDelegate>

@property (nonatomic, strong) UIImageView *borderImageView;
@property (nonatomic, strong) UITextField *textField;

@end

@implementation TextInputView

- (instancetype)initWithMessage:(NSString *)message {
    self = [self initWithFrame:CGRectZero];
    if (self) {
        self.textField.text = message;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _contentInsets = UIEdgeInsetsMake(8, 12, 8, 12);
        [self addSubview:self.borderImageView];
        [self.borderImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(_contentInsets.left);
            make.trailing.mas_equalTo(-_contentInsets.right);
            make.top.mas_equalTo(_contentInsets.top);
            make.bottom.mas_equalTo(-_contentInsets.bottom);
        }];
        [self addSubview:self.textField];
        [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.borderImageView).offset(16);
            make.trailing.equalTo(self.borderImageView).offset(-16);
            make.bottom.top.equalTo(self.borderImageView);
        }];
    }
    return self;
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets {
    _contentInsets = contentInsets;
    [self.borderImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(contentInsets.left);
        make.trailing.mas_equalTo(-contentInsets.right);
        make.top.mas_equalTo(contentInsets.top);
        make.bottom.mas_equalTo(-contentInsets.bottom);
    }];
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

- (void)setBorderColor:(UIColor *)borderColor {
    self.borderImageView.backgroundColor = borderColor;
}

- (UIColor *)borderColor {
    return self.borderImageView.backgroundColor;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (self.didBeginEditing) {
        self.didBeginEditing();
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (self.didEndEditing) {
        self.didEndEditing();
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField reason:(UITextFieldDidEndEditingReason)reason API_AVAILABLE(ios(10.0)) {
    [self textFieldDidEndEditing:textField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (IsEmptyStr(self.textField.text)) {
        return YES;
    }
    if (self.clickSenderBlock) {
        self.clickSenderBlock(self.textField.text);
    }
    return YES;
}

#pragma mark - Getter
- (UIImageView *)borderImageView {
    if (!_borderImageView) {
        _borderImageView = [[UIImageView alloc] init];
        _borderImageView.backgroundColor = [UIColor colorFromRGBHexString:@"#F3F3F3"];
        _borderImageView.layer.cornerRadius = 36 / 2;
        _borderImageView.layer.masksToBounds = YES;
    }
    return _borderImageView;
}

- (UITextField *)textField {
    if (!_textField) {
        UIColor *color = [UIColor colorFromRGBHexString:@"#000000"];
        UIColor *placeholderColor = [UIColor colorFromRGBHexString:@"#80838A" andAlpha:0.5 * 255];
        _textField = [[UITextField alloc] init];
        _textField.delegate = self;
        _textField.autocorrectionType = UITextAutocorrectionTypeNo;
        _textField.returnKeyType = UIReturnKeySend;
        [_textField setBackgroundColor:[UIColor clearColor]];
        _textField.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        _textField.textColor = color;
        _textField.tintColor = color;
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:LocalizedStringFromBundle(@"placeholder_message", ToolKitBundleName)
                                                                         attributes:@{NSForegroundColorAttributeName: placeholderColor}];
        _textField.attributedPlaceholder = attrString;
    }
    return _textField;
}

@end
