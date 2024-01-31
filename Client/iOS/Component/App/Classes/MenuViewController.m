// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "MenuViewController.h"
#import "FunctionsViewController.h"
#import "MenuItemButton.h"
#import "ScenesViewController.h"
#import "UserEntry.h"
#import "UserViewController.h"
#import <Masonry/Masonry.h>
#import <ToolKit/BaseEntrance.h>
#import <ToolKit/LoginComponent.h>
#import <ToolKit/ToolKit.h>

@interface MenuViewController ()

@property (nonatomic, strong) UserEntry *userEntry;
@property (nonatomic, strong) MenuItemButton *scenesButton;
@property (nonatomic, strong) MenuItemButton *functionButton;

@property (nonatomic, weak) UIViewController *currentVC;
@property (nonatomic, strong) FunctionsViewController *functionsViewController;
@property (nonatomic, strong) ScenesViewController *scenesViewController;

@property (nonatomic, strong) UIView *bottomView;
@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(logoutNotificate:)
                                                 name:NotificationLogout
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(prepareEnvironment)
                                                 name:NotificationLoginSucceed
                                               object:nil];

    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-52);
    }];
    [self.bottomView addSubview:self.scenesButton];
    [self.bottomView addSubview:self.functionButton];
    NSArray *bottomBtns = @[self.scenesButton, self.functionButton];
    [bottomBtns mas_distributeViewsAlongAxis:(MASAxisTypeHorizontal)
                            withFixedSpacing:0
                                 leadSpacing:0
                                 tailSpacing:0];
    [bottomBtns mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomView);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
    }];

    [self.view addSubview:self.userEntry];
    [self.userEntry mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(44);
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(8);
        make.right.equalTo(self.view).offset(-9);
    }];

    if (![LoginComponent showLoginVCIfNeed:NO]) {
        [self prepareEnvironment];
    }
    [self scenesButtonAction];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (!self.currentVC) {
        return UIStatusBarStyleDefault;
    }
    return [self.currentVC preferredStatusBarStyle];
}

- (void)logoutNotificate:(NSNotification *)sender {
    [LocalUserComponent logout];
    [DeviceInforTool backToRootViewController];

    NSString *reason = (NSString *)sender.userInfo[NotificationLogoutReasonKey];
    if ([reason isKindOfClass:[NSString class]] &&
        [reason isEqualToString:@"logout"]) {
        [[AlertActionManager shareAlertActionManager] dismiss:^{
            [LoginComponent showLoginVCAnimated:YES];
        }];
        [[ToastComponent shareToastComponent] showWithMessage:LocalizedStringFromBundle(@"same_logged_in", @"App") delay:2];
    } else if ([reason isEqualToString:@"manual_logout"]) {
        [[AlertActionManager shareAlertActionManager] dismiss:^{
            [LoginComponent showLoginVCAnimated:YES];
        }];
    } else {
        [LoginComponent showLoginVCAnimated:YES];
    }
}

- (void)prepareEnvironment {
    [self.userEntry reloadData];
    Class impClass = NSClassFromString(@"VideoPlaybackEdit");
    if (impClass && [impClass conformsToProtocol:@protocol(EntranceProtocol)]) {
        [(Class<EntranceProtocol>)impClass prepareEnvironment];
    }
}

#pragma mark - Touch Action
- (void)showViewController:(UIViewController *)vc {
    [vc willMoveToParentViewController:self];
    [self addChildViewController:vc];
    [self.view insertSubview:vc.view atIndex:0];
    [vc.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.bottomView.mas_top);
    }];
    [vc didMoveToParentViewController:self];
    self.currentVC = vc;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)hideViewController:(UIViewController *)vc {
    [vc willMoveToParentViewController:nil];
    [vc removeFromParentViewController];
    [vc.view removeFromSuperview];
    [vc didMoveToParentViewController:nil];
}

- (void)scenesButtonAction {
    [self hideViewController:self.functionsViewController];
    [self showViewController:self.scenesViewController];
    self.scenesButton.status = ButtonStatusActive;
    self.functionButton.status = ButtonStatusNone;
}

- (void)functionButtonAction {
    [self hideViewController:self.scenesViewController];
    [self showViewController:self.functionsViewController];
    self.functionButton.status = ButtonStatusActive;
    self.scenesButton.status = ButtonStatusNone;
}

- (void)entryUserViewContorller {
    UserViewController *userVC = [[UserViewController alloc] init];
    [self.navigationController pushViewController:userVC animated:YES];
}

#pragma mark - Getter

- (ScenesViewController *)scenesViewController {
    if (!_scenesViewController) {
        _scenesViewController = [[ScenesViewController alloc] init];
    }
    return _scenesViewController;
}

- (FunctionsViewController *)functionsViewController {
    if (!_functionsViewController) {
        _functionsViewController = [[FunctionsViewController alloc] init];
    }
    return _functionsViewController;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor whiteColor];
        _bottomView.layer.shadowColor = [UIColor colorWithRed:0.276 green:0.377 blue:0.529 alpha:0.1].CGColor;
        _bottomView.layer.shadowOpacity = 1;
        _bottomView.layer.shadowRadius = 32;
        _bottomView.layer.shadowOffset = CGSizeMake(0, -8);
        _bottomView.clipsToBounds = NO;
    }
    return _bottomView;
}

- (MenuItemButton *)scenesButton {
    if (!_scenesButton) {
        _scenesButton = [[MenuItemButton alloc] init];
        _scenesButton.backgroundColor = [UIColor clearColor];
        [_scenesButton addTarget:self action:@selector(scenesButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_scenesButton setTitle:LocalizedStringFromBundle(@"menu_scene", @"App") forState:UIControlStateNormal];
        [_scenesButton bingImage:[UIImage imageNamed:@"menu_list" bundleName:@"App"] status:ButtonStatusNone];
        [_scenesButton bingImage:[UIImage imageNamed:@"menu_list_s" bundleName:@"App"] status:ButtonStatusActive];
        [_scenesButton bingFont:[UIFont systemFontOfSize:14] status:ButtonStatusNone];
        [_scenesButton bingFont:[UIFont systemFontOfSize:14 weight:UIFontWeightMedium] status:ButtonStatusActive];
    }
    return _scenesButton;
}

- (MenuItemButton *)functionButton {
    if (!_functionButton) {
        _functionButton = [[MenuItemButton alloc] init];
        _functionButton.backgroundColor = [UIColor clearColor];
        [_functionButton addTarget:self action:@selector(functionButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_functionButton setTitle:LocalizedStringFromBundle(@"menu_function", @"App") forState:UIControlStateNormal];
        [_functionButton bingImage:[UIImage imageNamed:@"menu_funtction" bundleName:@"App"] status:ButtonStatusNone];
        [_functionButton bingImage:[UIImage imageNamed:@"menu_funtction_s" bundleName:@"App"] status:ButtonStatusActive];
        [_functionButton bingFont:[UIFont systemFontOfSize:14] status:ButtonStatusNone];
        [_functionButton bingFont:[UIFont systemFontOfSize:14 weight:UIFontWeightMedium] status:ButtonStatusActive];
    }
    return _functionButton;
}

- (UserEntry *)userEntry {
    if (!_userEntry) {
        _userEntry = [[UserEntry alloc] init];
        [_userEntry addTarget:self action:@selector(entryUserViewContorller) forControlEvents:UIControlEventTouchUpInside];
    }
    return _userEntry;
}

@end
