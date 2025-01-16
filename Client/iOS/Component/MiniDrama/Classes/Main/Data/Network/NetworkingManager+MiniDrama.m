//
//  NetworkingManager+MiniDrama.m
//  MiniDrama
//
//  Created by ByteDance on 2024/11/15.
//

#import "NetworkingManager+MiniDrama.h"
#import "NetworkingManager+VodPlayer.h"
#import <ToolKit/LocalUserComponent.h>

@implementation NetworkingManager (MiniDrama)

+ (void)getDramaDataForHomePageData:(void (^__nullable)(MDHomePageData *))success
                            failure:(void (^__nullable)(NSString *_Nonnull))failure {
    [NetworkingManager postWithPath:@"drama/v1/getDramaChannel"
                         parameters:@{}
                              block:^(NetworkingResponse *_Nonnull response) {
        if (!response.result) {
            if (failure) {
                failure(response.error.localizedDescription);
            }
            return;
        }
        MDHomePageData *pageData = [[MDHomePageData alloc] init];
        if ([response.response isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)response.response;
            pageData = [MDHomePageData yy_modelWithDictionary:dic];
        }
        if (success) success(pageData);
        
    }];
}

+ (void)getDramaDataForChannelPage:(NSRange)range 
                           success:(void (^)(NSArray<MDDramaFeedInfo *> * _Nonnull))success
                           failure:(void (^)(NSString * _Nonnull))failure {
    NSDictionary *param = @{ @"offset": @(range.location), @"page_size": @(range.length)};
    [NetworkingManager postWithPath:@"drama/v1/getDramaFeed"
                         parameters:param
                              block:^(NetworkingResponse * _Nonnull response) {
        if (!response.result) {
            if (failure) {
                failure(response.error.localizedDescription);
            }
            return;
        }
        NSMutableArray *dramaDataList = [[NSMutableArray alloc] init];
        if ([response.response isKindOfClass:[NSArray class]]) {
            NSArray *arr = (NSArray *)response.response;
            for (NSDictionary *dic in arr) {
                MDDramaFeedInfo *infoModel = [MDDramaFeedInfo yy_modelWithDictionary:dic];
                [dramaDataList addObject:infoModel];
            }
        }
        if (success) success(dramaDataList);
    }];
}

+ (void)getDramaDataForDetailPage:(NSString *)dramaId 
                          success:(void (^)(NSArray<MDDramaEpisodeInfoModel *> * _Nonnull))success
                          failure:(void (^)(NSString * _Nonnull))failure {
    NSDictionary *param = @{ @"drama_id": dramaId, @"user_id": [LocalUserComponent userModel].uid};
    [NetworkingManager postWithPath:@"drama/v1/getDramaList"
                         parameters:param
                              block:^(NetworkingResponse * _Nonnull response) {
        if (!response.result) {
            if (failure) {
                failure(response.error.localizedDescription);
            }
            return;
        }
        NSMutableArray *dramaDataList = [[NSMutableArray alloc] init];
        if ([response.response isKindOfClass:[NSArray class]]) {
            NSArray *arr = (NSArray *)response.response;
            for (NSDictionary *dic in arr) {
                MDDramaEpisodeInfoModel *infoModel = [MDDramaEpisodeInfoModel yy_modelWithDictionary:dic];
                [dramaDataList addObject:infoModel];
            }
        }
        if (success) success(dramaDataList);
    }];
}

+ (void)getDramaDataForPaymentEpisodeInfo:(NSString *)userId 
                                  dramaId:(NSString *)dramaId
                                  vidList:(NSArray<NSString *> *)videoIdList
                                  success:(void (^)(NSArray<MDSimpleEpisodeInfoModel *> * _Nonnull))success
                                  failure:(void (^)(NSString * _Nonnull))failure {
    NSDictionary *param = @{ @"user_id": userId, @"drama_id": dramaId ,@"vid_list": videoIdList, @"play_info_type": @(0) };
    [NetworkingManager postWithPath:@"drama/v1/getDramaDetail"
                         parameters:param
                              block:^(NetworkingResponse * _Nonnull response) {
        if (!response.result) {
            if (failure) {
                failure(response.error.localizedDescription);
            }
            return;
        }
        NSMutableArray *vipDataList = [[NSMutableArray alloc] init];
        if ([response.response isKindOfClass:[NSArray class]]) {
            NSArray *arr = (NSArray *)response.response;
            for (NSDictionary *dic in arr) {
                MDSimpleEpisodeInfoModel *infoModel = [MDSimpleEpisodeInfoModel yy_modelWithDictionary:dic];
                [vipDataList addObject:infoModel];
            }
        }
        if (success) success(vipDataList);
    }];

}

+ (void)getDramaDataForVideoComment:(NSString *)vid 
                         completion:(void (^)(NSArray<VECommentModel *> * _Nonnull, NetworkingResponse * _Nonnull))completion {
    NSDictionary *param = @{@"vid": vid};
    [NetworkingManager getWithPath:@"drama/v1/getVideoComments"
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
