// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VESettingModel.h"

NS_ASSUME_NONNULL_BEGIN

@import Foundation;
@class VEVideoModel;

@interface VEDataManager : NSObject

@property (nonatomic, assign, readonly) VESceneType sceneType;

@property (nonatomic, assign, getter=isNoMoreData) BOOL noMoreData;

@property (nonatomic, strong, readonly) NSMutableArray *videoModels;

- (instancetype)initWithScene:(VESceneType)type;

#pragma mark - ShortVideo

/**
 * @brief Request feed data with solid scene type which has been setted when initialize this class. Range is default to (0, VEVideoPageCount)
 * @param success when success, we result an array of video models.
 * @param failure return fail message.
 */

- (void)refreshData:(void (^__nullable)(void))success
            failure:(void (^__nullable)(NSString *errorMessage))failure;

/**
 * @brief Request feed data with solid scene type which has been setted when initialize this class. Range is default to (current counts, VEVideoPageCount)
 * @param success when success, we result an array of video models.
 * @param failure return fail message.
 */


- (void)looadMoreData:(void (^__nullable)(void))success
              failure:(void (^__nullable)(NSString *errorMessage))failure;

@end

NS_ASSUME_NONNULL_END
