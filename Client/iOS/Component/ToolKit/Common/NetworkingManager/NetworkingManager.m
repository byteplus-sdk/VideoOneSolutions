// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "NetworkingManager.h"
#import "BuildConfig.h"
#import "Localizator.h"
#import "NetworkingTool.h"
#import "NotificationConstans.h"
#import "PublicParameterComponent.h"
#import <AFNetworking/AFNetworking.h>
#import <YYModel/YYModel.h>

@interface NetworkingManager ()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end

@implementation NetworkingManager

- (instancetype)init {
    self = [super init];
    if (self) {
        self.sessionManager = [AFHTTPSessionManager manager];
        self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        self.sessionManager.requestSerializer.timeoutInterval = 15.0;
        self.sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",
                                                                                              @"text/json",
                                                                                              @"text/javascript",
                                                                                              @"text/plain",
                                                                                              nil];
    }
    return self;
}

+ (NetworkingManager *)shareManager {
    static NetworkingManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[NetworkingManager alloc] init];
    });
    return manager;
}

#pragma mark - User

+ (void)changeUserName:(NSString *)userName
            loginToken:(NSString *)loginToken
                 block:(void (^)(NetworkingResponse *_Nonnull))block {
    NSDictionary *content = @{@"user_name": userName ?: @"",
                              @"login_token": loginToken ?: @""};
    [self postWithEventName:@"changeUserName" space:@"login" content:content block:block];
}

#pragma mark -

+ (void)postWithEventName:(NSString *)eventName
                    space:(NSString *)space
                  content:(NSDictionary *)content
                    block:(void (^__nullable)(NetworkingResponse *response))block {
    NSString *appid = [PublicParameterComponent share].appId;
    NSDictionary *parameters = @{@"event_name": eventName ?: @"",
                                 @"language": [Localizator getLanguageKey],
                                 @"content": [content yy_modelToJSONString] ?: @{},
                                 @"device_id": [NetworkingTool getDeviceId] ?: @"",
                                 @"app_id": appid ? appid : @""};
    [self postWithPath:space parameters:parameters headers:nil progress:nil block:block];
}

+ (void)postWithParameters:(id)parameters space:(NSString *)space block:(void (^)(NetworkingResponse * _Nonnull))block {
    [self postWithPath:space parameters:parameters headers:nil progress:nil block:block];
}

+ (void)postWithPath:(NSString *)path
          parameters:(id)parameters
             headers:(NSDictionary<NSString *, NSString *> *)headers
            progress:(void (^)(NSProgress *_Nonnull))uploadProgress
               block:(void (^)(NetworkingResponse *_Nonnull))block {
    NSString *URLString = [NSString stringWithFormat:@"%@/%@", ServerUrl, path];
    [[self shareManager].sessionManager POST:URLString
        parameters:parameters
        headers:headers
        progress:uploadProgress
        success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
            [self processResponse:responseObject block:block];
            NSLog(@"[%@]-%@ %@", [self class], path, responseObject);
        } failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
            if (block) {
                block([NetworkingResponse responseWithError:error]);
            }
            NSLog(@"[%@]-%@ failure %@", [self class], path, task.response);
        }];
}

+ (void)getWithPath:(NSString *)path
         parameters:(nullable id)parameters
              block:(void (^)(NetworkingResponse *_Nonnull))block {
    NSString *URLString = [NSString stringWithFormat:@"%@/%@", ServerUrl, path];
    [[self shareManager].sessionManager GET:URLString
        parameters:parameters
        headers:nil
        progress:nil
        success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
            [self processResponse:responseObject block:block];
            NSLog(@"[%@]-%@ %@", [self class], path, responseObject);
        } failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
            if (block) {
                block([NetworkingResponse responseWithError:error]);
            }
            NSLog(@"[%@]-%@ failure %@", [self class], path, task.response);
        }];
}

+ (void)processResponse:(id _Nullable)responseObject
                  block:(void (^__nullable)(NetworkingResponse *response))block {
    NetworkingResponse *response = [NetworkingResponse dataToResponseModel:responseObject];
    if (block) {
        block(response);
    }
    if (response.code == RTSStatusCodeTokenExpired) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationLogout
                                                            object:self
                                                          userInfo:@{NotificationLogoutReasonKey: @"token_expired"}];
    }
}

@end
