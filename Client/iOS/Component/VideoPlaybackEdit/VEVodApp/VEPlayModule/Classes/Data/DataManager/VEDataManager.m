// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEDataManager.h"
#import "NetworkingManager+Vod.h"
#import "VEVideoModel.h"
#import "VEVideoPlayerController+Strategy.h"

static NSInteger const VEVideoPageCount = 10;

@interface VEDataManager ()

@property (nonatomic, strong) NSMutableArray *videoModels;

@end

@implementation VEDataManager

- (instancetype)initWithScene:(VESceneType)type {
    self = [super init];
    if (self) {
        _sceneType = type;
        _noMoreData = YES;
    }
    return self;
}

#pragma mark - ShortVideo

- (void)refreshData:(void (^)(void))success failure:(void (^)(NSString *_Nonnull))failure {
    [NetworkingManager dataForScene:self.sceneType
        range:NSMakeRange(0, VEVideoPageCount)
        success:^(NSArray<VEVideoModel *> *_Nonnull videoModels) {
            // trans video model to strategy source
            NSMutableArray *sources = nil;
            if (self.sceneType == VESceneTypeShortVideo) {
                sources = [NSMutableArray array];
                [videoModels enumerateObjectsUsingBlock:^(VEVideoModel *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
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
        } failure:^(NSString *_Nonnull errorMessage) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failure) {
                    failure(errorMessage);
                }
            });
        }];
}

- (void)looadMoreData:(void (^)(void))success failure:(void (^)(NSString *_Nonnull))failure {
    [NetworkingManager dataForScene:self.sceneType
        range:NSMakeRange(self.videoModels.count, VEVideoPageCount)
        success:^(NSArray<VEVideoModel *> *_Nonnull videoModels) {
            // trans video model to strategy source
            NSMutableArray *sources = nil;
            if (self.sceneType == VESceneTypeShortVideo) {
                sources = [NSMutableArray array];
                [videoModels enumerateObjectsUsingBlock:^(VEVideoModel *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
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
        } failure:^(NSString *_Nonnull errorMessage) {
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
