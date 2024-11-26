//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "NetworkingManager+Vod.h"
#import "VECommentModel.h"
#import "VEVideoModel.h"

@implementation NetworkingManager (Vod)

+ (void)dataForScene:(VESceneType)type
               range:(NSRange)range
             success:(void (^)(NSArray<VEVideoModel *> *_Nonnull))success
             failure:(void (^)(NSString *_Nonnull))failure {
    NSDictionary *param;
    if (range.length) {
        param = @{@"videoType": @(type), @"offset": @(range.location), @"pageSize": @(range.length)};
    } else {
        param = @{@"videoType": @(type)};
    }
    [NetworkingManager postWithPath:@"vod/v1/getFeedStreamWithPlayAuthToken"
                         parameters:param
                              block:^(NetworkingResponse *_Nonnull response) {
                                  if (!response.result) {
                                      if (failure) {
                                          failure(response.error.localizedDescription);
                                      }
                                      return;
                                  }
                                  NSMutableArray *medias = [NSMutableArray array];
                                  if ([response.response isKindOfClass:[NSArray class]]) {
                                      NSArray *ary = (NSArray *)response.response;
                                      for (NSDictionary *dic in ary) {
                                          VEVideoModel *videoModel = [VEVideoModel yy_modelWithDictionary:dic];
                                          [medias addObject:videoModel];
                                      }
                                  }
                                  if (success) success(medias);
                              }];
}



@end
