// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "PhonePrivacyView.h"
#import <AppConfig/BuildConfig.h>
#import <ToolKit/Localizator.h>

@interface PhonePrivacyView () <UITextViewDelegate>
@property (nonatomic, strong) BaseButton *agreeButton;
@property (nonatomic, strong) UITextView *messageLabel;

@end

@implementation PhonePrivacyView

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *str1 = LocalizedString(@"login_terms_of_service");
        NSString *str2 = LocalizedString(@"login_privacy_policy");
        NSString *all = [NSString stringWithFormat:LocalizedString(@"login_privacy_service_format"), str1, str2];
        NSRange range1 = [all rangeOfString:str1];
        NSRange range2 = [all rangeOfString:str2];
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:all];

        [string beginEditing];
        [string addAttribute:NSForegroundColorAttributeName
                       value:[UIColor colorFromHexString:@"#80838A"]
                       range:NSMakeRange(0, all.length)];
        [string addAttribute:NSFontAttributeName
                       value:[UIFont fontWithName:@"Roboto" size:14] ?: [UIFont systemFontOfSize:14]
                       range:NSMakeRange(0, all.length)];
        [string addAttributes:@{NSLinkAttributeName: PrivacyPolicy}
                        range:range1];
        [string addAttributes:@{NSLinkAttributeName: TermsOfService}
                        range:range2];
        self.messageLabel.linkTextAttributes =
            @{NSForegroundColorAttributeName: [UIColor colorFromHexString:@"#1664FF"]};
        self.messageLabel.editable = NO;
        self.messageLabel.scrollEnabled = NO;
        self.messageLabel.delegate = self;
        [string endEditing];

        self.messageLabel.attributedText = string;

        [self addSubview:self.agreeButton];
        [self.agreeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(20, 20));
            make.top.left.equalTo(self);
        }];

        [self addSubview:self.messageLabel];
        [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.agreeButton.mas_right).mas_offset(3);
            make.top.right.bottom.equalTo(self);
        }];
    }
    return self;
}
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if (URL != nil && [[UIApplication sharedApplication] canOpenURL:URL]) {
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:URL
                                               options:@{}
                                     completionHandler:^(BOOL success){

                                     }];
        } else {
            [[UIApplication sharedApplication] openURL:URL];
        }
    }

    return YES;
}
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction API_AVAILABLE(ios(10.0)) {
    if (interaction != UITextItemInteractionPresentActions) {
        return [self textView:textView shouldInteractWithURL:URL inRange:characterRange];
    }
    return YES;
}

- (void)agreeButtonAction:(UIButton *)sender {
    _isAgree = !_isAgree;
    if (_isAgree) {
        [self.agreeButton setImage:[UIImage imageNamed:@"menus_select_s" bundleName:HomeBundleName] forState:UIControlStateNormal];
    } else {
        [self.agreeButton setImage:[UIImage imageNamed:@"menus_select" bundleName:HomeBundleName] forState:UIControlStateNormal];
    }
    if (self.changeAgree) {
        self.changeAgree(_isAgree);
    }
}

- (UITextView *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UITextView alloc] init];
        _messageLabel.backgroundColor = [UIColor clearColor];
        _messageLabel.editable = NO;
        _messageLabel.contentInset = UIEdgeInsetsZero;
        _messageLabel.textContainerInset = UIEdgeInsetsZero;
    }
    return _messageLabel;
}

- (BaseButton *)agreeButton {
    if (!_agreeButton) {
        _agreeButton = [[BaseButton alloc] init];
        [_agreeButton addTarget:self action:@selector(agreeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_agreeButton setImage:[UIImage imageNamed:@"menus_select" bundleName:HomeBundleName] forState:UIControlStateNormal];
    }
    return _agreeButton;
}

@end
