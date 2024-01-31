// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEBaseVideoDetailViewController.h"
#import "NetworkingManager+PlayList.h"

NS_ASSUME_NONNULL_BEGIN

@interface PlayListViewController : VEBaseVideoDetailViewController

@property (nonatomic, strong) NSArray<VEVideoModel *>* playList;

@property (nonatomic, assign) PlayListMode playMode;

@end

NS_ASSUME_NONNULL_END
