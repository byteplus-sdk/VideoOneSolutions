// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import "MDVideoPlaybackDefine.h"

NS_ASSUME_NONNULL_BEGIN


@interface MDPlayFinishStatus : NSObject

@property (nonatomic, assign) MDVideoPlayFinishStatusType finishState;
@property (nonatomic, strong) NSError * _Nullable error;

- (BOOL)playerFinishedSuccess;

@end

NS_ASSUME_NONNULL_END
