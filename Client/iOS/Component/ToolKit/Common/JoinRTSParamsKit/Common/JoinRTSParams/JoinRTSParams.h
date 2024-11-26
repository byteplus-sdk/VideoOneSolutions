// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import <Foundation/Foundation.h>
#import "JoinRTSParamsModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface JoinRTSParams : NSObject

/**
 *
 * @brief Get RTS login information
 * @param inputInfo data model
 * @param block callback
 */

+ (void)getJoinRTSParams:(NSDictionary *)inputInfo
                   block:(void (^)(JoinRTSParamsModel *model))block;

@end

NS_ASSUME_NONNULL_END
