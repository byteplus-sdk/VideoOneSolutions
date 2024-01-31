//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT
//

#import "BaseButton.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, VEMainItemStatus) {
    VEMainItemStatusDark,
    VEMainItemStatusLight,
    VEMainItemStatusActive,
};

@class VEViewController;

@interface VEMainItemButton : BaseButton

@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, strong, nullable) VEViewController *bingedVC;

@end

NS_ASSUME_NONNULL_END
