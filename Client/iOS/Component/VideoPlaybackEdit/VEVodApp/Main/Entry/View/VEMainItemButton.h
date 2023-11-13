//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT
//

#import "BaseButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface VEMainItemButton : BaseButton

@property (nonatomic, copy) NSString *desTitle;

- (void)bingLabelColor:(UIColor *)color status:(ButtonStatus)status;

@end

NS_ASSUME_NONNULL_END
