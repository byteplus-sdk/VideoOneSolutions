// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import "ChorusMusicLyricConfig.h"
@class ChorusMusicLyricModel;

NS_ASSUME_NONNULL_BEGIN

@interface ChorusMusicLyricsAnalyzer : NSObject

+ (ChorusMusicLyricModel *)analyzeLrcByPath:(NSString *)path
                               lrcFormat:(ChorusMusicLrcFormat)lrcFormat;
@end

NS_ASSUME_NONNULL_END
