// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import "LiveRTCManager.h"
#import "LiveUserModel.h"
#import <UIKit/UIKit.h>
@class LiveAddGuestsRoomView;

NS_ASSUME_NONNULL_BEGIN

@protocol LiveAddGuestsRoomViewDelegate <NSObject>

- (void)guestsRoomView:(LiveAddGuestsRoomView *)guestsRoomView
       clickMoreButton:(LiveUserModel *)model;

- (void)guestsRoomView:(LiveAddGuestsRoomView *)guestsRoomView
        clickMultiUser:(LiveUserModel *)model;

@end

@interface LiveAddGuestsRoomView : UIView

@property (nonatomic, weak) id<LiveAddGuestsRoomViewDelegate> delegate;

- (instancetype)initWithHostID:(NSString *)hostID
                 roomInfoModel:(LiveRoomInfoModel *)roomInfoModel;

- (void)updateGuests:(NSArray<LiveUserModel *> *)userList;

- (void)removeGuests:(NSString *)uid;

- (void)updateGuestsMic:(BOOL)mic uid:(NSString *)uid;

- (void)updateGuestsCamera:(BOOL)camera uid:(NSString *)uid;

- (BOOL)getIsGuests:(NSString *)uid;

- (void)updateNetworkQuality:(LiveNetworkQualityStatus)status uid:(NSString *)uid;

@end

NS_ASSUME_NONNULL_END
