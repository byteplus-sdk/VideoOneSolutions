// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELUIViewController.h"
#import "VELCommonDefine.h"
#import "VELUIButton.h"
#import "VELDeviceRotateHelper.h"
#import <Masonry/Masonry.h>

@interface VELUIViewController ()
@property (nonatomic, strong, readwrite) VELNavigationBar *navigationBar;
@end

@implementation VELUIViewController
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _showNavigationBar = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = VELViewBackgroundColor;
    [self setupNavigationBar];
    [self addAppNotifaction];
}

- (void)addAppNotifaction {
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(_applicationWillResignActive)
                                               name:UIApplicationWillResignActiveNotification
                                             object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(_applicationDidBecomeActive)
                                               name:UIApplicationDidBecomeActiveNotification
                                             object:nil];
}

- (void)_applicationWillResignActive {
    if (self.view.window == nil) {
        return;
    }
    [self applicationWillResignActive];
    self.isFirstAppear = NO;
}
- (void)applicationWillResignActive {}
- (void)_applicationDidBecomeActive {
    if (self.view.window == nil) {
        return;
    }
    [self applicationDidBecomeActive];
}
- (void)applicationDidBecomeActive {}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.isFirstAppear = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.showNavigationBar) {
        [self.view bringSubviewToFront:self.navigationBar];
    }
    [VELDeviceRotateHelper autoRotateWhenViewWillAppear];
}

- (void)setupNavigationBar {
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.view addSubview:self.navigationBar];
    if (self.navigationController == nil
        && self.modalPresentationStyle != UIModalPresentationFullScreen
        && self.parentViewController == nil) {
        self.navigationBar.topSafeMargin = 0;
    }
    [self.navigationBar mas_makeConstraints:^(MASConstraintMaker *make) {
        if (self.showNavigationBar) {
            make.top.equalTo(self.view.mas_top);
        } else {
            make.bottom.equalTo(self.view.mas_top);
        }
        make.right.left.equalTo(self.view);
        make.height.mas_equalTo(VEL_NAVIGATION_HEIGHT);
    }];
    self.navigationBar.hidden = !self.showNavigationBar;
    if (self.navigationController.viewControllers.firstObject == self) {
        [self.navigationBar onlyShowTitle];
        return;
    }
    self.navigationBar.leftButton.hidden = NO;
}
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    if (size.width > size.height) {
        self.navigationBar.topSafeMargin = VEL_SAFE_INSERT.top;
        [self.navigationBar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(VEL_NAVIGATION_HEIGHT - VEL_SAFE_INSERT.top);
        }];
    } else {
        self.navigationBar.topSafeMargin = [VELDeviceHelper statusBarHeight];
        [self.navigationBar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(VEL_NAVIGATION_HEIGHT);
        }];
    }
}

- (BOOL)shouldPopViewController:(BOOL)isGesture {
    return YES;
}

- (void)backButtonClick {
    if ([self shouldPopViewController:NO]) {
        [self vel_hideCurrentViewControllerWithAnimated:YES];
    }
}

- (void)vel_showViewController:(UIViewController *)vc animated:(BOOL)animated {
    if (vc == nil) {
        return;
    }
    if (self.navigationController) {
        [self.navigationController pushViewController:vc animated:animated];
    } else {
        [self presentViewController:vc animated:animated completion:nil];
    }
}

- (void)vel_hideCurrentViewControllerWithAnimated:(BOOL)animated {
    [VELDeviceRotateHelper rotateToDeviceOrientation:(UIDeviceOrientationPortrait)];
    if (self.navigationController && self.navigationController.viewControllers.firstObject != self) {
        [self.navigationController popViewControllerAnimated:animated];
    } else if (self.presentingViewController) {
        [self dismissViewControllerAnimated:animated completion:nil];
    }
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    self.navigationBar.titleLabel.text = title;
}

- (void)setShowNavigationBar:(BOOL)showNavigationBar {
    _showNavigationBar = showNavigationBar;
    self.navigationBar.hidden = !showNavigationBar;
    [self.navigationBar mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (showNavigationBar) {
            make.top.equalTo(self.view.mas_top);
        } else {
            make.bottom.equalTo(self.view.mas_top);
        }
        make.right.left.equalTo(self.view);
        make.height.mas_equalTo(VEL_NAVIGATION_HEIGHT);
    }];
}

- (VELNavigationBar *)navigationBar {
    if (!_navigationBar) {
        _navigationBar = [VELNavigationBar navigationBarWithTitle:self.title];
        __weak __typeof__(self)weakSelf = self;
        [_navigationBar setLeftEventBlock:^{
            __strong __typeof__(weakSelf)self = weakSelf;
            [self backButtonClick];
        }];
    }
    return _navigationBar;
}

- (void)vel_addViewController:(UIViewController *)vc {
    [vc willMoveToParentViewController:self];
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
    [vc.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navigationBar.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
    [vc didMoveToParentViewController:self];
}

- (void)vel_removeViewController:(UIViewController *)vc {
    [vc willMoveToParentViewController:nil];
    [vc.view removeFromSuperview];
    [vc didMoveToParentViewController:nil];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [VELDeviceRotateHelper supportInterfaceMask];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)dealloc {
    VELLogDebug(@"Memory", @"%@ - dealloc", NSStringFromClass(self.class));
}
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    [super motionEnded:motion withEvent:event];
    if (event.subtype == UIEventSubtypeMotionShake) {
        [NSNotificationCenter.defaultCenter postNotificationName:VELUIHandleShakeNotifactionName object:self];
        if (@available(iOS 10.0, *)) {
            UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
            [generator prepare];
            [generator impactOccurred];
        }
    }
}
@end
NSString *VELUIHandleShakeNotifactionName = @"VELUIHandleShakeNotifactionName";
