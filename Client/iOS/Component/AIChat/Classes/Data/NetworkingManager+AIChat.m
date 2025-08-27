//
//  NetworkingManager+AIChat.m
//  AIChat-AIChat
//
//  Created by ByteDance on 2025/3/11.
//

#import "NetworkingManager+AIChat.h"

@implementation NetworkingManager (AIChat)

+ (void)requestAIConfig:(void (^)(AIConfigModel * _Nullable))success 
                fallure:(void (^)(NSString * _Nullable))failure {
    NSDictionary *params = @{};
    NSString *urlString = [NSString stringWithFormat:@"aigc/v1/getAIConfig?lang=%@", [Localizator isChinese] ? @"zh_cn" : @"en"];
    [NetworkingManager getWithPath:urlString
                        parameters:params
                             block:^(NetworkingResponse * _Nonnull response) {
        if (!response.result) {
            if (failure) {
                failure(response.message);
            }
            return;
           
        }
        AIConfigModel *model = nil;
        if ([response.response isKindOfClass:[NSDictionary class]]) {
             model = [AIConfigModel yy_modelWithDictionary:response.response];
        }
        if (success) {
            success(model);
        }
    }];
}

+ (void)requestStartRealTimeAIChat:(AIRoomInfoModel *)roomInfo 
                       settingInfo:(AISettingModel *)settingInfo 
                           success:(void (^)(BOOL))success
                           fallure:(void (^)(NSString * _Nullable))failure {
    NSDictionary *params = @{
        @"rtc_app_id": [PublicParameterComponent share].appId ?: @"",
        @"room_id": roomInfo.roomId ?: @"",
        @"user_id": roomInfo.userId ?: @"",
        @"voice_type": settingInfo.currentVoiceRoleName ?: @"",
        @"voice_provider": settingInfo.currentVoiceProviderName ?: @"",
        @"prompt": settingInfo.prompt ?: @"",
        @"welcome_speech": settingInfo.welcomeSpeech ?: @""
    };
    [NetworkingManager postWithPath:@"aigc/v1/startRealTimeVoiceChat"
                         parameters:params
                              block:^(NetworkingResponse * _Nonnull response) {
        if (!response.result) {
            if (failure) {
                failure(response.message);
            }
            return;
        }
        if (success) {
            success(YES);
        }
    }];
}

+ (void)requestStopRealTimeAIChat:(AIRoomInfoModel *)roomInfo
                          success:(void (^)(BOOL))success
                          fallure:(void (^)(NSString * _Nullable))failure {
    NSDictionary *params = @{
        @"rtc_app_id": [PublicParameterComponent share].appId ?: @"",
        @"room_id": roomInfo.roomId ?: @"",
        @"user_id": roomInfo.userId ?: @""
    };
    [NetworkingManager postWithPath:@"aigc/v1/stopRealTimeVoiceChat"
                         parameters:params
                              block:^(NetworkingResponse * _Nonnull response) {
        if (!response.result) {
            if (failure) {
                failure(response.message);
            }
            return;
        }
        if (success) {
            success(YES);
        }
    }];
}

+ (void)requestStartFlexibleAIChat:(AIRoomInfoModel *)roomInfo
                        settingInfo:(AISettingModel *)settingInfo
                            success:(void (^)(BOOL))success
                            fallure:(void (^)(NSString * _Nullable))failure {
    NSDictionary *params = @{
        @"rtc_app_id": [PublicParameterComponent share].appId ?: @"",
        @"room_id": roomInfo.roomId ?: @"",
        @"user_id": roomInfo.userId ?: @"",
        @"voice_type": settingInfo.currentVoiceRoleName ?: @"",
        @"voice_provider": settingInfo.currentVoiceProviderName ?: @"",
        @"llm_provider": settingInfo.currentLLMVendorName ?: @"",
        @"asr_provider": settingInfo.currentASRVendorName ?: @"",
        @"prompt": settingInfo.prompt ?: @"",
        @"welcome_speech": settingInfo.welcomeSpeech ?: @""
    };
    [NetworkingManager postWithPath:@"aigc/v1/startFlexibleVoiceChat"
                         parameters:params
                              block:^(NetworkingResponse * _Nonnull response) {
        if (!response.result) {
            if (failure) {
                failure(response.message);
            }
            return;
        }
        if (success) {
            success(YES);
        }
    }];
}

+ (void)requestStopFlexibleAIChat:(AIRoomInfoModel *)roomInfo
                          success:(void (^)(BOOL))success
                          fallure:(void (^)(NSString * _Nullable))failure {
    NSDictionary *params = @{
        @"rtc_app_id": [PublicParameterComponent share].appId ?: @"",
        @"room_id": roomInfo.roomId ?: @"",
        @"user_id": roomInfo.userId ?: @""
    };
    [NetworkingManager postWithPath:@"aigc/v1/stopFlexibleVoiceChat"
                         parameters:params
                              block:^(NetworkingResponse * _Nonnull response) {
        if (!response.result) {
            if (failure) {
                failure(response.message);
            }
            return;
        }
        if (success) {
            success(YES);
        }
    }];
}


+ (void)requestRTCRoomToken:(NSString *)roomId success:(void (^)(NSString * _Nonnull))success
                    fallure:(void (^)(NSString * _Nullable))failure {
    NSDictionary *param = @{
        @"os": @"iOS",
        @"login_token": [LocalUserComponent userModel].loginToken ?: @"",
        @"room_id": roomId ?: @"",
        @"user_id": [LocalUserComponent userModel].uid ?: @"",
         @"app_key": RTCAPPKey ?: @"",
        @"app_id": [PublicParameterComponent share].appId ?: @""
    };
    [NetworkingManager postWithPath:@"getRTCJoinRoomToken"
                         parameters:param
                            headers:nil
                           progress:nil
                              block:^(NetworkingResponse *_Nonnull response) {
        if (!response.result) {
            if (failure) {
                failure(response.message);
            }
            return;
        }
        NSString *RTCToken = @"";
        if ([response.response isKindOfClass:[NSDictionary class]]) {
            RTCToken = [NSString stringWithFormat:@"%@", response.response[@"Token"]];
        }
        
        if (success) {
            success(RTCToken);
        }
    }];
}

@end
