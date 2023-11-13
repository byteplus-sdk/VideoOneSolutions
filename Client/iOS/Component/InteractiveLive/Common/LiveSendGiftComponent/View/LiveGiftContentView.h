//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveGiftItemView.h"
#import "LiveGiftModel.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LiveGiftItemViewDelegate <NSObject>

- (void)liveGiftItemClickHandler:(GiftType)giftType;

@end

@interface LiveGiftContentView : UIView

@property (nonatomic, assign) GiftType currentGiftType;

@property (nonatomic, weak) id<LiveGiftItemViewDelegate> delegate;

- (void)addSubviewAndConstraints:(NSArray<LiveGiftModel *> *)giftDataList;

@end

NS_ASSUME_NONNULL_END
