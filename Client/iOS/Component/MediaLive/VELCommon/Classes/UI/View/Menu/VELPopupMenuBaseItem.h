// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>
#import "VELPopupMenuItemProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface VELPopupMenuBaseItem : UIView <VELPopupMenuItemProtocol>
@property (nonatomic, strong) id extObj;
@end

NS_ASSUME_NONNULL_END
