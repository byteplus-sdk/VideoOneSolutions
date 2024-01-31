// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

#import "VEVideoDetailViewController.h"
#import "NetworkingManager+Vod.h"
#import "VEBaseVideoDetailViewController+Private.h"
#import "VEInterfaceVideoDetailSceneConf.h"
#import "VEVideoDetailTableView.h"

@interface VEVideoDetailViewController () <VEVideoDetailTableViewDelegate>

@property (nonatomic, strong) VEVideoDetailTableView *tableView;
@property (nonatomic, strong) NSMutableArray<VEVideoModel *> *recommendedListData;

@end

@implementation VEVideoDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.landscapeMode) {
        [self loadDataWithRecommended:YES];
    }
}

- (void)layoutUI {
    [super layoutUI];
    if (!self.landscapeMode) {
        [self.view addSubview:self.tableView];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.videoInfoView.mas_bottom).offset(16);
            make.leading.trailing.equalTo(self.view);
            make.bottom.equalTo(self.view).priority(MASLayoutPriorityDefaultLow);
        }];
    }
}

- (void)reloadTableView:(NSArray<VEVideoModel *> *)listData {
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(VEVideoModel *videoModel, NSDictionary *bindings) {
        return ![videoModel.videoId isEqualToString:self.videoModel.videoId];
    }];
    NSArray *filteredArray = [listData filteredArrayUsingPredicate:predicate];
    self.tableView.hidden = filteredArray.count > 0 ? NO : YES;
    self.tableView.dataLists = filteredArray;
}

#pragma mark - Getter

- (VEInterfaceBaseVideoDetailSceneConf *)interfaceScene {
    return [VEInterfaceVideoDetailSceneConf new];
}

- (VEVideoDetailTableView *)tableView {
    if (!_tableView) {
        _tableView = [[VEVideoDetailTableView alloc] init];
        _tableView.delegate = self;
        _tableView.hidden = YES;
    }
    return _tableView;
}

- (NSMutableArray<VEVideoModel *> *)recommendedListData {
    if (!_recommendedListData) {
        _recommendedListData = [[NSMutableArray alloc] init];
    }
    return _recommendedListData;
}

#pragma mark----- Network request Method

- (void)loadDataWithRecommended:(BOOL)isRefresh {
    NSInteger sceneType = (self.videoPlayerType == VEVideoPlayerTypeFeed) ? VESceneTypeFeedVideo : VESceneTypeLongVideo;
    NSInteger limit = 10;
    __weak __typeof(self) wself = self;
    [NetworkingManager similarDataForScene:sceneType
                                       vid:self.videoModel.videoId
                                     range:NSMakeRange(self.recommendedListData.count, limit)
                                   success:^(NSArray<VEVideoModel *> *_Nonnull videoModels) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           if (isRefresh) {
                                               [wself.recommendedListData removeAllObjects];
                                           }
                                           [wself.recommendedListData addObjectsFromArray:videoModels];
                                           [wself reloadTableView:[wself.recommendedListData copy]];
                                           if (videoModels.count < limit) {
                                               [wself.tableView endRefreshingWithNoMoreData];
                                           } else {
                                               [wself.tableView endRefresh];
                                           }
                                       });
                                   }
                                   failure:nil];
}

#pragma mark----- VEVideoDetailTableViewDelegate

- (void)tableView:(VEVideoDetailTableView *)tableView didSelectRowAtModel:(VEVideoModel *)model {
    self.closeCallback = nil;
    VEVideoDetailViewController *detailViewController = [[VEVideoDetailViewController alloc] initWithType:self.videoPlayerType];
    detailViewController.videoModel = model;
    UINavigationController *navigationController = self.navigationController;
    NSMutableArray *viewControllers = navigationController.viewControllers.mutableCopy;
    [viewControllers removeObject:self];
    [navigationController setViewControllers:viewControllers animated:NO];
    [navigationController pushViewController:detailViewController animated:NO];
}

- (void)tableView:(VEVideoDetailTableView *)tableView loadDataWithMore:(BOOL)result {
    [self loadDataWithRecommended:NO];
}

@end
