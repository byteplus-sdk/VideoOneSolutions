// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>
#import "TTLiveModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTDataManager : NSObject

@property (nonatomic, assign, getter=isNoMoreData) BOOL noMoreData;

@property (nonatomic, strong, readonly) NSMutableArray *videoSources;

@property (nonatomic, strong, readonly) NSMutableArray *mixModels;

@property (nonatomic, strong, readonly) NSMutableArray *liveModels;

- (void)refreshData:(void (^__nullable)(void))success
            failure:(void (^__nullable)(NSString *errorMessage))failure;

- (void)looadMoreData:(void (^__nullable)(void))success
              failure:(void (^__nullable)(NSString *errorMessage))failure;

- (void)enterLiveRoomWithLiveModel:(TTLiveModel *)liveModel success:(void (^__nullable)(void))success
                           failure:(void (^__nullable)(NSString *errorMessage))failure;

- (void)looadMoreLiveRoomData:(void (^__nullable)(void))success
              failure:(void (^__nullable)(NSString *errorMessage))failure;

@end
NS_ASSUME_NONNULL_END
