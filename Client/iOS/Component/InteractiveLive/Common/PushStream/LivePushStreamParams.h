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

@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, assign) NSInteger fps;
@property (nonatomic, assign) NSInteger gop;


@property (nonatomic, assign) NSInteger minBitrate;
@property (nonatomic, assign) NSInteger maxBitrate;
@property (nonatomic, assign) NSInteger defaultBitrate;

@end

NS_ASSUME_NONNULL_END
