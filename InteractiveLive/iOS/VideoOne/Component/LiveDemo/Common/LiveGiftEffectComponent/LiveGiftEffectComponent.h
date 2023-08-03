// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import <UIKit/UIKit.h>
#import "LiveGiftEffectModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LiveGiftEffectComponent : NSObject

- (instancetype)initWithView:(UIView *)superView;

- (void) addTrackToQueue: (LiveGiftEffectModel *)model;

- (void)hidden:(BOOL)isHidden;


@end

NS_ASSUME_NONNULL_END


