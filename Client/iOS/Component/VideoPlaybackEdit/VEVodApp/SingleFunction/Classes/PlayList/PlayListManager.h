// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
NS_ASSUME_NONNULL_BEGIN

@class VEVideoModel, VEEventMessageBus, VEEventPoster, PlayListView, PlayListFloatView;

@protocol PlayListManagerDelegate <NSObject>

- (void)updatePlayVideo:(VEVideoModel *)videoModel;

@end

@interface PlayListManager : NSObject

@property (nonatomic, strong) PlayListView *playListView;

@property (nonatomic, strong) PlayListFloatView *playListFloatView;

@property (nonatomic, strong) NSArray<VEVideoModel *> *playList;

@property (nonatomic, assign) NSInteger currentPlayViewIndex;

@property (nonatomic, weak) VEEventMessageBus *eventMessageBus;

@property (nonatomic, weak) VEEventPoster *eventPoster;

@property (nonatomic, weak) id<PlayListManagerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
