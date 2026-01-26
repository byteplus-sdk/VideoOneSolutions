// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEShortVideoDemoViewController.h"
#import "VEPageViewController.h"
#import "VEPlayerKit.h"
#import "VESettingManager.h"
#import "VEShortVideoCellController.h"
#import "VEVideoModel.h"
#import <Masonry/Masonry.h>
#import <ToolKit/ToolKit.h>

static NSString *VEShortVideoCellReuseIDDemo = @"VEShortVideoCellReuseIDDemo";

@interface VEShortVideoDemoViewController () <VEPageDataSource, VEPageDelegate, VEShortVideoCellControllerDelegate>

@property (nonatomic, strong) VEPageViewController *pageContainer;

@end

@implementation VEShortVideoDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialUI];
    [self startVideoStrategy];
}

- (void)dealloc {
    [VEVideoPlayerController clearAllEngineStrategy];
    [VEVideoPlayerController cancelPreloadVideoSources];
}

#pragma mark---- ATPageViewControllerDataSource & Delegate
- (NSInteger)numberOfItemInPageViewController:(VEPageViewController *)pageViewController {
    return self.videoModels.count;
}

// designed like the cellForRow Method of UITableView, you should return the cell corresponding to the exact index
- (__kindof UIViewController<VEPageItem> *)pageViewController:(VEPageViewController *)pageViewController pageForItemAtIndex:(NSUInteger)index {
    VEShortVideoCellController *cell = [pageViewController dequeueItemForReuseIdentifier:VEShortVideoCellReuseIDDemo];
    if (!cell) {
        cell = [VEShortVideoCellController new];
        cell.reuseIdentifier = VEShortVideoCellReuseIDDemo;
    }
    cell.delegate = self;
    cell.videoModel = [self.videoModels objectAtIndex:index];
    return cell;
}

- (BOOL)shouldScrollVertically:(VEPageViewController *)pageViewController {
    return YES;
}

- (void)pageViewController:(VEPageViewController *)pageViewController
    didScrollChangeDirection:(VEPageItemMoveDirection)direction
              offsetProgress:(CGFloat)progress {
}

- (void)pageViewControllerWillBeginDragging:(VEPageViewController *)pageViewController {
    [VEVideoPlayerController cancelPreloadVideoSources];
}

- (void)pageViewController:(VEPageViewController *)pageViewController didDisplayItem:(id<VEPageItem>)viewController atIndex:(NSUInteger)index {
    if (!self.videoModels.count || index == self.videoModels.count - 1) {
        return;
    }
}

#pragma mark----- Lazy load

- (VEPageViewController *)pageContainer {
    if (!_pageContainer) {
        _pageContainer = [VEPageViewController new];
        _pageContainer.dataSource = self;
        _pageContainer.delegate = self;
        _pageContainer.viewAppeared = YES;
        _pageContainer.scrollView.directionalLockEnabled = YES;
        _pageContainer.scrollView.scrollsToTop = NO;
    }
    return _pageContainer;
}

- (void)startVideoStrategy {
    VESettingModel *preRender = [[VESettingManager universalManager] settingForKey:VESettingKeyShortVideoPreRenderStrategy];
    if (preRender.open) {
        [VEVideoPlayerController enableEngineStrategy:TTVideoEngineStrategyTypePreRender scene:TTVEngineStrategySceneSmallVideo];
    }
    VESettingModel *preload = [[VESettingManager universalManager] settingForKey:VESettingKeyShortVideoPreloadStrategy];
    if (preload.open) {
        [VEVideoPlayerController enableEngineStrategy:TTVideoEngineStrategyTypePreload scene:TTVEngineStrategySceneSmallVideo];
    }
}

#pragma mark----- UI
- (void)initialUI {
    self.view.backgroundColor = [UIColor whiteColor];
    [self addChildViewController:self.pageContainer];
    [self.view addSubview:self.pageContainer.view];
    [self.pageContainer.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    BaseButton *backButton = [BaseButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"nav_left" bundleName:@"VodPlayer"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(14);
        make.left.mas_equalTo(15);
        make.size.equalTo(@(CGSizeMake(16, 16)));
    }];
}

- (void)close {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark----- VEShortVideoCellControllerDelegate

- (void)shortVideoController:(VEShortVideoCellController *)controller shouldLockVerticalScroll:(BOOL)shouldLock {
    self.pageContainer.scrollView.scrollEnabled = !shouldLock;
}

@end
