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


/**
 * @brief Request feed data.
 * @param type: We have three scenarios:shortVideo, feedVideo, longVideo. This parameter defines which kind of data we want to fetch.
 * @param range: The range of Data, contains beginning index and length.
 * @param videoModes: when success, we result an array of video models.
 * @param failure: return fail message.
 */

+ (void)dataForScene:(VESceneType)type
               range:(NSRange)range
             success:(void(^__nullable)(NSArray<VEVideoModel *> *videoModels))success
             failure:(void(^__nullable)(NSString *errorMessage))failure;


- (instancetype)initWithScene:(VESceneType)type;

/**
 * @brief Request feed data with solid scene type which has been setted when initialize this class. Range is default to (0, VEVideoPageCount)
 * @param videoModes: when success, we result an array of video models.
 * @param failure: return fail message.
 */

- (void)refreshData:(void(^__nullable)(void))success
            failure:(void(^__nullable)(NSString *errorMessage))failure;

/**
 * @brief Request feed data with solid scene type which has been setted when initialize this class. Range is default to (current counts, VEVideoPageCount)
 * @param videoModes: when success, we result an array of video models.
 * @param failure: return fail message.
 */


- (void)looadMoreData:(void(^__nullable)(void))success
              failure:(void(^__nullable)(NSString *errorMessage))failure;

@end

NS_ASSUME_NONNULL_END
