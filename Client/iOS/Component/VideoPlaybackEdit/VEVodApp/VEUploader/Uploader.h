//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class BDVideoUploadInfo;
@interface VideoUploader : NSObject

- (instancetype)initWithFilePath:(NSString *)filePath;

- (void)start:(nullable void (^)(NSInteger progress))progress
    completion:(nullable void (^)(BDVideoUploadInfo *_Nullable videoInfo, NSError *_Nullable error))completion;

- (void)close;

@end

NS_ASSUME_NONNULL_END
