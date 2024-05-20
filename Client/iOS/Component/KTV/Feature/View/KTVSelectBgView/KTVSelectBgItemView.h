// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "BaseButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface KTVSelectBgItemView : BaseButton

@property (nonatomic, assign) BOOL isSelected;

- (instancetype)initWithIndex:(NSInteger)index;

- (NSString *)getBackgroundImageName;

- (NSString *)getBackgroundSmallImageName;

@end

NS_ASSUME_NONNULL_END
