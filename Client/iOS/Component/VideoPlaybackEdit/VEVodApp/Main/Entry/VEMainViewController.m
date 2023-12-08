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

@interface VEMainViewController ()

@property (nonatomic, strong) VEViewController *currentVC;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) NSDictionary *viewControllerDic;
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *itemNameDic;
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
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

#pragma mark - Touch Action

- (void)scenesButtonAction:(VEMainItemButton *)sender {
    NSInteger index = sender.tag - 3000;
    VEViewController *viewController = self.viewControllerDic[@(index).stringValue];
    if (![viewController isKindOfClass:[VEViewController class]]) {
        if (self.clickTabCenterBolck) {
            self.clickTabCenterBolck();
            [self.currentVC clickTabCenterAction];
        }
        return;
    }

    [self reset:index];
    viewController.view.hidden = NO;
    [viewController tabViewDidAppear];
    sender.status = ButtonStatusActive;
    self.currentVC = viewController;
    self.bottomView.backgroundColor = [self getDrak:index] ? [UIColor colorFromHexString:@"#07080A"] : [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.9 * 255];
}

#pragma mark - Private Action

- (void)addSubviewAndmakeConstraints {
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo([DeviceInforTool getVirtualHomeHeight] + 48);
    }];

    NSMutableArray *list = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.viewControllerDic.count; i++) {
        VEMainItemButton *scenesButton = [self createItemButton:i];
        [self.bottomView addSubview:scenesButton];
        [list addObject:scenesButton];

        UIViewController *viewController = self.viewControllerDic[@(i).stringValue];
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
    self.itemButtonArray = [list copy];
}

- (VEMainItemButton *)createItemButton:(NSInteger)index {
    NSString *message = LocalizedStringFromBundle(self.itemNameDic[@(index).stringValue], @"VEVodApp");
    VEMainItemButton *itemButton = [[VEMainItemButton alloc] init];
    itemButton.tag = 3000 + index;
    itemButton.backgroundColor = [UIColor clearColor];
    [itemButton addTarget:self action:@selector(scenesButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    itemButton.imageEdgeInsets = UIEdgeInsetsMake(4, 0, 20, 0);
    itemButton.desTitle = message;

    BOOL isDark = [self getDrak:index];
    NSString *imageName = [self getImageName:index isAction:NO isDark:isDark];
    NSString *imageActionName = [self getImageName:index isAction:YES isDark:isDark];

    [itemButton bingImage:[UIImage imageNamed:imageName]
                   status:ButtonStatusNone];
    [itemButton bingImage:[UIImage imageNamed:imageActionName]
                   status:ButtonStatusActive];

    return itemButton;
}

- (void)reset:(NSInteger)index {
    self.currentVC.view.hidden = YES;
    [self.currentVC tabViewDidDisappear];
    BOOL isDark = [self getDrak:index];
    for (int i = 0; i < self.itemButtonArray.count; i++) {
        VEMainItemButton *button = self.itemButtonArray[i];
        button.status = ButtonStatusNone;

        NSString *imageName = [self getImageName:i isAction:NO isDark:isDark];
        NSString *imageActionName = [self getImageName:i isAction:YES isDark:isDark];

        [button bingImage:[UIImage imageNamed:imageName]
                   status:ButtonStatusNone];
        [button bingImage:[UIImage imageNamed:imageActionName]
                   status:ButtonStatusActive];

        [button bingLabelColor:[self getTitleColor:NO isDark:isDark]
                        status:ButtonStatusNone];
        [button bingLabelColor:[self getTitleColor:YES isDark:isDark]
                        status:ButtonStatusActive];
    }
}

- (BOOL)getDrak:(NSInteger)index {
    BOOL isDrak = NO;
    switch (index) {
        case 0:
        case 1:
        case 2:
            isDrak = YES;
            break;

        default:
            break;
    }
    return isDrak;
}

- (UIColor *)getTitleColor:(BOOL)isAction
                    isDark:(BOOL)isDark {
    UIColor *color = nil;
    if (isDark) {
        color = isAction ? [UIColor colorFromHexString:@"#EBEDF0"] : [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.7 * 255];
    } else {
        color = [UIColor colorFromHexString:@"#0C0D0F"];
    }
    return color;
}

- (NSString *)getImageName:(NSInteger)index
                  isAction:(BOOL)isAction
                    isDark:(BOOL)isDark {
    NSString *name = @"";
    switch (index) {
        case 0: {
            if (isDark) {
                name = isAction ? @"vod_entry_home_s" : @"vod_entry_home";
            } else {
                name = @"vod_entry_home_dark";
            }
            break;
        }

        case 1: {
            if (isDark) {
                name = isAction ? @"vod_entry_feed_s" : @"vod_entry_feed";
            } else {
                name = @"vod_entry_feed_dark";
            }
            break;
        }

        case 2:
            name = isDark ? @"vod_entry_add" : @"vod_entry_add_dark";
            break;

        case 3: {
            if (isDark) {
                name = @"vod_entry_channel";
            } else {
                name = isAction ? @"vod_entry_channel_s_dark" : @"vod_entry_channel_dark";
            }
            break;
        }

        case 4: {
            if (isDark) {
                name = @"vod_entry_setting";
            } else {
                name = isAction ? @"vod_entry_setting_s_dark" : @"vod_entry_setting_dark";
            }
            break;
        }

        default:
            break;
    }
    return name;
}

- (NSDictionary *)viewControllerDic {
    if (!_viewControllerDic) {
        _viewControllerDic = @{@"0": [[VEShortVideoViewController alloc] init],
                               @"1": [[VEFeedVideoViewController alloc] init],
                               @"2": @"",
                               @"3": [[VELongVideoViewController alloc] init],
                               @"4": [[VESettingViewController alloc] init]};
    }
    return _viewControllerDic;
}

- (NSDictionary<NSString *, NSString *> *)itemNameDic {
    if (!_itemNameDic) {
        _itemNameDic = @{
            @"0": @"vod_entry_home",
            @"1": @"vod_entry_feed",
            @"2": @"",
            @"3": @"vod_entry_channel",
            @"4": @"vod_entry_setting",
        };
    }
    return _itemNameDic;
}

#pragma mark - Getter

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
    }
    return _bottomView;
}

@end
