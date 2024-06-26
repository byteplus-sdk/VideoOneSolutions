// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "ChorusMusicLyricConfig.h"
#import "ChorusMusicLyricModel.h"
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface ChorusMusicLyricCell : UITableViewCell

@property (nonatomic, strong) ChorusMusicLyricLineModel *lineModel;

@property (nonatomic, strong) ChorusMusicLyricConfig *config;

- (void)setCurrentRow:(NSInteger)currentRow playingRow:(NSInteger)playingRow;

- (void)playProgress:(NSInteger)time;

+ (CGFloat)getCellHeight:(ChorusMusicLyricLineModel *)lineModel
                  config:(ChorusMusicLyricConfig *)config
                maxWidth:(CGFloat)maxWidth;

@end

NS_ASSUME_NONNULL_END
