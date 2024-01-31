//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "NetworkingManager+SingleFunction.h"
#import "VEVideoModel.h"

@implementation NetworkingManager (SingleFunction)

+ (void)dataForScene:(VESceneType)sceneType
        functionType:(VESingleFunctionType)functionType
             success:(void (^)(VEVideoModel *_Nonnull))success
             failure:(void (^)(NSString *_Nonnull))failure {
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:@{@"videoType": @(sceneType)}];
    if (functionType == VESingleFunctionTypePreventRecording) {
        param[@"antiScreenshotAndRecord"] = @(YES);
    } else if (functionType == VESingleFunctionTypeSmartSubtitles) {
        param[@"supportSmartSubtitle"] = @(YES);
    }
    [NetworkingManager postWithPath:@"vod/v1/getFeedStreamWithPlayAuthToken"
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
        if ([response.response isKindOfClass:[NSArray class]]) {
            NSArray *ary = (NSArray *)response.response;
            if (ary.count > 0) {
                VEVideoModel *videoModel = [VEVideoModel yy_modelWithDictionary:ary.firstObject];
                if (success) success(videoModel);
                return;
            }
        }
        if (failure) {
            failure(BadServerResponseMsg);
        }
    }];
}

@end
