// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "NetworkingResponse.h"
#import "NetworkingTool.h"
#import <YYModel/YYModel.h>

@implementation NetworkingResponse

+ (instancetype)dataToResponseModel:(id)data {
    NetworkingResponse *response = [self yy_modelWithJSON:data];
    if (response && response.code != RTSStatusCodeSuccess) {
        NSString *message = [NetworkingTool messageFromResponseCode:response.code];
        if (message && message.length > 0) {
            response.message = message;
        }
    }
    if (!response) {
        response = [self badServerResponse];
    }
    return response;
}

+ (instancetype)badServerResponse {
    NetworkingResponse *response = [[self alloc] init];
    response.code = RTSStatusCodeBadServerResponse;
    response.message = [NetworkingTool messageFromResponseCode:response.code];
    return response;
}

+ (instancetype)responseWithError:(NSError *)error {
    NetworkingResponse *response = [[NetworkingResponse alloc] init];
    response.code = error.code;
    response.message = error.localizedDescription;
    response.error = error;
    return response;
}

- (BOOL)result {
    if (self.code == RTSStatusCodeSuccess) {
        return YES;
    } else {
        return NO;
    }
}

@end
