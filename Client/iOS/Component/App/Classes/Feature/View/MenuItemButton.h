// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "BaseButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface MenuItemButton : BaseButton

@property (nonatomic, copy) NSString *desTitle;

@property (nonatomic, assign) BOOL isAction;

@property (nonatomic, assign) NSInteger tagNum;

@end

NS_ASSUME_NONNULL_END
