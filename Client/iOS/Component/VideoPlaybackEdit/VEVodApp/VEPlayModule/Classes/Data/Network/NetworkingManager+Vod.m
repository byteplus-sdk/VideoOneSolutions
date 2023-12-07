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
                            headers:nil
                           progress:nil
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

+ (void)similarDataForScene:(VESceneType)type
                        vid:(NSString *)vid
                      range:(NSRange)range
                    success:(void (^)(NSArray<VEVideoModel *> *_Nonnull))success
                    failure:(void (^)(NSString *_Nonnull))failure {
    NSDictionary *param;
    if (range.length) {
        param = @{@"videoType": @(type),
                  @"vid": vid ?: @"",
                  @"offset": @(range.location),
                  @"pageSize": @(range.length)};
    } else {
        param = @{@"videoType": @(type),
                  @"vid": vid ?: @""};
    }
    [NetworkingManager postWithPath:@"vod/v1/getFeedSimilarVideos"
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

+ (void)getVideoCommentsForVid:(NSString *)vid
                    completion:(void (^)(NSArray<VECommentModel *> *_Nonnull, NetworkingResponse *_Nonnull))completion {
    NSDictionary *param = @{@"vid": vid};
    [NetworkingManager getWithPath:@"vod/v1/getVideoComments"
                        parameters:param
                             block:^(NetworkingResponse *_Nonnull response) {
                                 NSMutableArray *medias = nil;
                                 if (response.result) {
                                     medias = [NSMutableArray array];
                                     if ([response.response isKindOfClass:[NSArray class]]) {
                                         NSArray *ary = (NSArray *)response.response;
                                         for (NSDictionary *dic in ary) {
                                             VECommentModel *videoModel = [VECommentModel yy_modelWithDictionary:dic];
                                             [medias addObject:videoModel];
                                         }
                                     }
                                 }
                                 if (completion) completion(medias, response);
                             }];
}

@end
