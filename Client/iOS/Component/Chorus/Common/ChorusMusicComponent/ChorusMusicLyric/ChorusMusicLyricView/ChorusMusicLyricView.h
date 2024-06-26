// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>
#import "ChorusMusicLyricModel.h"
#import "ChorusMusicLyricConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChorusMusicLyricView : UITableView

@property (nonatomic, copy) void (^finishLineBlock)(ChorusMusicLyricLineModel *lineModel);

- (void)loadLrcByPath:(NSString *)path
               config:(ChorusMusicLyricConfig *)config
                error:(NSError * _Nullable *)error;

- (void)playAtTime:(NSTimeInterval)time;

- (void)reset;

@end

NS_ASSUME_NONNULL_END
