// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEMainViewController.h"
#import "Masonry.h"
#import "ToolKit.h"
#import "VEFeedVideoViewController.h"
#import "VELongVideoViewController.h"
#import "VEMainItemButton.h"
#import "VESettingViewController.h"
#import "VEShortVideoViewController.h"
#import <Toolkit/Localizator.h>

static inline BOOL VEIsMainDartTheme(NSUInteger index) {
    return (index == 0 || index == 1);
}

@interface VEMainViewController ()

@property (nonatomic, weak) VEViewController *currentVC;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) NSArray<VEMainItemButton *> *itemButtonArray;

@end

@implementation VEMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorFromHexString:@"#F6F8FA"];

    [self addSubviewAndmakeConstraints];
    [self scenesButtonAction:self.itemButtonArray.firstObject];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [self.currentVC preferredStatusBarStyle];
}

#pragma mark - Touch Action

- (void)scenesButtonAction:(VEMainItemButton *)sender {
    VEViewController *viewController = sender.bingedVC;
    if (![viewController isKindOfClass:[VEViewController class]]) {
        if (self.clickTabCenterBolck) {
            self.clickTabCenterBolck();
            [self.currentVC clickTabCenterAction];
        }
        return;
    }
    if (self.currentVC == viewController) {
        return;
    }
    [self reset:sender.index];
    viewController.view.hidden = NO;
    [viewController tabViewDidAppear];
    sender.status = VEMainItemStatusActive;
    self.currentVC = viewController;
    [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark - Private Action

- (void)addSubviewAndmakeConstraints {
    self.bottomView = [[UIView alloc] init];
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-48);
    }];

    NSMutableArray *list = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.itemButtonArray.count; i++) {
        VEMainItemButton *scenesButton = self.itemButtonArray[i];
        [self.bottomView addSubview:scenesButton];
        [list addObject:scenesButton];

        UIViewController *viewController = scenesButton.bingedVC;
        if (![viewController isKindOfClass:[UIViewController class]]) {
            continue;
        }
        [self addChildViewController:viewController];
        viewController.view.hidden = YES;
        [self.view addSubview:viewController.view];
        [viewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self.view);
            make.bottom.equalTo(self.bottomView.mas_top);
        }];
    }
    [list mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:0 leadSpacing:0 tailSpacing:0];
    [list mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomView);
        make.height.mas_equalTo(48);
    }];
}

- (void)reset:(NSInteger)index {
    self.currentVC.view.hidden = YES;
    [self.currentVC tabViewDidDisappear];
    BOOL isDark = VEIsMainDartTheme(index);
    self.bottomView.backgroundColor = isDark ? [UIColor colorFromHexString:@"#07080A"] : [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.9 * 255];
    for (int i = 0; i < self.itemButtonArray.count; i++) {
        VEMainItemButton *button = self.itemButtonArray[i];
        button.status = isDark ? VEMainItemStatusLight : VEMainItemStatusDark;
    }
}

#pragma mark - Getter

- (NSArray<VEMainItemButton *> *)itemButtonArray {
    if (!_itemButtonArray) {
        NSMutableArray *array = [NSMutableArray new];

        VEMainItemButton *shortVideoItem = [[VEMainItemButton alloc] init];
        shortVideoItem.index = 0;
        shortVideoItem.bingedVC = [[VEShortVideoViewController alloc] init];
        [shortVideoItem bingImage:[UIImage imageNamed:@"vod_entry_home_dark"] status:VEMainItemStatusDark];
        [shortVideoItem bingImage:[UIImage imageNamed:@"vod_entry_home"] status:VEMainItemStatusLight];
        [shortVideoItem bingImage:[UIImage imageNamed:@"vod_entry_home_s"] status:VEMainItemStatusActive];
        [shortVideoItem bingTitleColor:[UIColor colorFromHexString:@"#EBEDF0"] status:VEMainItemStatusActive];
        [shortVideoItem setTitle:LocalizedStringFromBundle(@"vod_entry_home", @"VEVodApp") forState:UIControlStateNormal];
        [shortVideoItem addTarget:self action:@selector(scenesButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [array addObject:shortVideoItem];

        VEMainItemButton *feedVideoItem = [[VEMainItemButton alloc] init];
        feedVideoItem.index = 1;
        feedVideoItem.bingedVC = [[VEFeedVideoViewController alloc] init];
        [feedVideoItem bingImage:[UIImage imageNamed:@"vod_entry_feed_dark"] status:VEMainItemStatusDark];
        [feedVideoItem bingImage:[UIImage imageNamed:@"vod_entry_feed"] status:VEMainItemStatusLight];
        [feedVideoItem bingImage:[UIImage imageNamed:@"vod_entry_feed_s"] status:VEMainItemStatusActive];
        [feedVideoItem setTitle:LocalizedStringFromBundle(@"vod_entry_feed", @"VEVodApp") forState:UIControlStateNormal];
        [feedVideoItem bingTitleColor:[UIColor colorFromHexString:@"#EBEDF0"] status:VEMainItemStatusActive];
        [feedVideoItem addTarget:self action:@selector(scenesButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [array addObject:feedVideoItem];

        VEMainItemButton *longVideoItem = [[VEMainItemButton alloc] init];
        longVideoItem.index = 2;
        longVideoItem.bingedVC = [[VELongVideoViewController alloc] init];
        [longVideoItem bingImage:[UIImage imageNamed:@"vod_entry_channel_dark"] status:VEMainItemStatusDark];
        [longVideoItem bingImage:[UIImage imageNamed:@"vod_entry_channel"] status:VEMainItemStatusLight];
        [longVideoItem bingImage:[UIImage imageNamed:@"vod_entry_channel_s_dark"] status:VEMainItemStatusActive];
        [longVideoItem setTitle:LocalizedStringFromBundle(@"vod_entry_channel", @"VEVodApp") forState:UIControlStateNormal];
        [longVideoItem addTarget:self action:@selector(scenesButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [array addObject:longVideoItem];

        VEMainItemButton *settingItem = [[VEMainItemButton alloc] init];
        settingItem.index = 3;
        settingItem.bingedVC = [[VESettingViewController alloc] init];
        [settingItem bingImage:[UIImage imageNamed:@"vod_entry_setting_dark"] status:VEMainItemStatusDark];
        [settingItem bingImage:[UIImage imageNamed:@"vod_entry_setting"] status:VEMainItemStatusLight];
        [settingItem bingImage:[UIImage imageNamed:@"vod_entry_setting_s_dark"] status:VEMainItemStatusActive];
        [settingItem setTitle:LocalizedStringFromBundle(@"vod_entry_setting", @"VEVodApp") forState:UIControlStateNormal];
        [settingItem addTarget:self action:@selector(scenesButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [array addObject:settingItem];

        _itemButtonArray = array.copy;
    }
    return _itemButtonArray;
}

@end
