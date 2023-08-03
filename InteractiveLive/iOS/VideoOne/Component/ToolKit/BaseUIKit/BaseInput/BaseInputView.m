// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "BaseInputView.h"
#import "UIColor+String.h"
#import "UIImage+Bundle.h"
#import <Masonry/Masonry.h>
@interface BaseInputView ()

@property (nonatomic, strong, readwrite) UITextField *textField;
@property (nonatomic, strong, readwrite) UIButton *clearBtn;
@property (nonatomic, strong, readwrite) UIView *bottomLineView;
@end
@implementation BaseInputView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self loadSubViews];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleTextFieldEditingStateChangeNotification:)
                                                     name:UITextFieldTextDidBeginEditingNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleTextFieldEditingStateChangeNotification:)
                                                     name:UITextFieldTextDidEndEditingNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)becomeFirstResponder {
    return [self.textField becomeFirstResponder];
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.textColor = [UIColor colorFromHexString:@"#020814"];
        _textField.font = _font ?: [UIFont systemFontOfSize:24];
        _textField.keyboardType = UIKeyboardTypeASCIICapable;
        _textField.delegate = self;
        [_textField setMinimumFontSize:8];
        [_textField setAdjustsFontSizeToFitWidth:YES];
        [_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [_textField setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [_textField setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [self addSubview:_textField];
    }
    return _textField;
}

- (UIButton *)clearBtn {
    if (!_clearBtn) {
        _clearBtn = [[UIButton alloc] init];
        _clearBtn.hidden = YES;
        [_clearBtn setImage:[UIImage imageNamed:@"ic_circle_close" bundleName:@"ToolKit"] forState:UIControlStateNormal];
        [_clearBtn addTarget:self action:@selector(clearInput) forControlEvents:UIControlEventTouchUpInside];
        [_clearBtn setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_clearBtn setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self addSubview:_clearBtn];
        [_clearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(16);
        }];
    }
    return _clearBtn;
}

- (UIView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [UIView new];
        _bottomLineView.backgroundColor = [UIColor clearColor];
        [self addSubview:_bottomLineView];
        [_bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.height.mas_equalTo(1 / UIScreen.mainScreen.scale);
        }];
    }
    return _bottomLineView;
}

- (void)setFont:(UIFont *)font {
    _font = font;
    _textField.font = font;
}

- (void)setPlaceHolder:(NSString *)placeHolder {
    if (!placeHolder.length) {
        return;
    }
    self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeHolder
                                                                           attributes:@{
        NSForegroundColorAttributeName : [UIColor colorFromHexString:@"#C9CDD4"]
    }];
}

- (void)loadSubViews {
    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[ self.textField, self.clearBtn ]];
    stackView.alignment = UIStackViewAlignmentCenter;
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.spacing = 15;
    [self addSubview:stackView];
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self bottomLineView];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([_delegate respondsToSelector:@selector(baseInputViewShouldBeginEditing:)]) {
        return [_delegate baseInputViewShouldBeginEditing:self];
    }
    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField {
    self.clearBtn.hidden = !self.textField.text.length;
    if ([_delegate respondsToSelector:@selector(baseInputView:inputDidChange:userInfo:)]) {
        [_delegate baseInputView:self inputDidChange:textField.text userInfo:nil];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.textField resignFirstResponder];
    return YES;
}

- (void)clearInput {
    [self setInput:@""];
}

- (NSString *)input {
    return [self.textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
}

- (void)setInput:(NSString *)input {
    [self.textField setText:@""];
    [self.textField insertText:(input ?: @"")];
    [self.textField becomeFirstResponder];
}

- (void)handleTextFieldEditingStateChangeNotification:(NSNotification *)notification {
    _clearBtn.alpha = _textField.isFirstResponder ? 1 : 0;
}

@end
