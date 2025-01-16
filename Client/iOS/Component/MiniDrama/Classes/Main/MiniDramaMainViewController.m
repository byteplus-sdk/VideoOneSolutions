//
//  MiniDramaMainViewController.m
//  MiniDrama
//
//  Created by ByteDance on 2024/11/14.
//

#import "MiniDramaMainViewController.h"
#import "MiniDramaItemButton.h"
#import "MiniDramaListViewController.h"
#import "MiniDramaVideoFeedViewController.h"
#import <ToolKit/UIColor+String.h>
#import <ToolKit/UIImage+Bundle.h>
#import <ToolKit/Localizator.h>
#import <Masonry/Masonry.h>
#import "MDVideoPlayerController+Strategy.h"
#import "DramaDisrecordManager.h"

static NSInteger HomePageIndex = 0;
static NSInteger ChannelPageIndex = 1;

@interface MiniDramaMainViewController ()

@property (nonatomic, strong) BaseButton *backButton;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) MiniDramaListViewController *homeListVC;
@property (nonatomic, strong) MiniDramaVideoFeedViewController *chanelFeedVC;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) NSArray<MiniDramaItemButton *> *itemButtonArray;

@end

@implementation MiniDramaMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorFromHexString:@"#F6F8FA"];
    [self addSubviewAndmakeConstraints];
    self.currentIndex = HomePageIndex;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.view bringSubviewToFront:self.backButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)dealloc
{
    [DramaDisrecordManager destroyUnit];
    [MDVideoPlayerController cleanCache];
    [MDVideoPlayerController clearAllEngineStrategy];
}

#pragma mark - Touch Action
- (void)scenesButtonAction:(MiniDramaItemButton *)sender {
    if (self.currentIndex == sender.index) {
        return;
    }
    self.currentIndex = sender.index;
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
    self.homeListVC.viewisVisible = currentIndex == HomePageIndex;
    self.chanelFeedVC.viewisVisible =  currentIndex == ChannelPageIndex;
    self.homeListVC.view.hidden = currentIndex != HomePageIndex;
    self.chanelFeedVC.view.hidden = currentIndex != ChannelPageIndex;
    
    [self.itemButtonArray enumerateObjectsUsingBlock:^(MiniDramaItemButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.index == currentIndex) {
            obj.status = MiniDramaMainItemStatusActive;
        } else {
            obj.status = MiniDramaMainItemStatusDeactive;
        }
    }];
}

#pragma mark - Private Action

- (void)addSubviewAndmakeConstraints {
    [self.view addSubview:self.backButton];
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(14);
        make.left.mas_equalTo(15);
        make.size.equalTo(@(CGSizeMake(16, 16)));
    }];
    
    self.bottomView = [[UIView alloc] init];
    self.bottomView.backgroundColor = [UIColor colorFromHexString:@"#07080A"];
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-48);
    }];

    NSMutableArray *list = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.itemButtonArray.count; i++) {
        MiniDramaItemButton *scenesButton = self.itemButtonArray[i];
        [self.bottomView addSubview:scenesButton];
        [list addObject:scenesButton];
    }
    [list mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:0 leadSpacing:0 tailSpacing:0];
    [list mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomView);
        make.height.mas_equalTo(48);
    }];
    
    [self addChildViewController:self.homeListVC];
    [self addChildViewController:self.chanelFeedVC];
    [self.view addSubview:self.homeListVC.view];
    [self.view addSubview:self.chanelFeedVC.view];
    [self.homeListVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.bottom.equalTo(self.bottomView.mas_top);
    }];
    [self.chanelFeedVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.bottom.equalTo(self.bottomView.mas_top);
    }];
}

- (void)close {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Getter

- (MiniDramaListViewController *)homeListVC {
    if (!_homeListVC) {
        _homeListVC = [[MiniDramaListViewController alloc] init];
    }
    return _homeListVC;
}

- (MiniDramaVideoFeedViewController *)chanelFeedVC {
    if (!_chanelFeedVC) {
        _chanelFeedVC = [[MiniDramaVideoFeedViewController alloc] init];
    }
    return _chanelFeedVC;
}

- (NSArray<MiniDramaItemButton *> *)itemButtonArray {
    if (!_itemButtonArray) {
        NSMutableArray *array = [NSMutableArray new];

        MiniDramaItemButton *HomeItem = [[MiniDramaItemButton alloc] init];
        HomeItem.index = HomePageIndex;
        [HomeItem bingImage:[UIImage imageNamed:@"vod_entry_home" bundleName:@"VodPlayer"] status:MiniDramaMainItemStatusDeactive];
        [HomeItem bingImage:[UIImage imageNamed:@"vod_entry_home_s"  bundleName:@"VodPlayer"] status:MiniDramaMainItemStatusActive];
        [HomeItem bingTitleColor:[UIColor colorFromHexString:@"#EBEDF0"] status:MiniDramaMainItemStatusActive];
        [HomeItem setTitle:LocalizedStringFromBundle(@"mini_drama_home", @"MiniDrama") forState:UIControlStateNormal];
        [HomeItem addTarget:self action:@selector(scenesButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [array addObject:HomeItem];

        MiniDramaItemButton *ChannelItem = [[MiniDramaItemButton alloc] init];
        ChannelItem.index = ChannelPageIndex;
        [ChannelItem bingImage:[UIImage imageNamed:@"vod_entry_channel" bundleName:@"VodPlayer"] status:MiniDramaMainItemStatusDeactive];
        [ChannelItem bingImage:[UIImage imageNamed:@"vod_entry_channel_s" bundleName:@"VodPlayer"] status:MiniDramaMainItemStatusActive];
        [ChannelItem setTitle:LocalizedStringFromBundle(@"mini_drama_Channel", @"MiniDrama") forState:UIControlStateNormal];
        [ChannelItem bingTitleColor:[UIColor colorFromHexString:@"#EBEDF0"] status:MiniDramaMainItemStatusActive];
        [ChannelItem addTarget:self action:@selector(scenesButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [array addObject:ChannelItem];

        _itemButtonArray = array.copy;
    }
    return _itemButtonArray;
}

- (BaseButton *)backButton {
    if (!_backButton) {
        _backButton = [BaseButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage imageNamed:@"nav_left" bundleName:@"VodPlayer"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

@end
