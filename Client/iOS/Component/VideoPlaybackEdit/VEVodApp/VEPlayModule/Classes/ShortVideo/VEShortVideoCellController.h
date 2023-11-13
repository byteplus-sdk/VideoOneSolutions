// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
@import UIKit;
@class VEVideoModel;
@class VEShortVideoCellController;
#import "VEPageViewController.h"

@protocol VEShortVideoCellControllerDelegate <NSObject>

- (void)shortVideoController:(VEShortVideoCellController *)controller shouldLockVerticalScroll:(BOOL)shouldLock;

@end

@interface VEShortVideoCellController : UIViewController <VEPageItem>

@property (nonatomic, weak) id<VEShortVideoCellControllerDelegate> delegate;

@property (nonatomic, strong) VEVideoModel *videoModel;

@end
