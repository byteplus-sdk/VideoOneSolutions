// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEFeedVideoViewController.h"
#import "NetworkingManager+Vod.h"
#import "UIScrollView+Refresh.h"
#import "VEFeedVideoNormalCell.h"
#import "VEVideoDetailViewController.h"
#import "VEVideoModel.h"
#import "VEVideoPlayerController.h"
#import "VEVideoStartTimeRecorder.h"
#import <MJRefresh/MJRefresh.h>
#import <Masonry/Masonry.h>
#import <ToolKit/ToolKit.h>

static NSString *VEFeedVideoNormalCellReuseID = @"VEFeedVideoNormalCellReuseID";

@interface VEFeedVideoViewController () <UITableViewDelegate, UITableViewDataSource, VEFeedVideoNormalCellDelegate, VEVideoDetailProtocol, VEVideoPlaybackDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *videoModels;
@property (nonatomic, strong) VEVideoPlayerController *playerController;
@property (nonatomic, strong) UIView *navView;
@property (nonatomic, assign, getter=isViewAppeared) BOOL viewAppeared;
@property (nonatomic, assign) BOOL isFetchingData;

@end

@implementation VEFeedVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialUI];
    [self loadDataWithMore:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.viewAppeared = YES;
    [self playVideo];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.viewAppeared = NO;
    [self stopVideos:NO];
}

- (void)tabViewDidAppear {
    [super tabViewDidAppear];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self playVideo];
}

- (void)tabViewDidDisappear {
    [super tabViewDidDisappear];
    self.playerController.startTime = 0;
    [self stopVideos:NO];
}

- (void)dealloc {
    [self.playerController stop];
    self.playerController = nil;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark----- Base

- (void)initialUI {
    self.view.backgroundColor = [UIColor colorFromHexString:@"#0C0D0F"];
    [self.view addSubview:self.navView];
    [self.navView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(44);
    }];

    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navView.mas_bottom);
        make.left.bottom.right.equalTo(self.view);
    }];
    WeakSelf;
    [self.tableView systemRefresh:^{
        StrongSelf;
        [sself loadDataWithMore:NO];
    }];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        StrongSelf;
        [sself loadDataWithMore:YES];
    }];
}

- (void)resumePlay {
    if (self.view.isHidden) {
        return;
    }
    NSString *mediaId = self.playerController.mediaSource.uniqueId;
    if (mediaId.length) {
        for (VEFeedVideoNormalCell *cell in self.tableView.visibleCells) {
            if ([cell.videoModel.videoId isEqualToString:mediaId]) {
                [cell startPlay];
                break;
            }
        }
    }
}

- (void)playSuitableVideo {
    if (!self.isViewAppeared || self.view.isHidden) {
        return;
    }
    if (self.videoModels.count) {
        VEFeedVideoNormalCell *suitableCell = nil;
        VEFeedVideoNormalCell *currentPlayingCell = nil;
        CGFloat maxOffset = 100000;
        for (VEFeedVideoNormalCell *cell in self.tableView.visibleCells) {
            CGFloat offsetY = cell.frame.origin.y - self.tableView.contentOffset.y;
            if (offsetY >= 0 && offsetY < maxOffset) {
                maxOffset = offsetY;
                suitableCell = cell;
            }
            if ([cell isPlaying] && offsetY >= 0 && offsetY + cell.frame.size.height <= self.tableView.frame.size.height) {
                currentPlayingCell = cell;
            }
        }
        if (currentPlayingCell) {
            return;
        } else {
            for (VEFeedVideoNormalCell *cell in self.tableView.visibleCells) {
                if (cell != suitableCell) {
                    [cell cellDidEndDisplay:YES];
                } else {
                    [cell startPlay];
                }
            }
        }
    }
}

- (void)playVideo {
    if (!self.isViewAppeared || self.view.isHidden) {
        return;
    }
    if (self.playerController) {
        [self.playerController play];
    } else {
        [self playSuitableVideo];
    }
}

- (void)stopVideos:(BOOL)force {
    if (!force) {
        [self.playerController pause];
        return;
    }
    for (VEFeedVideoNormalCell *cell in self.tableView.visibleCells) {
        [cell cellDidEndDisplay:force];
    }
}

- (void)playerControlDestory:(NSIndexPath *)indexPath {
    VEFeedVideoNormalCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell playerControlInterfaceDestory];
}

#pragma mark----- UITableView Delegate & DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.videoModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VEVideoModel *videoModel = [self.videoModels objectAtIndex:indexPath.row];
    VEFeedVideoNormalCell *normalCell = [tableView dequeueReusableCellWithIdentifier:VEFeedVideoNormalCellReuseID];
    normalCell.selectionStyle = UITableViewCellSelectionStyleNone;
    normalCell.separatorInset = UIEdgeInsetsMake(0, SCREEN_WIDTH, 0, 0);
    normalCell.delegate = self;
    normalCell.videoModel = videoModel;
    return normalCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    VEVideoModel *videoModel = [self.videoModels objectAtIndex:indexPath.row];
    return [VEFeedVideoNormalCell cellHeight:videoModel];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    VEVideoModel *videoModel = [self.videoModels objectAtIndex:indexPath.row];
    if ([self willPlayCurrentSource:videoModel]) {
        [self playerControlDestory:indexPath];
    } else {
        [self stopVideos:YES];
    }
    VEVideoDetailViewController *detailViewController = [[VEVideoDetailViewController alloc] initWithType:VEVideoPlayerTypeFeed];
    detailViewController.delegate = self;
    detailViewController.videoModel = videoModel;
    __weak __typeof(self) wself = self;
    detailViewController.closeCallback = ^(BOOL landscapeMode, VEVideoPlayerController *playerController) {
        wself.playerController = playerController;
        [wself resumePlay];
    };
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    /*When switching back from video detail view controller, the orientation is changing from landscapeRight to portrait.
     so we will receive this unexpect callback because the height of tableview is smaller than usual, and some cells might be unvisiable.
    */
    if (!normalScreenBehaivor()) {
        return;
    }
    if ([cell respondsToSelector:@selector(cellDidEndDisplay:)]) {
        [(VEFeedVideoNormalCell *)cell cellDidEndDisplay:YES];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate && !self.isFetchingData) {
        if (scrollView.tracking && !scrollView.dragging && !scrollView.decelerating) {
            [self playSuitableVideo];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (!self.isFetchingData) {
        [self playSuitableVideo];
    }
}

#pragma mark - VEFeedVideoNormalCellDelegate
- (id)feedVideoCellShouldPlay:(VEFeedVideoNormalCell *)cell {
    CGFloat offsetY = cell.frame.origin.y - self.tableView.contentOffset.y;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (normalScreenBehaivor()) {
        if (offsetY < 0) {
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        } else if (offsetY + cell.frame.size.height > self.tableView.frame.size.height) {
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }
    [self.playerController.view removeFromSuperview];
    [self.playerController removeFromParentViewController];
    NSString *mediaId = self.playerController.mediaSource.uniqueId;
    if (!mediaId || ![mediaId isEqualToString:cell.videoModel.videoId]) {
        [self stopVideos:YES];
        self.playerController = [[VEVideoPlayerController alloc] initWithType:VEVideoPlayerTypeFeed];
    }
    [self addChildViewController:self.playerController];
    self.playerController.delegate = self;
    return self.playerController;
}

- (void)feedVideoCellReport:(VEFeedVideoNormalCell *)cell {
}

- (void)feedVideoCellDidRotate:(VEFeedVideoNormalCell *)cell {
    VOLogD(VOVideoPlayback, @"feedVideoCellDidRotate");
    [cell playerControlInterfaceDestory];
    VEVideoDetailViewController *detailViewController = [[VEVideoDetailViewController alloc] initWithType:VEVideoPlayerTypeFeed];
    detailViewController.landscapeMode = YES;
    detailViewController.delegate = self;
    detailViewController.videoModel = cell.videoModel;
    [self.navigationController pushViewController:detailViewController animated:NO];
    __weak __typeof(self) wself = self;
    detailViewController.closeCallback = ^(BOOL landscapeMode, VEVideoPlayerController *playerController) {
        wself.playerController = playerController;
        [wself resumePlay];
    };
}

- (CFTimeInterval)feedVideoWillStartPlay:(VEVideoModel *)videoModel {
    return [[VEVideoStartTimeRecorder sharedInstance] startTimeFor:videoModel.videoId];
}

- (void)feedVideoDidEndPlay:(VEVideoModel *)videoModel playAt:(CFTimeInterval)time duration:(CFTimeInterval)duration {
    if (videoModel.videoId.length > 0 && time > 0 && time < duration - 1) {
        [[VEVideoStartTimeRecorder sharedInstance] record:videoModel.videoId startTime:time];
    }
}

#pragma mark -VEVideoPlaybackDelegate
- (void)videoPlayer:(id<VEVideoPlayback>)player playbackStateDidChange:(VEPlaybackState)state uniqueId:(NSString *)uniqueId {
    if (state == VEPlaybackStateStopped && player.currentPlaybackTime > 1 && fabs(player.duration - player.currentPlaybackTime) < 1) {
        [[VEVideoStartTimeRecorder sharedInstance] removeRecord:uniqueId];
    }
}

#pragma mark----- lazy load

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.directionalLockEnabled = YES;
        _tableView.estimatedRowHeight = 0.0;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerNib:[UINib nibWithNibName:@"VEFeedVideoNormalCell" bundle:nil] forCellReuseIdentifier:VEFeedVideoNormalCellReuseID];
    }
    return _tableView;
}

- (NSMutableArray *)videoModels {
    if (!_videoModels) {
        _videoModels = [NSMutableArray array];
    }
    return _videoModels;
}

- (UIView *)navView {
    if (!_navView) {
        _navView = [[UIView alloc] init];
        _navView.backgroundColor = [UIColor colorFromHexString:@"#0C0D0F"];

        BaseButton *button = [[BaseButton alloc] init];
        button.backgroundColor = [UIColor clearColor];
        UIImage *image = [UIImage imageNamed:@"nav_left" bundleName:@"VodPlayer"];
        button.tintColor = [UIColor whiteColor];
        [button setImage:image forState:UIControlStateNormal];
        [button addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        [_navView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(16, 16));
            make.left.mas_equalTo(15);
            make.bottom.mas_equalTo(-14);
        }];

        UILabel *label = [[UILabel alloc] init];
        label.text = LocalizedStringFromBundle(@"vod_entry_feed", @"VodPlayer");
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
        [_navView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(button);
            make.centerX.equalTo(_navView);
        }];
    }
    return _navView;
}

#pragma mark----- Data

- (void)loadDataWithMore:(BOOL)more {
    NSInteger fetchCount = 10;
    self.isFetchingData = YES;
    [NetworkingManager dataForScene:VESceneTypeFeedVideo
                              range:NSMakeRange(more ? self.videoModels.count : 0, fetchCount)
                            success:^(NSArray<VEVideoModel *> *_Nonnull videoModels) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if (!more) {
                                        [self.videoModels removeAllObjects];
                                    }
                                    if (videoModels.count) {
                                        [self.videoModels addObjectsFromArray:videoModels];
                                    }
                                    [self.tableView reloadData];
                                    if (more) {
                                        if (videoModels.count < fetchCount) {
                                            [self.tableView.mj_footer endRefreshingWithNoMoreData];
                                        } else {
                                            [self.tableView.mj_footer resetNoMoreData];
                                        }
                                    } else {
                                        [self.tableView endRefresh];
                                        [self.tableView.mj_footer resetNoMoreData];
                                    }
                                    self.isFetchingData = NO;
                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                        [self playSuitableVideo];
                                    });
                                });
                            }
                            failure:nil];
}

#pragma mark----- VEVideoDetailProtocol

- (VEVideoPlayerController *)currentPlayerController:(VEVideoModel *)videoModel {
    if ([self willPlayCurrentSource:videoModel]) {
        VEVideoPlayerController *c = self.playerController;
        self.playerController = nil;
        return c;
    } else {
        self.playerController = nil;
        return nil;
    }
}

- (BOOL)willPlayCurrentSource:(VEVideoModel *)videoModel {
    NSString *currentVid = @"";
    if (self.playerController && [self.playerController.mediaSource isKindOfClass:[TTVideoEngineVidSource class]]) {
        currentVid = [self.playerController.mediaSource performSelector:@selector(vid)];
    }
    if ([currentVid isEqualToString:videoModel.videoId]) {
        return YES;
    } else {
        return NO;
    }
}

@end
