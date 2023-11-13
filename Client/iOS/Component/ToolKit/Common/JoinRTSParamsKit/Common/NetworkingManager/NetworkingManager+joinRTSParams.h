// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import "NetworkingManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface NetworkingManager (joinRTSParams)

#pragma mark - RTS


/*
 * Join RTS
 * @param scenes Scenes name
 * @param loginToken Login token
 * @param block Callback
 */
+ (void)joinRTS:(NSDictionary *)dic
          block:(void (^ __nullable)(NetworkingResponse *response))block;


@end

NS_ASSUME_NONNULL_END
