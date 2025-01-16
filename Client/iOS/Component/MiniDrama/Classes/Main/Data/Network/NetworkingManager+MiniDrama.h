//
//  NetworkingManager+MiniDrama.h
//  MiniDrama
//
//  Created by ByteDance on 2024/11/15.
//

#import <Foundation/Foundation.h>
#import "NetworkingManager.h"
#import "MDHomePageData.h"
#import "MDDramaFeedInfo.h"
#import "MDSimpleEpisodeInfoModel.h"
#import "MDDramaEpisodeInfoModel.h"
#import "VECommentModel.h"
#import "NetworkingResponse.h"

NS_ASSUME_NONNULL_BEGIN

@interface NetworkingManager (MiniDrama)

+ (void)getDramaDataForHomePageData:(void (^__nullable)(MDHomePageData *))success
                            failure:(void (^__nullable)(NSString *_Nonnull))failure;

+ (void)getDramaDataForChannelPage:(NSRange)range
                           success:(void (^)(NSArray<MDDramaFeedInfo *> *list))success
                           failure:(void (^__nullable)(NSString *_Nonnull))failure;

+ (void)getDramaDataForDetailPage:(NSString *)dramaId
                           success:(void (^)(NSArray<MDDramaEpisodeInfoModel *> *list))success
                           failure:(void (^__nullable)(NSString *_Nonnull))failure;

+ (void)getDramaDataForPaymentEpisodeInfo:(NSString *)userId
                       dramaId:(NSString *)dramaId
                       vidList:(NSArray<NSString *> *)videoIdList
                       success:(void (^)(NSArray<MDSimpleEpisodeInfoModel *> *))success
                       failure:(void (^__nullable)(NSString *_Nonnull))failure;

+ (void)getDramaDataForVideoComment:(NSString *)vid completion:(void (^__nullable)(NSArray<VECommentModel *> *_Nonnull commentModels,
                                                                                   NetworkingResponse *response))completion;

@end

NS_ASSUME_NONNULL_END
