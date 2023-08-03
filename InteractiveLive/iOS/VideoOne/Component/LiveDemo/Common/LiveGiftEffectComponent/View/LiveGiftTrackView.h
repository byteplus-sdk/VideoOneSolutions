// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import <UIKit/UIKit.h>
#import "LiveGifteffectModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LiveGiftTrackView : UIView

@property (nonatomic, assign) float duration;

-(instancetype) initWithModel: (LiveGiftEffectModel *)model withDuration:(float) duration;

- (void) decrease:(float)delta;

@end

NS_ASSUME_NONNULL_END

