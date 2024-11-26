//
//  TTRTSManager.m
//  AFNetworking
//
//  Created by ByteDance on 2024/9/12.
//

#import "TTRTSManager.h"
#import "TTRTCManager.h"
#import "LiveMessageModel.h"
#import "TTRTCManager.h"
#import <ToolKit/ToolKit.h>

@implementation TTRTSManager

+ (void)registerOnLiveFeedJoinRoomWithBlock:(void (^)(NSInteger))block  {
//    [TTRTCManager shareRtc].joinRoomBlock = ^(NSInteger audienceCount) {
//        if (block) {
//            block(audienceCount);
//        }
//    };
}

+ (void)registerOnLiveFeedUserJoinRoom:(void (^)(NSString * _Nonnull, NSString * _Nonnull, NSInteger))block {
    [[TTRTCManager shareRtc] onSceneListener:@"feedLiveOnUserJoin" block:^(RTSNoticeModel * _Nonnull noticeModel) {
        NSString *userId = nil;
        NSString *userName = nil;
        NSInteger count = -1;
        if (noticeModel.data && [noticeModel.data isKindOfClass:[NSDictionary class]]) {
            userId = [NSString stringWithFormat:@"%@", noticeModel.data[@"user_id"]];
            userName = [NSString stringWithFormat:@"%@", noticeModel.data[@"user_name"]];
            count =  [noticeModel.data[@"audience_count"] integerValue];
        }
        VOLogI(VOTTProto, @"userId: %@, userName: %@, audienceCount: %ld", userId, userName, count);
        if (block) {
            block(userId, userName, count);
        }
    }];
}

+ (void)registerOnLiveFeedUserLeaveRoom:(void (^)(NSString * _Nonnull, NSString * _Nonnull, NSInteger))block {
    [[TTRTCManager shareRtc] onSceneListener:@"feedLiveOnUserLeave" block:^(RTSNoticeModel * _Nonnull noticeModel) {
        NSString *userId = nil;
        NSString *userName = nil;
        NSInteger count = -1;
        if (noticeModel.data && [noticeModel.data isKindOfClass:[NSDictionary class]]) {
            userId = [NSString stringWithFormat:@"%@", noticeModel.data[@"user_id"]];
            userName = [NSString stringWithFormat:@"%@", noticeModel.data[@"user_name"]];
            count =  [noticeModel.data[@"audience_count"] integerValue];
        }
        VOLogI(VOTTProto, @"userId: %@, userName: %@, audienceCount: %ld", userId, userName, count);
        if (block) {
            block(userId, userName, count);
        }
    }];
}

+ (void)registerOnLiveFeedMessageSendWithBlock:(void (^)(NSString * _Nonnull, NSString * _Nonnull,  LiveMessageModel *messageModel))block {
    [[TTRTCManager shareRtc] onSceneListener:@"feedLiveOnMessageSend" block:^(RTSNoticeModel * _Nonnull noticeModel) {
        NSString *userId = nil;
        NSString *userName = nil;
        LiveMessageModel *model = nil;
        if (noticeModel.data && [noticeModel.data isKindOfClass:[NSDictionary class]]) {
            userId = [NSString stringWithFormat:@"%@", noticeModel.data[@"user_id"]];
            userName = [NSString stringWithFormat:@"%@", noticeModel.data[@"user_name"]];
            model = [LiveMessageModel yy_modelWithJSON:noticeModel.data[@"message"]];
            model.userId = userId;
            model.userName = userName;
        }
        VOLogI(VOTTProto, @"userId: %@, userName: %@, type: %ld", userId, userName, model.type);
        if (block) {
            block(userId, userName, model);
        }
    }];
}

+ (void)removeAllListeners {
//    [TTRTCManager shareRtc].joinRoomBlock = nil;
    [[TTRTCManager shareRtc] offSceneListener];
}
@end
