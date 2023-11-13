//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <Foundation/Foundation.h>

@class LiveUserModel;
NS_ASSUME_NONNULL_BEGIN

@interface LivePushStreamParams : NSObject

@property (nonatomic, copy) NSString *rtcToken;
@property (nonatomic, copy) NSString *rtcRoomId;
@property (nonatomic, copy) NSString *currerntUserId;

@property (nonatomic, copy) NSString *pushUrl;

@property (nonatomic, strong) LiveUserModel *host;

@end

NS_ASSUME_NONNULL_END
