//
//  TTDataManager.m
//  TTProtoTypeRoom
//
//  Created by ByteDance on 2024/9/5.
//

#import "TTDataManager.h"
#import "NetworkingManager+TTProto.h"
#import "VEPlayerKit.h"
#import <ToolKit/ToolKit.h>

static NSInteger const TTVideoPageCount = 10;

@interface TTDataManager ()

@property (nonatomic, strong) NSMutableArray *mixModels;
@property (nonatomic, strong) NSMutableArray *liveModels;

@end

@implementation TTDataManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _noMoreData = YES;
    }
    return self;
}

#pragma mark -- 混播数据
- (void)refreshData:(void (^)(void))success failure:(void (^)(NSString * _Nonnull))failure {
    [NetworkingManager dataForMixFeedData:NSMakeRange(0, TTVideoPageCount)
                                   userId:[LocalUserComponent userModel].uid
                                  success:^(NSArray<TTMixModel *> * _Nonnull mixModels) {
        VOLogI(VOTTProto, @"mixModel count: %ld", mixModels.count);
        NSMutableArray *sources = [NSMutableArray array];
        [mixModels enumerateObjectsUsingBlock:^(TTMixModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.modelType == TTModelTypeVideo) {
                [sources addObject:[TTVideoModel videoEngineVidSource:obj.videoModel]];
            }
        }];
        dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
            if (!mixModels.count) {
                self.noMoreData = YES;
            } else {
                self.noMoreData = NO;
            }
            [self.mixModels removeAllObjects];
            [self.mixModels addObjectsFromArray:mixModels];
            [VEVideoPlayerController setStrategyVideoSources:sources];
            
            if (success) {
                success();
            }
        });
    } failure:^(NSString * _Nonnull errorMessage) {
        VOLogE(VOTTProto, @"error: %@", errorMessage);
        dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
            if (failure) {
                failure(errorMessage);
            }
        });
    }];
}

- (void)looadMoreData:(void (^)(void))success failure:(void (^)(NSString * _Nonnull))failure {
    [NetworkingManager dataForMixFeedData:NSMakeRange(self.mixModels.count, TTVideoPageCount)
                                   userId:[LocalUserComponent userModel].uid
                                  success:^(NSArray<TTMixModel *> * _Nonnull mixModels) {
        VOLogI(VOTTProto, @"currentCount: %ld, add count: %ld", self.mixModels.count, mixModels.count);
        NSMutableArray *sources = [NSMutableArray array];
        [mixModels enumerateObjectsUsingBlock:^(TTMixModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.modelType == TTModelTypeVideo) {
                [sources addObject:[TTVideoModel videoEngineVidSource:obj.videoModel]];
            }
        }];
        
        dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
            if (!mixModels.count) {
                self.noMoreData = YES;
            }
            
            [self.mixModels addObjectsFromArray:mixModels];
            [VEVideoPlayerController addStrategyVideoSources:sources];
            
            if (success) {
                success();
            }
        });
    } failure:^(NSString * _Nonnull errorMessage) {
        VOLogE(VOTTProto, @"error: %@", errorMessage);
        dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
            if (failure) {
                failure(errorMessage);
            }
        });
    }];
}

#pragma mark -- 直播数据

- (void)enterLiveRoomWithLiveModel:(TTLiveModel *)liveModel success:(void (^)(void))success failure:(void (^)(NSString * _Nonnull))failure {
    VOLogI(VOTTProto, @"%@", liveModel.hostName);
    if (liveModel) {
        dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
            self.noMoreData = NO;
            [self.liveModels removeAllObjects];
            [self.liveModels addObject:liveModel];
            if (success) {
                success();
            }
        });
    } else {
        NSString *errorMessage = @"liveModel is nil";
        VOLogE(VOTTProto, @"error: %@", errorMessage);
        dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
            if (failure) {
                failure(errorMessage);
            }
        });
    }
}

- (void)looadMoreLiveRoomData:(void (^)(void))success failure:(void (^)(NSString * _Nonnull))failure {
    TTLiveModel *firstLiveModel = [self.liveModels objectAtIndex:0];
    [NetworkingManager dataForLiveFeedData:NSMakeRange(self.mixModels.count, TTVideoPageCount)
                                    userId:[LocalUserComponent userModel].uid
                                    roomId:firstLiveModel.roomId
                                   success:^(NSArray<TTLiveModel *> * _Nonnull liveModels) {
        VOLogI(VOTTProto, @"currentCount: %ld, add count: %ld", self.liveModels.count, liveModels.count);
        dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
            if (!liveModels.count) {
                self.noMoreData = YES;
            }
            [self.liveModels addObjectsFromArray:liveModels];
            if (success) {
                success();
            }
        });
    } failure:^(NSString * _Nonnull errorMessage) {
        VOLogE(VOTTProto, @"error: %@", errorMessage);
        dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
            if (failure) {
                failure(errorMessage);
            }
        });
    }];
}

#pragma mark -- getter

- (NSMutableArray *)mixModels {
    if (!_mixModels) {
        _mixModels = [NSMutableArray array];
    }
    return _mixModels;
}

- (NSMutableArray *)liveModels {
    if (!_liveModels) {
        _liveModels = [NSMutableArray array];
    }
    return _liveModels;
}

@end
