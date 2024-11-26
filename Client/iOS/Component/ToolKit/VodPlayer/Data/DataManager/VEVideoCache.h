// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TTVideoEngineModel;

@interface VEVideoCache : NSObject

+ (instancetype)shared;

- (nullable TTVideoEngineModel *)videoForKey:(NSString *)key;

- (void)setVideo:(nullable TTVideoEngineModel *)object forKey:(NSString *)key;

- (void)removeVideoForKey:(NSString *)key;

- (void)removeAllVideos;

@end

NS_ASSUME_NONNULL_END
