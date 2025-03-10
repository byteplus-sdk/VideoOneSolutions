// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "BaseButton.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MiniDramaMainItemStatus) {
    MiniDramaMainItemStatusDeactive,
    MiniDramaMainItemStatusActive
};

@interface MiniDramaItemButton : BaseButton

@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, strong, nullable) UIViewController *bingedVC;

@end

NS_ASSUME_NONNULL_END
