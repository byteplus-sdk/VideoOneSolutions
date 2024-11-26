//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <UIKit/UIKit.h>
#import "LiveGiftModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol LiveGiftItemComponentDelegate <NSObject>

- (void)liveGiftItemClickHandler:(GiftType)giftType;

@end

@interface LiveSendGiftComponent : NSObject

- (instancetype)initWithView:(UIView *)superView;

- (void)showWithRoomID:(NSString *)roomID;

@property (nonatomic, weak) id<LiveGiftItemComponentDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
