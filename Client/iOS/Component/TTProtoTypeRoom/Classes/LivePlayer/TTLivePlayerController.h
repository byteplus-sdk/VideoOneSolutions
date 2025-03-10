// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import "TTLiveModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTLivePlayerController : NSObject

@property (nonatomic, strong, readonly) TTLiveModel *liveModel;

@property (nonatomic, assign) BOOL isActive;


- (void)playerStreamWith:(TTLiveModel *)liveModel;

- (void)bindStreamView:(UIView *)streamView;

- (void)removeStreamView;

- (void)setMute:(BOOL)mute;

- (void)stopPlayerStream;

- (void)destroy;

@end

NS_ASSUME_NONNULL_END
