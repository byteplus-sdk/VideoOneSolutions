//
//  TTRTSManager.h
//  AFNetworking
//
//  Created by ByteDance on 2024/9/12.
//

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
