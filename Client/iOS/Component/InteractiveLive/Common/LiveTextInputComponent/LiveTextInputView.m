// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveTextInputView.h"

@interface LiveTextInputView () <UITextFieldDelegate>

@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIImageView *borderImageView;
@property (nonatomic, strong) UITextField *textField;

@end

@implementation LiveTextInputView

- (instancetype)initWithMessage:(NSString *)message {
    self = [super init];
    if (self) {
        [self addSubview:self.maskView];
        [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];

        [self addSubview:self.borderImageView];
        [self.borderImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(12);
            make.right.mas_equalTo(-12);
            make.top.mas_equalTo(8);
            make.bottom.mas_equalTo(-8);
        }];

        [self addSubview:self.textField];
        [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.borderImageView).offset(16);
            make.right.equalTo(self.borderImageView).offset(-16);
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

#pragma mark - UITextFieldDelegate

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

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] init];
        _maskView.backgroundColor = [UIColor colorFromRGBHexString:@"#FFFFFF"];
    }
    return _maskView;
}

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
        NSAttributedString *attrString = [[NSAttributedString alloc]
            initWithString:LocalizedString(@"placeholder_message")
                attributes:
                    @{NSForegroundColorAttributeName: placeholderColor}];
        _textField.attributedPlaceholder = attrString;
    }
    return _textField;
}

@end
