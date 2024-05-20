// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELSettingsInputViewModel.h"
#import <MediaLive/VELCommon.h>
@implementation VELSettingsInputViewModel
- (instancetype)init{
    if (self = [super init]) {
        self.insets = UIEdgeInsetsMake(16, 0, 0, 0);
        self.textInset = UIEdgeInsetsMake(16, 16, 16, 16);
        self.titleAttribute = @{
            NSFontAttributeName : [UIFont boldSystemFontOfSize:20],
            NSForegroundColorAttributeName : VELColorWithHex(0x1D2129)
        }.mutableCopy;
        self.placeHolderAttribute = @{
            NSFontAttributeName : [UIFont systemFontOfSize:14],
            NSForegroundColorAttributeName : VELColorWithHex(0xC9CDD4)
        }.mutableCopy;
        self.textAttribute = @{
            NSFontAttributeName : [UIFont systemFontOfSize:14],
            NSForegroundColorAttributeName : VELColorWithHex(0x1D2129)
        }.mutableCopy;
        self.qrScanTipAttribute = self.textAttribute.mutableCopy;
        self.spacingBetweenQRAndInput = 16;
        self.spacingBetweenTitleAndInput = 16;
        self.qrScanIcon = VELUIImageMake(@"vel_qr_scan");
        self.qrScanSize = CGSizeMake(20, 20);
        self.showQRScan = YES;
    }
    return self;
}
+ (instancetype)modeWithTitle:(NSString *)title placeHolder:(NSString *)placeHolder {
    VELSettingsInputViewModel *model = [[self alloc] init];
    model.title = title;
    model.placeHolder = placeHolder;
    return model;
}
@end
