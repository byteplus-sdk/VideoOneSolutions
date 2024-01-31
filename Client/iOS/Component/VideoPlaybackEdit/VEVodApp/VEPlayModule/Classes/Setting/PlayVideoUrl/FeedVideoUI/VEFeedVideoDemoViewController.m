// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEFeedVideoDemoViewController.h"
#import "VEFeedVideoNormalCell.h"
#import "VEVideoDetailViewController.h"
#import "VEVideoModel.h"
#import "VEVideoPlayerController.h"
#import <Masonry/Masonry.h>
#import <ToolKit/ToolKit.h>

static NSString *VEFeedVideoNormalCellReuseIDdemo = @"VEFeedVideoNormalCellReuseIDdemo";

@interface VEFeedVideoDemoViewController () <UITableViewDelegate, UITableViewDataSource, VEFeedVideoNormalCellDelegate, VEVideoDetailProtocol>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) VEVideoPlayerController *playerController;
@property (nonatomic, strong) UIView *navView;

@end

@implementation VEFeedVideoDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)dealloc {
    [self.playerController stop];
    self.playerController = nil;
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
}

#pragma mark----- UITableView Delegate & DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.videoModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VEVideoModel *videoModel = [self.videoModels objectAtIndex:indexPath.row];
    VEFeedVideoNormalCell *normalCell = [tableView dequeueReusableCellWithIdentifier:VEFeedVideoNormalCellReuseIDdemo];
    normalCell.selectionStyle = UITableViewCellSelectionStyleNone;
    normalCell.separatorInset = UIEdgeInsetsMake(0, SCREEN_WIDTH, 0, 0);
    normalCell.delegate = self;
    normalCell.videoModel = videoModel;
    return normalCell;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(cellDidEndDisplay:)]) {
        [(VEFeedVideoNormalCell *)cell cellDidEndDisplay:YES];
    }
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
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (id)feedVideoCellShouldPlay:(VEFeedVideoNormalCell *)cell {
    if ([self willPlayCurrentSource:cell.videoModel]) {
    } else {
        [self stopVideos:YES];
        self.playerController = [[VEVideoPlayerController alloc] initWithType:VEVideoPlayerTypeFeed];
    }
    return self.playerController;
}

- (void)feedVideoCellReport:(VEFeedVideoNormalCell *)cell {
}

- (void)feedVideoCellDidRotate:(VEFeedVideoNormalCell *)cell {
}

- (void)feedVideoDidEndPlay:(VEVideoModel *)videoModel playAt:(CFTimeInterval)time duration:(CFTimeInterval)duration {
}

- (CFTimeInterval)feedVideoWillStartPlay:(VEVideoModel *)videoModel {
    return 0;
}

- (void)stopVideos:(BOOL)force {
    for (VEFeedVideoNormalCell *cell in self.tableView.visibleCells) {
        [cell cellDidEndDisplay:force];
    }
}

- (void)playerControlDestory:(NSIndexPath *)indexPath {
    VEFeedVideoNormalCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell playerControlInterfaceDestory];
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
        [_tableView registerNib:[UINib nibWithNibName:@"VEFeedVideoNormalCell" bundle:nil] forCellReuseIdentifier:VEFeedVideoNormalCellReuseIDdemo];
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
        UIImage *image = [UIImage imageNamed:@"nav_left"];
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
        label.text = LocalizedStringFromBundle(@"vod_entry_feed", @"VEVodApp");
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

#pragma mark----- VEVideoDetailProtocol

- (VEVideoPlayerController *)currentPlayerController:(VEVideoModel *)videoModel {
    if ([self willPlayCurrentSource:videoModel]) {
        VEVideoPlayerController *c = self.playerController;
        self.playerController = nil;
        return c;
    } else {
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
