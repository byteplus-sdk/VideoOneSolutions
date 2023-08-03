// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RTCJoinModel : NSObject

@property (nonatomic, copy) NSString *roomId;
@property (nonatomic, assign) NSInteger errorCode;
@property (nonatomic, assign) NSInteger joinType;
@property (nonatomic, assign) NSInteger elapsed;

+ (RTCJoinModel *)modelArrayWithClass:(NSString *)extraInfo
                                state:(NSInteger)state
                               roomId:(NSString *)roomId;

@end

NS_ASSUME_NONNULL_END
