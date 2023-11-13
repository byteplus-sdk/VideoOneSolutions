// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "RTCJoinModel.h"
#import "NetworkingTool.h"

@implementation RTCJoinModel

+ (RTCJoinModel *)modelArrayWithClass:(NSString *)extraInfo
                                state:(NSInteger)state
                               roomId:(NSString *)roomId {
    NSDictionary *dic = [NetworkingTool decodeJsonMessage:extraInfo];
    NSInteger errorCode = state;
    NSInteger joinType = -1;
    NSInteger elapsed = 0;
    if ([dic isKindOfClass:[NSDictionary class]]) {
        NSString *joinTypeStr = [NSString stringWithFormat:@"%@", dic[@"join_type"]];
        joinType = joinTypeStr.integerValue;
        if ([dic valueForKey:@"elapsed"]) {
            elapsed = [dic[@"elapse"] integerValue];
        }
    }

    RTCJoinModel *joinModel = [[RTCJoinModel alloc] init];
    joinModel.roomId = roomId;
    joinModel.errorCode = errorCode;
    joinModel.joinType = joinType;
    joinModel.elapsed = elapsed;
    return joinModel;
}

@end
