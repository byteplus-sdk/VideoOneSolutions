// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "UserNameViewController.h"
#import <Masonry/Masonry.h>
#import <ToolKit/Localizator.h>
#import <ToolKit/MenuCreateTextFieldView.h>
#import <ToolKit/NetworkingManager.h>
#import <ToolKit/ToolKit.h>

@interface UserNameViewController ()

@property (nonatomic, strong) UIView *navView;
@property (nonatomic, strong) UILabel *navLabel;
@property (nonatomic, strong) BaseButton *rightButton;
@property (nonatomic, strong) BaseButton *leftButton;

@property (nonatomic, strong) MenuCreateTextFieldView *userNameTextFieldView;

@end

@implementation UserNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorFromHexString:@"#F6F8FA"];

    [self.view addSubview:self.navView];
    [self.navView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.height.mas_equalTo([DeviceInforTool getStatusBarHight] + 44);
    }];

    [self.navView addSubview:self.navLabel];
    [self.navLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.navView);
        make.centerY.equalTo(self.navView).offset([DeviceInforTool getStatusBarHight] / 2);
    }];

    [self.navView addSubview:self.leftButton];
    [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(16);
        make.left.mas_equalTo(16);
        make.centerY.equalTo(self.navLabel);
    }];

    [self.navView addSubview:self.rightButton];
    [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-16);
        make.centerY.equalTo(self.navLabel);
    }];

    [self.view addSubview:self.userNameTextFieldView];
    [self.userNameTextFieldView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.right.mas_equalTo(-16);
        make.height.mas_equalTo(32);
        make.top.equalTo(self.navView.mas_bottom).offset(30);
    }];

    self.userNameTextFieldView.text = [LocalUserComponent userModel].name;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleDefault;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.userNameTextFieldView becomeFirstResponder];
}

- (void)rightButtonAction:(BaseButton *)sender {
    if (![LocalUserComponent isMatchUserName:self.userNameTextFieldView.text] ||
        self.userNameTextFieldView.text.length <= 0) {
        return;
    }
    __weak __typeof(self) wself = self;
    BaseUserModel *userModel = [LocalUserComponent userModel];
    userModel.name = self.userNameTextFieldView.text;
    [[ToastComponent shareToastComponent] showLoading];
    [NetworkingManager changeUserName:userModel.name
                           loginToken:[LocalUserComponent userModel].loginToken
                                block:^(NetworkingResponse *_Nonnull response) {
                                    [[ToastComponent shareToastComponent] dismiss];
                                    if (response.result) {
                                        [LocalUserComponent updateLocalUserModel:userModel];
                                        [wself.navigationController popViewControllerAnimated:YES];
                                    } else {
                                        [[ToastComponent shareToastComponent] showWithMessage:response.message];
                                    }
                                }];
}

- (void)navBackAction {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Getter

- (BaseButton *)leftButton {
    if (!_leftButton) {
        _leftButton = [[BaseButton alloc] init];
        [_leftButton setImage:[UIImage imageNamed:@"img_left_black" bundleName:@"App"] forState:UIControlStateNormal];
        _leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_leftButton addTarget:self action:@selector(navBackAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftButton;
}

- (BaseButton *)rightButton {
    if (!_rightButton) {
        _rightButton = [[BaseButton alloc] init];
        ;
        [_rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _rightButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_rightButton addTarget:self action:@selector(rightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_rightButton setTitle:LocalizedStringFromBundle(@"ok", @"App") forState:UIControlStateNormal];
    }
    return _rightButton;
}

- (UIView *)navView {
    if (!_navView) {
        _navView = [[UIView alloc] init];
        _navView.backgroundColor = [UIColor clearColor];
    }
    return _navView;
}

- (UILabel *)navLabel {
    if (!_navLabel) {
        _navLabel = [[UILabel alloc] init];
        _navLabel.font = [UIFont systemFontOfSize:17];
        _navLabel.textColor = [UIColor blackColor];
        _navLabel.text = LocalizedStringFromBundle(@"change_user_name", @"App");
    }
    return _navLabel;
}

- (MenuCreateTextFieldView *)userNameTextFieldView {
    if (!_userNameTextFieldView) {
        _userNameTextFieldView = [[MenuCreateTextFieldView alloc] initWithModify:YES];
        _userNameTextFieldView.placeholderStr = LocalizedStringFromBundle(@"please_enter_user_nickname", @"App") ?: @"";
        _userNameTextFieldView.maxLimit = 18;
        _userNameTextFieldView.minLimit = 1;
        _userNameTextFieldView.textColor = [UIColor blackColor];
        _userNameTextFieldView.placeHolderColor = [UIColor grayColor];
    }
    return _userNameTextFieldView;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

@end
