// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEViewController.h"

@implementation VEViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)tabViewDidAppear {
    // override in subclasss
}

- (void)tabViewDidDisappear {
    //  override in subclasss
}

- (void)close {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
