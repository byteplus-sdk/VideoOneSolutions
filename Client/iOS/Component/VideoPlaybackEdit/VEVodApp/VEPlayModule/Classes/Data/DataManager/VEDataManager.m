// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEDataManager.h"
#import "VENetworkHelper.h"
#import "VEVideoModel.h"
#import "VEVideoPlayerController+Strategy.h"
#import <AppConfig/BuildConfig.h>

static NSInteger const VEVideoPageCount = 10;

@interface VEDataManager ()

@property (nonatomic, strong) NSMutableArray *videoModels;

@end

@implementation VEDataManager

+ (void)dataForScene:(VESceneType)type
               range:(NSRange)range
             success:(void (^)(NSArray<VEVideoModel *> * _Nonnull))success
             failure:(void (^)(NSString * _Nonnull))failure  {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *param;
        if (range.length) {
            param = @{@"videoType" : @(type), @"offset" : @(range.location), @"pageSize" : @(range.length)};
        } else {
            param = @{@"videoType" : @(type)};
        }
        NSString *urlString = [NSString stringWithFormat:@"%@/%@", ServerUrl, @"vod/v1/getFeedStreamWithPlayAuthToken"];
        [VENetworkHelper requestDataWithUrl:urlString httpMethod:@"POST" parameters:param success:^(id _Nonnull responseObject) {
            NSMutableArray *medias = [NSMutableArray array];
            if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                id results = [responseObject objectForKey:@"result"];
                if (!results) {
                    results = [responseObject objectForKey:@"response"];
                }
                if ([results isKindOfClass:[NSArray class]]) {
                    NSArray *ary = (NSArray *)results;
                    for (NSDictionary *dic in ary) {
                        VEVideoModel *videoModel = [VEVideoModel yy_modelWithDictionary:dic];
                        [medias addObject:videoModel];
                    }
                }
            }
            if (success) success(medias);
        } failure:failure];
    });
}

- (instancetype)initWithScene:(VESceneType)type {
    self = [super init];
    if (self) {
        _sceneType = type;
        _noMoreData = YES;
    }
    return self;
}

- (void)refreshData:(void (^)(void))success failure:(void (^)(NSString * _Nonnull))failure {
    [VEDataManager dataForScene:self.sceneType
                          range:NSMakeRange(0, VEVideoPageCount)
                        success:^(NSArray<VEVideoModel *> * _Nonnull videoModels) {
        // trans video model to strategy source
        NSMutableArray *sources = nil;
        if (self.sceneType == VESceneTypeShortVideo) {
            sources = [NSMutableArray array];
            [videoModels enumerateObjectsUsingBlock:^(VEVideoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [sources addObject:[VEVideoModel videoEngineVidSource:obj]];
            }];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!videoModels.count) {
                self.noMoreData = YES;
            } else {
                self.noMoreData = NO;
            }
            [self.videoModels removeAllObjects];
            [self.videoModels addObjectsFromArray:videoModels];
            if (sources) {
                [VEVideoPlayerController setStrategyVideoSources:sources];
            }
            if (success) {
                success();
            }
        });
    } failure:^(NSString * _Nonnull errorMessage) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failure) {
                failure(errorMessage);
            }
        });
    }];
}

- (void)looadMoreData:(void (^)(void))success failure:(void (^)(NSString * _Nonnull))failure  {
    [VEDataManager dataForScene:self.sceneType
                          range:NSMakeRange(self.videoModels.count, VEVideoPageCount)
                        success:^(NSArray<VEVideoModel *> * _Nonnull videoModels) {
        // trans video model to strategy source
        NSMutableArray *sources = nil;
        if (self.sceneType == VESceneTypeShortVideo) {
            sources = [NSMutableArray array];
            [videoModels enumerateObjectsUsingBlock:^(VEVideoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [sources addObject:[VEVideoModel videoEngineVidSource:obj]];
            }];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!videoModels.count) {
                self.noMoreData = YES;
            }
            [self.videoModels addObjectsFromArray:videoModels];
            if (sources) {
                [VEVideoPlayerController addStrategyVideoSources:sources];
            }
            if (success) {
                success();
            }
        });
    } failure:^(NSString * _Nonnull errorMessage) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failure) {
                failure(errorMessage);
            }
        });
    }];
}

- (NSMutableArray *)videoModels {
    if (!_videoModels) {
        _videoModels = [NSMutableArray array];
    }
    return _videoModels;
}

@end

