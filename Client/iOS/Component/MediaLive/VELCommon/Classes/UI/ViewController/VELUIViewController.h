// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>
#import "VELNavigationBar.h"

NS_ASSUME_NONNULL_BEGIN
FOUNDATION_EXTERN NSString *VELUIHandleShakeNotifactionName;
@interface VELUIViewController : UIViewController
@property (nonatomic, strong, readonly) VELNavigationBar *navigationBar;
@property(nonatomic, assign) UIInterfaceOrientationMask supportedOrientationMask;
@property (nonatomic, assign) BOOL showNavigationBar;
@property (nonatomic, assign) BOOL isFirstAppear;
- (void)vel_showViewController:(UIViewController *)vc animated:(BOOL)animated;
- (void)vel_hideCurrentViewControllerWithAnimated:(BOOL)animated;
/// - Parameter vc: vc
- (void)vel_addViewController:(UIViewController *)vc;
- (void)vel_removeViewController:(UIViewController *)vc;
- (void)setupNavigationBar NS_REQUIRES_SUPER;
- (BOOL)shouldPopViewController:(BOOL)isGesture;
- (void)backButtonClick NS_REQUIRES_SUPER;
- (void)applicationWillResignActive;
- (void)applicationDidBecomeActive;
@end

NS_ASSUME_NONNULL_END
