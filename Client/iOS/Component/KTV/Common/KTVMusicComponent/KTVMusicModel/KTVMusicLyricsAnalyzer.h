// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import "KTVMusicLyricConfig.h"
@class KTVMusicLyricModel;

NS_ASSUME_NONNULL_BEGIN

@interface KTVMusicLyricsAnalyzer : NSObject

+ (KTVMusicLyricModel *)analyzeLrcByPath:(NSString *)path
                               lrcFormat:(KTVMusicLrcFormat)lrcFormat;
@end

NS_ASSUME_NONNULL_END
