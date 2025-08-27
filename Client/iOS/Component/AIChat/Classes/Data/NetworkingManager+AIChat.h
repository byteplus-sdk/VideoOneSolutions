//
//  NetworkingManager+AIChat.h
//  AIChat-AIChat
//
//  Created by ByteDance on 2025/3/11.
//
#import "NetworkingManager.h"
#import "AIConfigModel.h"
#import "AIRoomInfoModel.h"
#import "AISettingModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NetworkingManager(AIChat)

+ (void)requestAIConfig:(void (^)(AIConfigModel * _Nullable response))success
            fallure:(void (^)(NSString * _Nullable errMsg))failure;

+ (void)requestStartRealTimeAIChat:(AIRoomInfoModel *)roomInfo
                       settingInfo:(AISettingModel *)settingInfo
                           success:(void (^)(BOOL res))success
                           fallure:(void (^)(NSString * _Nullable errMsg))failure;

+ (void)requestStopRealTimeAIChat:(AIRoomInfoModel *)roomInfo
                          success:(void (^)(BOOL res))success
                          fallure:(void (^)(NSString * _Nullable errMsg))failure;

+ (void)requestStartFlexibleAIChat:(AIRoomInfoModel *)roomInfo
                        settingInfo:(AISettingModel *)settingInfo
                            success:(void (^)(BOOL res))success
                            fallure:(void (^)(NSString * _Nullable errMsg))failure;

+ (void)requestStopFlexibleAIChat:(AIRoomInfoModel *)roomInfo
                          success:(void (^)(BOOL res))success
                          fallure:(void (^)(NSString * _Nullable errMsg))failure;

+ (void)requestRTCRoomToken:(NSString *)roomId success:(void (^)(NSString *token))success
                    fallure:(void (^)(NSString * _Nullable errMsg))failure;

@end

NS_ASSUME_NONNULL_END
