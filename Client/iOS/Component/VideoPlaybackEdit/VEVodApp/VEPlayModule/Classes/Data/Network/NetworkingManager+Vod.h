//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "NetworkingManager.h"
#import "VESettingModel.h"

NS_ASSUME_NONNULL_BEGIN

@class VEVideoModel, VECommentModel;

@interface NetworkingManager (Vod)

/**
 * @brief Request feed data.
 * @param type We have three scenarios:shortVideo, feedVideo, longVideo. This parameter defines which kind of data we want to fetch.
 * @param range The range of Data, contains beginning index and length.
 * @param videoModes when success, we result an array of video models.
 * @param failure return fail message.
 */

+ (void)dataForScene:(VESceneType)type
               range:(NSRange)range
             success:(void (^__nullable)(NSArray<VEVideoModel *> *videoModels))success
             failure:(void (^__nullable)(NSString *errorMessage))failure;
@end

NS_ASSUME_NONNULL_END
