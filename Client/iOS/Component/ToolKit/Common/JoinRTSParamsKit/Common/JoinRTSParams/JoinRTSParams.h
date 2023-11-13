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
        

/**
 *
 * Network request public parameter usage
 * @param dic Dic parameter, can be nil
 */

+ (NSDictionary *)addTokenToParams:(NSDictionary * _Nullable)dic;


@end

NS_ASSUME_NONNULL_END
