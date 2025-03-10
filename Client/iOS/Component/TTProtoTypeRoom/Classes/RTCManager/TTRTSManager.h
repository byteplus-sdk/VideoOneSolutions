// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "LiveMessageModel.h"
#import "LiveMessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTRTSManager : NSObject

#pragma mark - Global Notification message
+ (void)registerOnLiveFeedJoinRoomWithBlock:(void(^)(NSInteger audienceCount))block;
+ (void)registerOnLiveFeedMessageSendWithBlock:(void (^)(NSString *userId,
                                                 NSString *userName,
                                                 LiveMessageModel *messageModel))block;
+ (void)registerOnLiveFeedUserJoinRoom:(void (^)(NSString* userId,
                                         NSString *userName,
                                         NSInteger audienceCount))block;
+ (void)registerOnLiveFeedUserLeaveRoom:(void (^)(NSString* userId,
                                         NSString *userName,
                                         NSInteger audienceCount))block;

+ (void) removeAllListeners;
@end

NS_ASSUME_NONNULL_END
