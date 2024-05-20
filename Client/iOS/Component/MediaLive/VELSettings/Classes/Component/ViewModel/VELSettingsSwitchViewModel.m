// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELSettingsSwitchViewModel.h"
#import <MediaLive/VELCommon.h>
@implementation VELSettingsSwitchViewModel
- (instancetype)init {
    if (self = [super init]) {
        self.onTintColor = [UIColor clearColor];
        self.onBorderColor = UIColor.whiteColor;
        self.onThumbColor = UIColor.whiteColor;
        self.offTintColor = [UIColor clearColor];
        self.offBorderColor =  VELColorWithHexString(@"#636363");
        self.offThumbColor = VELColorWithHexString(@"#636363");
        self.enable = YES;
        self.switchSize = CGSizeMake(36, 24);
        self.titleAttribute = @{
            NSFontAttributeName : [UIFont systemFontOfSize:14],
            NSForegroundColorAttributeName : UIColor.whiteColor
        }.mutableCopy;
    }
    return self;
}

- (void)setLightStyle:(BOOL)lightStyle {
    _lightStyle = lightStyle;
    if (_lightStyle) {
        self.onTintColor = [UIColor whiteColor];
        self.onBorderColor = VELColorWithHexString(@"#35C75A");
        self.onThumbColor = VELColorWithHexString(@"#35C75A");
        self.offTintColor = [UIColor whiteColor];
        self.offBorderColor =  VELColorWithHexString(@"#E0DEDE");
        self.offThumbColor = VELColorWithHexString(@"#E0DEDE");
        self.titleAttribute = @{
            NSFontAttributeName : [UIFont systemFontOfSize:14],
            NSForegroundColorAttributeName : UIColor.blackColor
        }.mutableCopy;
    } else {
        self.onTintColor = [UIColor clearColor];
        self.onBorderColor = UIColor.whiteColor;
        self.onThumbColor = UIColor.whiteColor;
        self.offTintColor = [UIColor clearColor];
        self.offBorderColor =  VELColorWithHexString(@"#636363");
        self.offThumbColor = VELColorWithHexString(@"#636363");
        self.titleAttribute = @{
            NSFontAttributeName : [UIFont systemFontOfSize:14],
            NSForegroundColorAttributeName : UIColor.whiteColor
        }.mutableCopy;
    }
}
@end
