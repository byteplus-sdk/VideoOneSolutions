// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import "BaseButton.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, LiveRoomItemButtonState) {
    LiveRoomItemButtonStateAddGuests = 0,
    LiveRoomItemButtonStatePK,
    LiveRoomItemButtonStateChat,
    LiveRoomItemButtonStateBeauty,
    LiveRoomItemButtonStateData,
    LiveRoomItemButtonStateMore,
    LiveRoomItemButtonStateGift,
    LiveRoomItemButtonStateLike,
};

typedef NS_ENUM(NSInteger, LiveRoomItemTouchStatus) {
    LiveRoomItemTouchStatusNone = 0,
    LiveRoomItemTouchStatusClose,
    LiveRoomItemTouchStatusIng,
};

@interface LiveRoomItemButton : BaseButton

@property (nonatomic, assign) LiveRoomItemTouchStatus touchStatus;

@property (nonatomic, assign, readonly) LiveRoomItemButtonState currentState;

@property (nonatomic, assign) BOOL isUnread;

- (instancetype)initWithState:(LiveRoomItemButtonState)state;

@end

NS_ASSUME_NONNULL_END
