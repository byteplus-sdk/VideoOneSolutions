// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "KTVNavViewController.h"

@interface KTVNavViewController () <UIGestureRecognizerDelegate>

@end

@implementation KTVNavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    [self.view addSubview:self.topBackgroundImageView];
    [self.view addSubview:self.navView];
    [self.navView addSubview:self.leftButton];
    [self.navView addSubview:self.rightButton];
    [self addConstraints];
}

- (void)addConstraints {
    [self.topBackgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(@340);
    }];
    
    [self.navView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.height.mas_equalTo([DeviceInforTool getSafeAreaInsets].bottom + 44);
    }];
    
    [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(16);
        make.left.mas_equalTo(18);
        make.bottom.equalTo(self.navView).offset(-12);
    }];
    
    [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-18);
        make.bottom.equalTo(self.navView).offset(-12);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)navBackAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightButtonAction:(BaseButton *)sender {
    
}

- (void)setRightTitle:(NSString *)rightTitle {
    _rightTitle = rightTitle;
    
    [self.rightButton setTitle:rightTitle forState:UIControlStateNormal];
}

#pragma mark - getter

- (BaseButton *)leftButton {
    if (!_leftButton) {
        _leftButton = [[BaseButton alloc] init];
        [_leftButton setImage:[UIImage imageNamed:@"nav_left" bundleName:HomeBundleName] forState:UIControlStateNormal];
        _leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_leftButton addTarget:self action:@selector(navBackAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftButton;
}

- (BaseButton *)rightButton {
    if (!_rightButton) {
        _rightButton = [[BaseButton alloc] init];;
        [_rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _rightButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_rightButton addTarget:self action:@selector(rightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
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

- (UIImageView *)topBackgroundImageView {
    if (!_topBackgroundImageView) {
        _topBackgroundImageView = [[UIImageView alloc] init];
        _topBackgroundImageView.image = [UIImage imageNamed:@"room_list_bg" bundleName:HomeBundleName];
        _topBackgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        _topBackgroundImageView.clipsToBounds = YES;
        _topBackgroundImageView.hidden = YES;
    }
    return _topBackgroundImageView;
}

@end
