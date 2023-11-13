//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "NetworkingManager+Uploader.h"
#import <AppConfig/BuildConfig.h>
#import <ToolKit/PublicParameterComponent.h>
#import <Toolkit/Constants.h>

@implementation NetworkingManager (Uploader)

+ (void)getUploadToken:(void (^)(STSToken *_Nullable, NetworkingResponse *_Nonnull))block {
    [self getWithPath:@"vod/v1/upload"
           parameters:@{@"expiredTime": @(60)}
                block:^(NetworkingResponse *_Nonnull response) {
                    STSToken *token = nil;
                    if (response.result) {
                        token = [STSToken yy_modelWithDictionary:response.response];
                    }
                    if (block) {
                        block(token, response);
                    }
                }];
}

@end
