// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import "TTPageViewController.h"

@class TTMixModel;
@class TTVideoCellController;

NS_ASSUME_NONNULL_BEGIN

@protocol TTVideoCellControllerDelegate <NSObject>

- (void)TTVideoController:(TTVideoCellController *)controller shouldLockVerticalScroll:(BOOL)shouldLock;

@end

@interface TTVideoCellController : UIViewController <TTPageItem>

@property (nonatomic, weak) id<TTVideoCellControllerDelegate> delegate;

@property (nonatomic, strong) TTMixModel *mixModel;

@end

NS_ASSUME_NONNULL_END
