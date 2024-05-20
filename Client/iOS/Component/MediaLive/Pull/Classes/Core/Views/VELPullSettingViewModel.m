// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPullSettingViewModel.h"
@interface VELPullSettingViewModel ()
@property (nonatomic, strong, readwrite) UIView *settingsView;
@property (nonatomic, copy, readwrite) NSString *cellIdentifier;
@end
@implementation VELPullSettingViewModel
- (instancetype)init {
    if (self = [super init]) {
        [self setupViewModels];
    }
    return self;
}
- (void)setupViewModels {
}
- (void)setupSettingsView {
}

- (NSString *)cellIdentifier {
    if (!_cellIdentifier) {
        _cellIdentifier = [NSString stringWithFormat:@"VELPullSettingViewModel_%@", self];
    }
    return _cellIdentifier;
}

- (UIView *)settingsView {
    if (!_settingsView) {
        _settingsView = [[UIView alloc] init];
        [self setupSettingsView];
    }
    return _settingsView;
}
@end
