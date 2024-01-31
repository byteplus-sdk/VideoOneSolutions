// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "MenuLoginViewController.h"
#import "BuildConfig.h"
#import "LoginControlComponent.h"
#import "MenuCreateTextFieldView.h"
#import "PhonePrivacyView.h"
#import <ToolKit/Localizator.h>

@interface MenuLoginViewController () <MenuCreateTextFieldViewLoginDelegate>
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIView *inputBgView;
@property (nonatomic, strong) MenuCreateTextFieldViewLogin *userNameTextFieldView;
@property (nonatomic, strong) UILabel *inputErrorTipLabel;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) PhonePrivacyView *privacyView;

@property (nonatomic, strong) UIImageView *backgroundImgView;
@property (nonatomic, strong) UIImageView *bottomRightImgView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation MenuLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self addMakeConstraints];

    __weak __typeof(self) wself = self;
    self.userNameTextFieldView.textFieldChangeBlock = ^(NSString *_Nonnull text) {
        [wself updateLoginButtonStatus];
    };
    self.privacyView.changeAgree = ^(BOOL isAgree) {
        [wself updateLoginButtonStatus];
    };
    [self updateLoginButtonStatus];
}

#pragma mark - Private Action

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (touches.anyObject.view == self.view) {
        [self.userNameTextFieldView endEditing:YES];
        [self.userNameTextFieldView resignFirstResponder];
    }
}

- (void)loginButtonAction:(UIButton *)sender {
    NSAssert(NOEmptyStr(ServerUrl), @"Missing Login Url! Please configure information at BuildConfig.h");
    __weak __typeof(self) wself = self;
    [[ToastComponent shareToastComponent] showLoading];
    [LoginControlComponent passwordFreeLogin:self.userNameTextFieldView.text
                                       block:^(BOOL result, NSString *_Nullable errorStr) {
                                           [[ToastComponent shareToastComponent] dismiss];
                                           if (result) {
                                               [[NSNotificationCenter defaultCenter] postNotificationName:NotificationLoginSucceed object:self userInfo:nil];
                                               [wself dismissViewControllerAnimated:YES completion:^{

                                               }];
                                           } else {
                                               [[ToastComponent shareToastComponent] showWithMessage:errorStr];
                                           }
                                       }];
}

#pragma mark - MenuCreateTextFieldViewLoginDelegate

- (void)showErrorLabelWithMessage:(NSString *)message isShow:(BOOL)isShow {
    if (isShow) {
        self.inputErrorTipLabel.text = message;
        [self.inputErrorTipLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.inputBgView);
            make.top.equalTo(self.inputBgView.mas_bottom).mas_offset(16);
            make.right.lessThanOrEqualTo(self.inputBgView);
        }];

        [self.privacyView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.inputBgView);
            make.top.equalTo(self.inputErrorTipLabel.mas_bottom).mas_offset(16);
        }];
    } else {
        self.inputErrorTipLabel.text = nil;
        [self.privacyView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.inputBgView);
            make.top.equalTo(self.inputBgView.mas_bottom).mas_offset(16);
        }];
    }
}

#pragma mark - Private Action

- (void)updateLoginButtonStatus {
    BOOL isDisable = YES;
    BOOL isIllega = NO;
    isDisable = IsEmptyStr(self.userNameTextFieldView.text);
    isIllega = self.userNameTextFieldView.isIllega;
    BOOL isAgree = self.privacyView.isAgree;
    if (isDisable || isIllega || !isAgree) {
        self.loginButton.userInteractionEnabled = NO;
        self.loginButton.backgroundColor = [UIColor colorFromRGBHexString:@"#1664ff" andAlpha:0.3 * 255];
        [self.loginButton setTitleColor:[UIColor colorFromRGBHexString:@"#ffffff" andAlpha:0.3 * 255] forState:UIControlStateNormal];
    } else {
        self.loginButton.userInteractionEnabled = YES;
        self.loginButton.backgroundColor = [UIColor colorFromHexString:@"#0E42D2"];
        [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

- (void)addMakeConstraints {
    [self.view addSubview:self.bottomRightImgView];
    [self.bottomRightImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.equalTo(self.view);
    }];

    [self.view addSubview:self.backgroundImgView];
    [self.backgroundImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
    }];

    [self.view addSubview:self.iconImageView];
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(16);
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(78);
        make.width.mas_equalTo(120);
        make.height.mas_equalTo(24);
    }];

    [self.view addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImageView);
        make.top.equalTo(self.iconImageView.mas_bottom).mas_offset(15);
        make.right.lessThanOrEqualTo(self.view.mas_right).mas_offset(-16);
    }];

    [self.view addSubview:self.inputBgView];
    [self.inputBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backgroundImgView.mas_bottom).offset(-8);
        make.left.equalTo(self.iconImageView);
        make.right.mas_equalTo(-16);
        make.height.mas_equalTo(48);
    }];

    [self.view addSubview:self.inputErrorTipLabel];
    [self.inputErrorTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.inputBgView);
        make.top.equalTo(self.inputBgView.mas_bottom).mas_offset(16);
        make.right.lessThanOrEqualTo(self.inputBgView);
    }];

    [self.view addSubview:self.privacyView];
    [self.privacyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.inputBgView);
        make.top.equalTo(self.inputErrorTipLabel.mas_bottom).mas_offset(16);
    }];

    [self.view addSubview:self.loginButton];
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.inputBgView);
        make.top.equalTo(self.privacyView.mas_bottom).mas_offset(32);
        make.height.mas_equalTo(50);
        make.bottom.mas_lessThanOrEqualTo(self.view.mas_bottom);
    }];
}

#pragma mark - Getter

- (MenuCreateTextFieldViewLogin *)userNameTextFieldView {
    if (!_userNameTextFieldView) {
        _userNameTextFieldView = [[MenuCreateTextFieldViewLogin alloc] initWithModify:NO];
        _userNameTextFieldView.placeholderStr = LocalizedString(@"Username");
        _userNameTextFieldView.maxLimit = 18;
        _userNameTextFieldView.delegate = self;
    }
    return _userNameTextFieldView;
}

- (UIButton *)loginButton {
    if (!_loginButton) {
        _loginButton = [[UIButton alloc] init];
        _loginButton.layer.masksToBounds = YES;
        _loginButton.layer.cornerRadius = 8;
        [_loginButton setTitle:LocalizedString(@"Log in") forState:UIControlStateNormal];
        _loginButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
        [_loginButton addTarget:self action:@selector(loginButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginButton;
}

- (PhonePrivacyView *)privacyView {
    if (!_privacyView) {
        _privacyView = [[PhonePrivacyView alloc] init];
    }
    return _privacyView;
}

- (UIImageView *)backgroundImgView {
    if (!_backgroundImgView) {
        _backgroundImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_bg" bundleName:HomeBundleName]];
        _backgroundImgView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _backgroundImgView;
}

- (UIImageView *)bottomRightImgView {
    if (!_bottomRightImgView) {
        _bottomRightImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bottom_right_bg" bundleName:HomeBundleName]];
        _bottomRightImgView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _bottomRightImgView;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.backgroundColor = [UIColor clearColor];
        _iconImageView.image = [UIImage imageNamed:@"login_logo_icon" bundleName:HomeBundleName];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _iconImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        if (@available(iOS 14.0, *)) {
            _titleLabel.lineBreakStrategy = NSLineBreakStrategyNone;
        }
        _titleLabel.textColor = [UIColor colorFromHexString:@"#020814"];
        _titleLabel.font = [UIFont fontWithName:@"Roboto" size:28] ?: [UIFont boldSystemFontOfSize:28];
        NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
        [paraStyle setParagraphStyle:NSParagraphStyle.defaultParagraphStyle];
        paraStyle.lineBreakStrategy = NSLineBreakStrategyNone;
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:LocalizedString(@"login_title") attributes:@{
            NSFontAttributeName: _titleLabel.font,
            NSForegroundColorAttributeName: _titleLabel.textColor,
            NSParagraphStyleAttributeName: paraStyle
        }];
        _titleLabel.attributedText = attr;
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

- (UIView *)inputBgView {
    if (!_inputBgView) {
        _inputBgView = [[UIView alloc] init];
        [_inputBgView addSubview:self.userNameTextFieldView];
        [self.userNameTextFieldView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.inputBgView).mas_offset(UIEdgeInsetsMake(14, 16, 14, 16));
        }];
        _inputBgView.layer.borderColor = [UIColor colorFromHexString:@"#C9CDD4"].CGColor;
        _inputBgView.layer.cornerRadius = 1;
        _inputBgView.layer.borderWidth = 1;
        _inputBgView.layer.cornerRadius = 8;
        _inputBgView.clipsToBounds = YES;
    }
    return _inputBgView;
}

- (UILabel *)inputErrorTipLabel {
    if (!_inputErrorTipLabel) {
        _inputErrorTipLabel = [[UILabel alloc] init];
        _inputErrorTipLabel.numberOfLines = 0;
        _inputErrorTipLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _inputErrorTipLabel.textColor = [UIColor colorFromHexString:@"#DB373F"];
        _inputErrorTipLabel.font = [UIFont fontWithName:@"Roboto" size:14] ?: [UIFont systemFontOfSize:14];
    }
    return _inputErrorTipLabel;
}

- (void)dealloc {
}

@end
