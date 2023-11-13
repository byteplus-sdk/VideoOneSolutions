//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LivePullRenderView.h"
#import "LiveRoomInfoModel.h"
#import <Foundation/Foundation.h>
@class LivePullStreamComponent;

NS_ASSUME_NONNULL_BEGIN

@protocol LivePullStreamComponentDelegate <NSObject>

- (void)pullStreamComponent:(LivePullStreamComponent *)pullStreamComponent
            didChangeStatus:(PullRenderStatus)status;

@end

@interface LivePullStreamComponent : NSObject

@property (nonatomic, assign, readonly) BOOL isConnect;

@property (nonatomic, weak) id<LivePullStreamComponentDelegate> delegate;

- (instancetype)initWithSuperView:(UIView *)superView;

- (void)open:(LiveRoomInfoModel *)roomModel;

- (void)updateHostMic:(BOOL)mic camera:(BOOL)camera;

- (void)updateWithStatus:(PullRenderStatus)status;

- (void)close;

@end

NS_ASSUME_NONNULL_END
