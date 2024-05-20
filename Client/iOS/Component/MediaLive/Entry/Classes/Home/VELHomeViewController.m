// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELHomeViewController.h"
#import "VELApplication.h"
#import <MediaLive/VELSettings.h>
#import <MediaLive/VELCommon.h>
#import <Masonry/Masonry.h>
#import <MediaLive/VELCore.h>
#import <MediaLive/VELPushViewController.h>
#import <MediaLive/VELPullViewController.h>
#import <ToolKit/Localizator.h>


@interface VELHomeViewController ()
@property (nonatomic, strong) NSArray <VELSettingsBaseViewModel *> *models;
@property (nonatomic, strong) VELSettingsTableView *settingTableView;
@property (nonatomic, strong) VELUILabel *versionLabel;
@property (nonatomic, strong) VELIQKeyboardManager *keyboardManager;
@end

@implementation VELHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LocalizedStringFromBundle(@"medialive_navbar_title", @"MediaLive");
    self.keyboardManager = [[VELIQKeyboardManager alloc] init];
    [self setupUI];
    [self configUIModel];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.keyboardManager.enable = YES;
}

- (BOOL)shouldPopViewController:(BOOL)isGesture {
    if (!isGesture) {
        self.keyboardManager.enable = NO;
        self.keyboardManager = nil;
        if (![self.navigationController isKindOfClass:VELUINavigationController.class]) {
            [self.navigationController vel_destroyNavGesture];
        }
        return YES;
    }
    return NO;
}

- (void)configUIModel {
    self.models = @[
        [self createCellModel:@"ic_home_live_push" title:LocalizedStringFromBundle(@"medialive_live_push", @"MediaLive") vcClass:VELPushViewController.class],
        [self createCellModel:@"ic_home_live_pull" title:LocalizedStringFromBundle(@"medialive_live_pull", @"MediaLive") vcClass:VELPullViewController.class],
    ];
    self.settingTableView.models = self.models;
}

- (VELSettingsButtonViewModel *)createCellModel:(NSString *)imgName title:(NSString *)title vcClass:(Class)vcClass {
    VELSettingsButtonViewModel *model = [VELSettingsButtonViewModel modelWithImage:VELUIImageMake(imgName)
                                                                         title:title
                                                                rightAccessory:VELUIImageMake(@"ic_arrow_right")];
    model.margin = UIEdgeInsetsMake(8, 16, 8, 16);
    model.insets = UIEdgeInsetsMake(23, 16, 23, 20);
    model.hasShadow = YES;
    model.imageSize = CGSizeMake(30, 30);
    model.titleAttributes[NSFontAttributeName] = [UIFont systemFontOfSize:16];
    model.extraInfo[VELExtraInfoKeyClass] = vcClass;
    __weak __typeof__(self)weakSelf = self;
    [model setSelectedBlock:^(__kindof VELSettingsBaseViewModel * _Nonnull model, NSInteger index) {
        __strong __typeof__(weakSelf)self = weakSelf;
        Class cls = model.extraInfo[VELExtraInfoKeyClass];
        [self vel_showViewController:[[cls alloc] init] animated:YES];
    }];
    return model;
}

- (void)setupUI {
    self.view.backgroundColor = VELViewBackgroundColor;
    [self.view addSubview:self.settingTableView];
    [self.settingTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navigationBar.mas_bottom).mas_offset(8);
        make.left.right.equalTo(self.view);
    }];
    [self.view addSubview:self.versionLabel];
    [self.versionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).mas_offset(8);
        make.right.equalTo(self.view).mas_offset(-8);
        make.top.equalTo(self.settingTableView.mas_bottom);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        } else {
            make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
        }
    }];
    if (self.navigationController.viewControllers.firstObject != self) {
        self.navigationBar.leftButton.hidden = NO;
    }
    if (![self.navigationController isKindOfClass:VELUINavigationController.class]) {
        [self.navigationController vel_setupNavGesture];
    }
}

- (VELUILabel *)versionLabel {
    if (!_versionLabel) {
        _versionLabel = [[VELUILabel alloc] init];
        _versionLabel.numberOfLines = 0;
        _versionLabel.backgroundColor = UIColor.clearColor;
        _versionLabel.font = [UIFont systemFontOfSize:12];
        _versionLabel.textColor = VELColorWithHex(0x878787);
        _versionLabel.text = [VELApplication getSDKVersionString];
        _versionLabel.textAlignment = NSTextAlignmentCenter;
        _versionLabel.canCopy = YES;
        _versionLabel.lineHeight = 12;
    }
    return _versionLabel;
}

- (VELSettingsTableView *)settingTableView {
    if (!_settingTableView) {
        _settingTableView = [[VELSettingsTableView alloc] init];
        _settingTableView.allowSelection = YES;
    }
    return _settingTableView;
}

@end
