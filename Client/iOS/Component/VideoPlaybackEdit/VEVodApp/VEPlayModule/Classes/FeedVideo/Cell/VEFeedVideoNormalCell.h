// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
@import UIKit;
@class VEVideoModel;
@class VEFeedVideoNormalCell;

@protocol VEFeedVideoNormalCellDelegate <NSObject>

- (id)feedVideoCellShouldPlay:(VEFeedVideoNormalCell *)cell;

- (CFTimeInterval)feedVideoWillStartPlay:(VEVideoModel *)videoModel;
- (void)feedVideoDidEndPlay:(VEVideoModel *)videoModel playAt:(CFTimeInterval)time duration:(CFTimeInterval)duration;

- (void)feedVideoCellReport:(VEFeedVideoNormalCell *)cell;

- (void)feedVideoCellDidRotate:(VEFeedVideoNormalCell *)cell;

@end

@interface VEFeedVideoNormalCell : UITableViewCell

@property (nonatomic, strong) VEVideoModel *videoModel;

@property (nonatomic, weak) id<VEFeedVideoNormalCellDelegate> delegate;

- (void)cellDidEndDisplay:(BOOL)force;

- (void)playerControlInterfaceDestory;

+ (CGFloat)cellHeight:(VEVideoModel *)videoModel;

- (void)startPlay;

- (BOOL)isPlaying;

@end
