// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPullViewController.h"
#import "VELPullUIViewController.h"
#import "VELPullNewViewController.h"
#import <MediaLive/VELApplication.h>
#import <MediaLive/VELSettings.h>
#import <ToolKit/Localizator.h>
@interface VELPullViewController ()
@property (nonatomic, strong) VELPullSettingsViewController *settingVC;
@property (nonatomic, strong) VELUILabel *versionLabel;
@end

@implementation VELPullViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.backgroundColor = UIColor.clearColor;
    [self.navigationBar onlyShowLeftBtn];
    [self showSettingViewController];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)startPlay {
    VELPullSettingConfig *config = self.settingVC.config;
    VELPullUIViewController *vc = nil;
#if __has_include("VELPullNewViewController.h")
    vc = [[VELPullNewViewController alloc] initWithConfig:config];
#endif
    if (vc == nil) {
        [VELUIToast showText:LocalizedStringFromBundle(@"medialive_pull_not_integration", @"MediaLive")];
        return;
    }
    [self vel_showViewController:vc animated:YES];
}

- (void)showSettingViewController {
    [self vel_addViewController:self.settingVC];
    [self.view addSubview:self.versionLabel];
    [self.settingVC.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navigationBar.mas_bottom);
        make.left.right.equalTo(self.view);
    }];
    [self.versionLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.settingVC.view.mas_bottom).mas_offset(8);
        make.left.right.equalTo(self.view);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        } else {
            make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
        }
    }];
}

+ (NSString *)getSDKVersionString {
    NSMutableString *versionString = @"".mutableCopy;
    [versionString appendFormat:@"BytePlus LivePlayer: %@", TVLManager.getVersion];
    return versionString.copy;
}

- (VELPullSettingsViewController *)settingVC {
    if (_settingVC == nil) {
        _settingVC = [[VELPullSettingsViewController alloc] init];
        _settingVC.showNavigationBar = NO;
        __weak __typeof__(self)weakSelf = self;
        _settingVC.startBlock = ^{
            __strong __typeof__(weakSelf)self = weakSelf;
            [self startPlay];
        };
    }
    return _settingVC;
}

- (VELUILabel *)versionLabel {
    if (!_versionLabel) {
        _versionLabel = [[VELUILabel alloc] init];
        [_versionLabel setContentCompressionResistancePriority:(UILayoutPriorityRequired) forAxis:(UILayoutConstraintAxisVertical)];
        [_versionLabel setContentHuggingPriority:(UILayoutPriorityRequired) forAxis:(UILayoutConstraintAxisVertical)];
        _versionLabel.textColor = VELColorWithHexString(@"#878787");
        _versionLabel.font = [UIFont systemFontOfSize:10];
        _versionLabel.textAlignment = NSTextAlignmentCenter;
        _versionLabel.text = [self.class getSDKVersionString];
    }
    return _versionLabel;
}
@end
