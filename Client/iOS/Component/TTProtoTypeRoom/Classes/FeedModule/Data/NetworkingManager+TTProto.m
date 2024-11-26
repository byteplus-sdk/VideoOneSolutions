//
//  NetworkingManager+TTProto.m
//  TTProtoTypeRoom
//
//  Created by ByteDance on 2024/9/5.
//

#import "NetworkingManager+TTProto.h"
#import <AppConfig/BuildConfig.h>
#import <YYModel/YYModel.h>
#import <ToolKit/Toolkit.h>


@implementation NetworkingManager (TTProto)

+ (void)dataForMixFeedData:(NSRange)range
                    userId:(NSString *)userId
             success:(void (^__nullable)(NSArray<TTMixModel *> *mixModels))success
                   failure:(void (^__nullable)(NSString *errorMessage))failure {
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    if (range.length) {
        [param setValue:@(range.location) forKey:@"offset"];
        [param setValue:@(range.length) forKey:@"page_size"];
        [param setValue:userId forKey:@"user_id"];
    } else {
        [param setValue:userId forKey:@"user_id"];
    }
    
     [param setValue:RTCAPPID forKey:@"app_id"];
    
    [NetworkingManager postWithPath:@"liveFeed/v1/getFeedStreamWithLive" parameters:param block:^(NetworkingResponse * _Nonnull response) {
        if (!response.result) {
            if (failure) {
                failure(response.error.localizedDescription);
            }
            return;
        }
        NSMutableArray *medias = [NSMutableArray array];
        if ([response.response isKindOfClass:[NSArray class]]) {
            NSArray *ary = (NSArray *)response.response;
            for (NSDictionary *dic in ary) {
                TTMixModel *mixModel = [TTMixModel yy_modelWithDictionary:dic];
                [medias addObject:mixModel];
            }
        }
        if (success) success(medias);
    }];
}

+ (void)dataForLiveFeedData:(NSRange)range userId:(NSString *)userId roomId:(NSString *)roomId success:(void (^)(NSArray<TTLiveModel *> * _Nonnull))success failure:(void (^)(NSString * _Nonnull))failure {
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    if (range.length) {
        [param setValue:@(range.location) forKey:@"offset"];
        [param setValue:@(range.length) forKey:@"page_size"];
        [param setValue:userId forKey:@"user_id"];
        [param setValue:roomId forKey:@"room_id"];
    } else {
        [param setValue:userId forKey:@"user_id"];
        [param setValue:roomId forKey:@"room_id"];
    }
    
     [param setValue:RTCAPPID forKey:@"app_id"];
    
    [NetworkingManager postWithPath:@"liveFeed/v1/getFeedStreamOnlyLive" parameters:param block:^(NetworkingResponse * _Nonnull response) {
        if (!response.result) {
            if (failure) {
                failure(response.error.localizedDescription);
            }
            return;
        }
        NSMutableArray *medias = [NSMutableArray array];
        if ([response.response isKindOfClass:[NSArray class]]) {
            NSArray *ary = (NSArray *)response.response;
            for (NSDictionary *dic in ary) {
                TTLiveModel *liveModel = [TTLiveModel yy_modelWithDictionary:dic];
                [medias addObject:liveModel];
            }
        }
        if (success) success(medias);
    }];
}

+ (void)liveSwitchFeedRoom:(NSString *)oldRoomId
                 newRoomId:(NSString *)newRoomId
                    userId:(NSString *)userID
                   success:(void (^)(NSInteger))success
                   failure:(void (^)(NSString * _Nonnull))failure {
    VOLogI(VOTTProto, @"oldRoomId: %@, newRoomId: %@, userId: %@", oldRoomId, newRoomId, userID);
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:oldRoomId forKey:@"old_room_id"];
    [param setValue:newRoomId forKey:@"new_room_id"];
    [param setValue:userID forKey:@"user_id"];
     [param setValue:RTCAPPID forKey:@"app_id"];
    [NetworkingManager postWithPath:@"liveFeed/v1/switchFeedLiveRoom" parameters:param block:^(NetworkingResponse * _Nonnull response) {
        if (!response.result) {
            if (failure) {
                failure(response.error.localizedDescription);
            }
            return;
        }
        NSInteger audienceCount =  [response.response[@"audience_count"] integerValue];
        if (success) {
            success(audienceCount);
        }
    }];
}

+ (void)sendMessageInLiveRoom:(NSString *)roomId userId:(NSString *)userId messageModel:(LiveMessageModel *)messageModel success:(void (^ _Nullable)(void))success failure:(void (^ _Nullable)(NSString * _Nonnull))failure {
    NSString *message = [messageModel yy_modelToJSONString];
    VOLogI(VOTTProto, @"roomId: %@, userId: %@, message: %@", roomId, userId, message);
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:roomId forKey:@"room_id"];
    [param setValue:userId forKey:@"user_id"];
    [param setValue:message forKey:@"message"];
     [param setValue:RTCAPPID forKey:@"app_id"];
    [NetworkingManager postWithPath:@"liveFeed/v1/liveSendMessage"  parameters:param block:^(NetworkingResponse * _Nonnull response) {
        if (!response.result) {
            if (failure) {
                failure(response.error.localizedDescription);
            }
            return;
        }
        if (success) {
            success();
        }
    }];
}
@end
