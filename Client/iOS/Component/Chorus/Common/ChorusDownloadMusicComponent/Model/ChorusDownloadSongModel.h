// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
// Get song lyrics download address model
@interface ChorusDownloadSongModel : NSObject

@property (nonatomic, copy) NSString *lrcPath;
@property (nonatomic, copy) NSString *musicPath;
@property (nonatomic, strong) ChorusSongModel *songModel;

@end

NS_ASSUME_NONNULL_END
