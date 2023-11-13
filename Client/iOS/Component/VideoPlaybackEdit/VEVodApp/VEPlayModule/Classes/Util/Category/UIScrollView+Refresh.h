// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
@import UIKit;

@interface UIScrollView (Refresh)

@property (nonatomic, assign) BOOL veLoading;

- (void)systemRefresh:(void (^)(void))handler;

- (void)beginRefresh;

- (void)endRefresh;

@end
