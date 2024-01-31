// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "NetworkingManager+PlayList.h"
#import "VEVideoModel.h"

@implementation NetworkingManager (PlayList)

+ (void)getPlayListDetail:(void (^)(NSArray<VEVideoModel *> *_Nonnull, PlayListMode))success failure:(void (^)(NSString *_Nonnull))failure {
    NSDictionary *param = @{};
    [NetworkingManager postWithPath:@"vod/v1/getPlayListDetail"
                         parameters:param
                            headers:nil
                           progress:nil
                              block:^(NetworkingResponse *_Nonnull response) {
        if (!response.result) {
            if (failure) {
                failure(response.error.localizedDescription);
            }
            return;
        }
        NSMutableArray *playList = [NSMutableArray array];
        PlayListMode mode = PlayListModeUnknown;
        if ([response.response isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)response.response;
            NSArray *ary = (NSArray *)dic[@"videoList"];
            NSString *modeStr = (NSString *)dic[@"playMode"];
            if ([modeStr isEqualToString:@"linear"]) {
                mode = PlayListModeLinear;
            } else if ([modeStr isEqualToString:@"loop"]) {
                mode = PlayListModeLoop;
            } else {
                NSLog(@"[PlayList] play mode(%lu) is unknown", mode);
            }
            for (NSDictionary *dic in ary) {
                VEVideoModel *videoModel = [VEVideoModel yy_modelWithDictionary:dic];
                [playList addObject:videoModel];
            }
            if (success) success(playList, mode);
            return;
        }
        if (failure) failure(BadServerResponseMsg);
    }];
}

@end
