// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import <UIKit/UIKit.h>
#import "LiveGiftModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol LiveGiftItemSendButtonDelegate <NSObject>

- (void)liveGiftItemSendButtonHandler:(GiftType) giftType;

@end


@interface LiveGiftItemView : UIView

@property (nonatomic, weak) id<LiveGiftItemSendButtonDelegate> delegate;

@property (nonatomic, strong) LiveGiftModel *model;

- (void)beSelected:(BOOL)isSelect;

- (instancetype)initWithBlock:(void(^)(GiftType))onClick;

@end

NS_ASSUME_NONNULL_END
