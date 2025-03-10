// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>
#import "MDPlayerControlView.h"
#import "MDPlayerControlViewDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface MDPlayerActionView : UIView

- (void)addPlayerControlView:(MDPlayerControlView * _Nullable)controlView viewType:(MDPlayerControlViewType)viewType;

- (void)removePlayerControlView:(MDPlayerControlViewType)viewType;

- (MDPlayerControlView * _Nullable)getPlayerControlView:(MDPlayerControlViewType)viewType;

@end

NS_ASSUME_NONNULL_END
