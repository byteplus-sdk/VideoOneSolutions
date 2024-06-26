// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChorusPickSongTopView : UIView

@property (nonatomic, copy) void(^selectedChangedBlock)(NSInteger index);

- (void)updatePickedSongCount:(NSInteger)count;

- (void)changedSelectIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
