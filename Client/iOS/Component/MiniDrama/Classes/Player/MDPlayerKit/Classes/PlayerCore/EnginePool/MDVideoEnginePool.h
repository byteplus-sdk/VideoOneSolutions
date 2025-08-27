// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import <TTSDKFramework/TTSDKFramework.h>


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MDCreateEngineFrom) {
    MDCreateEngineFrom_Init,
    MDCreateEngineFrom_Cache,
    MDCreateEngineFrom_Prerender,
};

typedef void(^MDEnginePoolBlock)(TTVideoEngine * _Nullable engine, MDCreateEngineFrom engineFrom);

@interface MDVideoEnginePool : NSObject

+ (MDVideoEnginePool *)shareInstance;

- (void)createVideoEngine:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource needPrerenderEngine:(BOOL)needPrerender block:(MDEnginePoolBlock)block;

- (void)removeVideoEngine:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource;
@end

NS_ASSUME_NONNULL_END
