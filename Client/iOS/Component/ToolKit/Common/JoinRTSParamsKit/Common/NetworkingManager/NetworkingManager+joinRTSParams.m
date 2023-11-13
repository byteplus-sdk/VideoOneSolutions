// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import "NetworkingManager+joinRTSParams.h"

@implementation NetworkingManager (joinRTSParams)

+ (void)joinRTS:(NSDictionary *)dic
          block:(void (^ __nullable)(NetworkingResponse *response))block {
    [self postWithEventName:@"joinRTS"
                      space:@"login"
                    content:dic
                      block:block];
}

@end
