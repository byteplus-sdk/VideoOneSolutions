// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEPlayProtocol.h"
#import <Foundation/Foundation.h>

@class PIPManager;

NS_ASSUME_NONNULL_BEGIN

@protocol PIPManagerDataSourceDelegate <NSObject>

- (NSTimeInterval)currentVideoPlaybackProgress:(PIPManager *)manager;

@end

@interface PIPManager : NSObject

+ (PIPManager *_Nullable)sharePIPManager;

@property (nonatomic, weak) id<PIPManagerDataSourceDelegate> dataSource;

@property (nonatomic, assign) BOOL enablePictureInPicture;

@property (nonatomic, assign) PIPManagerStatus status;

@property (nonatomic, copy, nullable) void (^restoreCompletionBlock)(CGFloat progress, BOOL isPlaying);

@property (nonatomic, copy, nullable) void (^closeCompletionBlock)(CGFloat progress);

@property (nonatomic, copy, nullable) void (^startCompletionBlock)(void);

- (void)prepare:(UIView *)contentView
       videoURL:(NSString *)videoURL
       interval:(NSTimeInterval)interval
     completion:(void (^)(PIPManagerStatus status))block;

- (void)cancelPrepare;

- (void)updatePlaybackStatus:(BOOL)isPlaying;

@end

NS_ASSUME_NONNULL_END
