// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "MenuViewController.h"
#import "ScenesViewController.h"
#import "UserViewController.h"
#import "MenuItemButton.h"
#import "MenuLoginHome.h"
#import "LocalizatorBundle.h"
#import "Masonry.h"
#import "ToolKit.h"

@interface MenuViewController ()

@property (nonatomic, strong) MenuItemButton *scenesButton;
@property (nonatomic, strong) MenuItemButton *userButton;

@property (nonatomic, strong) UserViewController *userViewController;
@property (nonatomic, strong) ScenesViewController *scenesViewController;

@property (nonatomic, strong) UIView *bottomView;
@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginExpiredNotificate:)
                                                 name:NotificationLoginExpired object:nil];
    
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo([DeviceInforTool getTabBarHight]);
    }];
    [self.bottomView addSubview:self.scenesButton];
    [self.bottomView addSubview:self.userButton];
    NSArray *bottomBtns = @[self.scenesButton, self.userButton];
    [bottomBtns mas_distributeViewsAlongAxis:(MASAxisTypeHorizontal)
                            withFixedSpacing:0
                                 leadSpacing:0
                                 tailSpacing:0];
    [bottomBtns mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomView).mas_offset(5);
        make.bottom.mas_equalTo(-[DeviceInforTool getVirtualHomeHeight] + 5);
    }];
    
    if ([LocalUserComponent userModel].loginToken == nil) {
        [MenuLoginHome showLoginViewControllerAnimated:NO];
    }
    
    [self scenesButtonAction];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)loginExpiredNotificate:(NSNotification *)sender {
    [LocalUserComponent userModel].loginToken = @"";
    [LocalUserComponent updateLocalUserModel:nil];
    
    [DeviceInforTool backToRootViewController];
    
    NSString *key = (NSString *)sender.object;
    if ([key isKindOfClass:[NSString class]] &&
        [key isEqualToString:@"logout"]) {
        [[AlertActionManager shareAlertActionManager] dismiss:^{
            [MenuLoginHome showLoginViewControllerAnimated:YES];
        }];
        [[ToastComponent shareToastComponent] showWithMessage:LocalizedStringFromBundle(@"same_logged_in", @"App") delay:2];
    } else if ([key isEqualToString:@"manual_logout"]) {
        [[AlertActionManager shareAlertActionManager] dismiss:^{
            [MenuLoginHome showLoginViewControllerAnimated:YES];
        }];
    } else {
        [MenuLoginHome showLoginViewControllerAnimated:YES];
    }
}

#pragma mark - Touch Action
- (void)showViewController:(UIViewController *)vc {
    [vc willMoveToParentViewController:self];
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
    [vc.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.bottomView.mas_top);
    }];
    [vc didMoveToParentViewController:self];
}

- (void)hideViewController:(UIViewController *)vc {
    [vc willMoveToParentViewController:nil];
    [vc removeFromParentViewController];
    [vc.view removeFromSuperview];
    [vc didMoveToParentViewController:nil];
}

- (void)scenesButtonAction {
    [self hideViewController:self.userViewController];
    [self showViewController:self.scenesViewController];
    self.scenesButton.status = ButtonStatusActive;
    self.userButton.status = ButtonStatusNone;
    self.scenesButton.isAction = YES;
    self.userButton.isAction = NO;
}

- (void)userButtonAction {
    [self hideViewController:self.scenesViewController];
    [self showViewController:self.userViewController];
    self.userButton.status = ButtonStatusActive;
    self.scenesButton.status = ButtonStatusNone;
    self.scenesButton.isAction = NO;
    self.userButton.isAction = YES;
}

#pragma mark - Getter

- (ScenesViewController *)scenesViewController {
    if (!_scenesViewController) {
        _scenesViewController = [[ScenesViewController alloc] init];
    }
    return _scenesViewController;
}

- (UserViewController *)userViewController {
    if (!_userViewController) {
        _userViewController = [[UserViewController alloc] init];
    }
    return _userViewController;
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
        _scenesButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _scenesButton.backgroundColor = [UIColor clearColor];
        [_scenesButton addTarget:self action:@selector(scenesButtonAction) forControlEvents:UIControlEventTouchUpInside];
        
        _scenesButton.imageEdgeInsets = UIEdgeInsetsMake(4, 0, 20, 0);
        _scenesButton.desTitle = LocalizedStringFromBundle(@"home", @"App");
        _scenesButton.isAction = NO;
        
        [_scenesButton bingImage:[UIImage imageNamed:@"menu_list" bundleName:@"App"] status:ButtonStatusNone];
        [_scenesButton bingImage:[UIImage imageNamed:@"menu_list_s" bundleName:@"App"] status:ButtonStatusActive];
        
        [_scenesButton bingFont:[UIFont systemFontOfSize:14] status:ButtonStatusNone];
        [_scenesButton bingFont:[UIFont boldSystemFontOfSize:14] status:ButtonStatusActive];
    }
    return _scenesButton;
}

- (MenuItemButton *)userButton {
    if (!_userButton) {
        _userButton = [[MenuItemButton alloc] init];
        _userButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _userButton.backgroundColor = [UIColor clearColor];
        [_userButton addTarget:self action:@selector(userButtonAction) forControlEvents:UIControlEventTouchUpInside];
        
        _userButton.imageEdgeInsets = UIEdgeInsetsMake(4, 0, 20, 0);
        _userButton.desTitle = LocalizedStringFromBundle(@"me", @"App");
        _userButton.isAction = NO;
        
        [_userButton bingImage:[UIImage imageNamed:@"menu_user" bundleName:@"App"] status:ButtonStatusNone];
        [_userButton bingImage:[UIImage imageNamed:@"menu_user_s" bundleName:@"App"] status:ButtonStatusActive];
        
        [_userButton bingFont:[UIFont systemFontOfSize:14] status:ButtonStatusNone];
        [_userButton bingFont:[UIFont boldSystemFontOfSize:14] status:ButtonStatusActive];
    }
    return _userButton;
}

@end
