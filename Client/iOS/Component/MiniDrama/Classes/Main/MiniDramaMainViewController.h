// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>
#import "MiniDramaItemButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface MiniDramaMainViewController : UIViewController

@property (nonatomic, assign) bool withAds;

- (void)viewWillAppear:(BOOL)animated;
- (void)viewDidAppear:(BOOL)animated;
- (void)dealloc;
- (void)scenesButtonAction:(MiniDramaItemButton *)sender;
- (void)close;
- (BaseButton *)backButton;

@end

NS_ASSUME_NONNULL_END
