// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "NetworkingManager.h"

NS_ASSUME_NONNULL_BEGIN

@class VEVideoModel;

typedef NS_ENUM(NSUInteger, PlayListMode) {
    PlayListModeUnknown,
    PlayListModeLinear,
    PlayListModeLoop
};

@interface NetworkingManager (PlayList)

+ (void)getPlayListDetail:(void (^)(NSArray<VEVideoModel *> *playList, PlayListMode playMode))success
                  failure:(void (^)(NSString *errorMessage))failure;

@end

NS_ASSUME_NONNULL_END
