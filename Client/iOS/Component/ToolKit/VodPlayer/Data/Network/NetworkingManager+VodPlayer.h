//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "NetworkingManager.h"
#import "VESettingModel.h"

NS_ASSUME_NONNULL_BEGIN

@class VECommentModel, BaseVideoModel;

@interface NetworkingManager (VodPlayer)

/**
 * @brief Request feed similar data.
 * @param type: We have three scenarios:shortVideo, feedVideo, longVideo. This parameter defines which kind of data we want to fetch.
 * @param vid original video
 * @param range: The range of Data, contains beginning index and length.
 * @param videoModes: when success, we result an array of video models.
 * @param failure: return fail message.
 */

+ (void)similarDataForScene:(VESceneType)type
                        vid:(NSString *)vid
                      range:(NSRange)range
                    success:(void (^__nullable)(NSArray<BaseVideoModel *> *_Nonnull))success
                    failure:(void (^__nullable)(NSString *_Nonnull))failure;

/**
 * @brief Request feed comments data.
 * @param vid original video
 * @param completion when success, we result an array of video models.
 */

+ (void)getVideoCommentsForVid:(NSString *)vid
                    completion:(void (^__nullable)(NSArray<VECommentModel *> *_Nonnull commentModels,
                                                   NetworkingResponse *response))completion;

@end

NS_ASSUME_NONNULL_END
