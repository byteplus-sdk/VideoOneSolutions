// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MiniDramaWithInStreamAdsMainViewController.h"
#import "MiniDramaListViewController.h"
#import "MiniDramaVideoFeedViewController.h"
#import <ToolKit/UIColor+String.h>
#import <ToolKit/UIImage+Bundle.h>
#import <ToolKit/Localizator.h>
#import <Masonry/Masonry.h>
#import "MDVideoPlayerController+Strategy.h"
#import "DramaDisrecordManager.h"
#import "MDAdSettingViewController.h"
#import "MDAdGlobalSettings.h"

static NSInteger const HomePageIndex = 0;
static NSInteger const SettingPageIndex = 1;

@interface MiniDramaWithInStreamAdsMainViewController ()

@property (nonatomic, strong) BaseButton *backButton;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) MiniDramaListViewController *homeListVC;
@property (nonatomic, strong) MDAdSettingViewController *settingVC;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) NSArray<MiniDramaItemButton *> *itemButtonArray;

@end

@implementation MiniDramaWithInStreamAdsMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorFromHexString:@"#F6F8FA"];
    [self addSubviewAndmakeConstraints];
    self.currentIndex = HomePageIndex;
    MDAdGlobalSettings.adsEnabled = YES;
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

- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
    self.homeListVC.viewisVisible = currentIndex == HomePageIndex;
    self.homeListVC.view.hidden = currentIndex != HomePageIndex;
    self.settingVC.view.hidden = currentIndex != SettingPageIndex;

    [self.itemButtonArray enumerateObjectsUsingBlock:^(MiniDramaItemButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.index == currentIndex) {
            obj.status = MiniDramaMainItemStatusActive;
        } else {
            obj.status = MiniDramaMainItemStatusDeactive;
        }
    }];

    if (currentIndex == HomePageIndex) {
        [self.view bringSubviewToFront:self.backButton];
    } else {
        [self.view sendSubviewToBack:self.backButton];
    }
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
    [self.view addSubview:self.homeListVC.view];
    [self.homeListVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.bottom.equalTo(self.bottomView.mas_top);
    }];

    [self addChildViewController:self.settingVC];
    [self.view addSubview:self.settingVC.view];
    [self.settingVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.bottom.equalTo(self.bottomView.mas_top);
    }];
}

#pragma mark - Getter

- (MiniDramaListViewController *)homeListVC {
    if (!_homeListVC) {
        _homeListVC = [[MiniDramaListViewController alloc] init];
    }
    return _homeListVC;
}

- (MDAdSettingViewController *)settingVC {
    if (!_settingVC) {
        _settingVC = [[MDAdSettingViewController alloc] init];
    }
    return _settingVC;
}

- (NSArray<MiniDramaItemButton *> *)itemButtonArray {
    if (!_itemButtonArray) {
        NSMutableArray *array = [NSMutableArray new];

        MiniDramaItemButton *HomeItem = [[MiniDramaItemButton alloc] init];
        HomeItem.index = HomePageIndex;
        [HomeItem bingImage:[UIImage imageNamed:@"vod_entry_home_dark" bundleName:@"VodPlayer"] status:MiniDramaMainItemStatusDeactive];
        [HomeItem bingImage:[UIImage imageNamed:@"vod_entry_home_s"  bundleName:@"VodPlayer"] status:MiniDramaMainItemStatusActive];
        [HomeItem bingTitleColor:[UIColor colorFromHexString:@"#EBEDF0"] status:MiniDramaMainItemStatusActive];
        [HomeItem bingTitleColor:[UIColor blackColor] status:MiniDramaMainItemStatusDeactive];
        [HomeItem setTitle:LocalizedStringFromBundle(@"mini_drama_home", @"MiniDrama") forState:UIControlStateNormal];
        [HomeItem addTarget:self action:@selector(scenesButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [array addObject:HomeItem];
        
        MiniDramaItemButton *SettingsItem = [[MiniDramaItemButton alloc] init];
        SettingsItem.index = SettingPageIndex;
        [SettingsItem bingImage:[UIImage imageNamed:@"vod_entry_setting" bundleName:@"VodPlayer"] status:MiniDramaMainItemStatusDeactive];
        [SettingsItem bingImage:[UIImage imageNamed:@"vod_entry_setting_s_dark" bundleName:@"VodPlayer"] status:MiniDramaMainItemStatusActive];
        [SettingsItem setTitle:LocalizedStringFromBundle(@"mini_drama_ads_setting", @"MiniDramaWithInStreamAds") forState:UIControlStateNormal];
        [SettingsItem bingTitleColor:[UIColor colorFromHexString:@"#EBEDF0"] status:MiniDramaMainItemStatusDeactive];
        [SettingsItem bingTitleColor:[UIColor blackColor] status:MiniDramaMainItemStatusActive];
        [SettingsItem addTarget:self action:@selector(scenesButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [array addObject:SettingsItem];

        _itemButtonArray = array.copy;
    }
    return _itemButtonArray;
}

- (void)scenesButtonAction:(MiniDramaItemButton *)sender {
    if (sender.index == HomePageIndex) {
        self.bottomView.backgroundColor = [UIColor colorFromHexString:@"#07080A"];
    } else {
        self.bottomView.backgroundColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.9 * 255];
    }
    [self setCurrentIndex:sender.index];
    [self setNeedsStatusBarAppearanceUpdate];
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

