// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import "LiveRoomInfoModel.h"
#import "LiveUserModel.h"
#import "RoomStatusModel.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LiveReconnectModel : NSObject

@property (nonatomic, strong) LiveRoomInfoModel *roomModel;
@property (nonatomic, copy) NSString *streamPushUrl;
@property (nonatomic, copy) NSString *rtcRoomID;
@property (nonatomic, copy) NSString *rtcToken;
@property (nonatomic, copy) NSArray<LiveUserModel *> *rtcUserList;
@property (nonatomic, strong) LiveUserModel *loginUserModel;
// 1: Live mode 2: Make guest mode 3: Make cohost mode
@property (nonatomic, assign) NSInteger interactStatus;

@end

NS_ASSUME_NONNULL_END
