//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveUserModel.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LiveRoomInfoModel : NSObject

@property (nonatomic, copy) NSString *liveAppID;
@property (nonatomic, copy) NSString *rtcAppID;
@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) NSString *roomName;
@property (nonatomic, copy) NSString *anchorUserID;
@property (nonatomic, copy) NSString *anchorUserName;
@property (nonatomic, assign) LiveRoomStatus status;
@property (nonatomic, assign) NSInteger audienceCount;
@property (nonatomic, copy) NSDictionary<NSString *, NSString *> *streamPullStreamList;
@property (nonatomic, strong) NSString *rtmToken;
@property (nonatomic, strong) LiveUserModel *hostUserModel;
@property (nonatomic, strong) NSString *rtcToken;
@property (nonatomic, strong) NSString *rtcRoomId;
@property (nonatomic, strong) NSDate *startTime;

@end

NS_ASSUME_NONNULL_END
