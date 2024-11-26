//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "NetworkingManager.h"
#import "VESettingModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, VESingleFunctionType) {
    VESingleFunctionTypePlayback,
    VESingleFunctionTypePlaylist,
    VESingleFunctionTypeSmartSubtitles,
    VESingleFunctionTypePreventRecording,
};

@class VEVideoModel;

@interface NetworkingManager (SingleFunction)

+ (void)dataForScene:(VESceneType)sceneType
        functionType:(VESingleFunctionType)functionType
             success:(void (^__nullable)(VEVideoModel *videoModel))success
             failure:(void (^__nullable)(NSString *errorMessage))failure;

@end

NS_ASSUME_NONNULL_END
