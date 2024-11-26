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
#import <ToolKit/ToolKit.h>

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

#pragma mark Public

+ (void)callHttpEvent:(nonnull NSString *)eventName
              content:(nonnull NSDictionary *)content
                block:(nullable NetworkingManagerBlock)block {
    NSString *url = [NSString stringWithFormat:@"%@/http_call?event_name=%@", ServerUrl, eventName];

    NSMutableDictionary *parameters = [NetworkingManager httpEventCommons];
    [parameters addEntriesFromDictionary:content];

    NSDictionary *headers = @{
        @"X-Login-Token": [LocalUserComponent userModel].loginToken
    };

    [self postWithUrl:url
           parameters:parameters
              headers:headers
                block:block];
}

+ (void)postWithEventName:(NSString *)eventName
                    space:(NSString *)space
                  content:(NSDictionary *)content
                    block:(nullable NetworkingManagerBlock)block {
    NSString *URLString = [NSString stringWithFormat:@"%@/%@", ServerUrl, space];
    NSString *appid = [PublicParameterComponent share].appId;
    NSDictionary *parameters = @{@"event_name": eventName ?: @"",
                                 @"language": [Localizator getLanguageKey],
                                 @"content": [content yy_modelToJSONString] ?: @{},
                                 @"device_id": [NetworkingTool getDeviceId] ?: @"",
                                 @"app_id": appid ? appid : @""};
    [self postWithUrl:URLString
            parameters:parameters
               headers:nil
                 block:block];
}



+ (void)postWithPath:(NSString *)path
          parameters:(nullable id)parameters
               block:(nullable NetworkingManagerBlock)block {
    [self postWithPath:path
           parameters:parameters
              headers:nil
             progress:nil
                block:block];
}

+ (void)postWithPath:(NSString *)path
          parameters:(nullable id)parameters
             headers:(nullable NSDictionary<NSString *, NSString *> *)headers
               block:(nullable NetworkingManagerBlock)block {
    [self postWithPath:path
           parameters:parameters
              headers:headers
             progress:nil
                block:block];
}


+ (void)postWithPath:(NSString *)path
          parameters:(nullable id)parameters
             headers:(nullable NSDictionary<NSString *, NSString *> *)headers
            progress:(nullable void (^)(NSProgress *))uploadProgress
               block:(nullable NetworkingManagerBlock)block {
    
    NSAssert(uploadProgress == nil, @"Simplify the api, ignore the progress block.");
    
    NSString *URLString = [NSString stringWithFormat:@"%@/%@", ServerUrl, path];
    [self postWithUrl:URLString
           parameters:parameters
              headers:headers
                block:block];
}

+ (void)getWithPath:(NSString *)path
         parameters:(nullable id)parameters
              block:(nullable NetworkingManagerBlock)block {
    NSString *URLString = [NSString stringWithFormat:@"%@/%@", ServerUrl, path];
    [[self shareManager].sessionManager GET:URLString
                                 parameters:parameters
                                    headers:nil
                                   progress:nil
                                    success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
        [self processResponse:responseObject block:block];
        VOLogI(VOToolKit, @"%@ REQUEST: %@", URLString, parameters);
        VOLogI(VOToolKit, @"%@ RESPONSE: %@", URLString, responseObject);
    } failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
        if (block) {
            block([NetworkingResponse responseWithError:error]);
        }
        VOLogI(VOToolKit, @"%@ REQUEST: %@", URLString, parameters);
        VOLogE(VOToolKit, @"%@ RESPONSE: failure: %@", URLString, task.response);
    }];
}

+ (void)processResponse:(id _Nullable)responseObject
                  block:(nullable NetworkingManagerBlock)block {
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

#pragma mark Private

+ (void)postWithUrl:(NSString *)URLString
         parameters:(id)parameters
            headers:(NSDictionary<NSString *, NSString *> *)headers
              block:(nullable NetworkingManagerBlock)block {
    AFHTTPSessionManager *sessionManager = [self shareManager].sessionManager;
    
    [sessionManager POST:URLString
              parameters:parameters
                 headers:headers
                progress:nil
                 success:^(NSURLSessionDataTask *_Nonnull task,
                           id _Nullable responseObject) {
        [NetworkingManager processResponse:responseObject
                                     block:block];
        VOLogI(VOToolKit, @"%@ REQUEST: %@", URLString, parameters);
        VOLogI(VOToolKit, @"%@ RESPONSE: %@", URLString, responseObject);
    }
                 failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
        if (block) {
            block([NetworkingResponse responseWithError:error]);
        }
        
        VOLogI(VOToolKit, @"%@ REQUEST: %@", URLString, parameters);
        VOLogE(VOToolKit, @"%@ RESPONSE: failure: %@", URLString, task.response);
    }];
}

+ (NSMutableDictionary *)httpEventCommons {
    NSMutableDictionary *params = [NSMutableDictionary new];

    NSString *rtcAppId = [PublicParameterComponent share].appId;
    if (NOEmptyStr(rtcAppId)) {
        [params setValue:rtcAppId forKey:@"app_id"];
    }

    NSString *userId = [LocalUserComponent userModel].uid;
    if (NOEmptyStr(userId)) {
        [params setValue:userId forKey:@"user_id"];
    }

    NSString *deviceId = [NetworkingTool getDeviceId];
    if (NOEmptyStr(deviceId)) {
        [params setValue:deviceId forKey:@"device_id"];
    }

    [params setValue:[Localizator getLanguageKey] forKey:@"language"];

    return params;
}

@end
