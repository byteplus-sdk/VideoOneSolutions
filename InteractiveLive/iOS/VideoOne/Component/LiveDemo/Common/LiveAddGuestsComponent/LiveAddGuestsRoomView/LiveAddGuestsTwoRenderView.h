// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LiveAddGuestsTwoRenderView : UIView

@property (nonatomic, copy) void (^clickSmallBlock)(LiveUserModel *userModel);

- (instancetype)initWithRoomInfoModel:(LiveRoomInfoModel *)roomInfoModel;

- (void)updateUserList:(NSArray<LiveUserModel *> *)userList;

- (void)updateGuestsMic:(BOOL)mic uid:(NSString *)uid;

- (void)updateGuestsCamera:(BOOL)camera uid:(NSString *)uid;

@end

NS_ASSUME_NONNULL_END
