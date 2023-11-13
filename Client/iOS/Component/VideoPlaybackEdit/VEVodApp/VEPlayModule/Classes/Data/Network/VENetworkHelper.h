// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
@import Foundation;

typedef void(^HttpSuccessResponseBlock)(id _Nonnull responseObject);
typedef void(^HttpFailureResponseBlock)(NSString * _Nonnull errorMessage);

@interface VENetworkHelper : NSObject

+ (void)requestDataWithUrl:(NSString *_Nonnull)url
                httpMethod:(NSString *_Nonnull)method
                parameters:(NSDictionary * _Nonnull)parameters
                   success:(HttpSuccessResponseBlock _Nullable )success
                   failure:(HttpFailureResponseBlock _Nullable )failure;

@end
