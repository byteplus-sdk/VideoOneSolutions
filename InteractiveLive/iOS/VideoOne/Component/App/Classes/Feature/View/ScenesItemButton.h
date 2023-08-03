// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <UIKit/UIKit.h>
#import "SceneButtonModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ScenesItemButton : UIButton

@property (nonatomic, assign) SceneButtonModel *model;

- (void)addItemLayer;

@end

NS_ASSUME_NONNULL_END
