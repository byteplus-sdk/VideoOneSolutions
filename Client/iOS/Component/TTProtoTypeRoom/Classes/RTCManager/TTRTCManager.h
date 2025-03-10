// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import <ToolKit/BaseRTCManager.h>


NS_ASSUME_NONNULL_BEGIN


@interface TTRTCManager : BaseRTCManager

+ (TTRTCManager *_Nullable)shareRtc;

@property (nonatomic, assign, nullable) void (^joinRoomBlock)(NSInteger audienceCount);

- (void)joinRoomByToken:(NSString *)token
                     roomID:(NSString *)roomID
                     userID:(NSString *)userID;

- (void)leaveRoom;

@end

NS_ASSUME_NONNULL_END
