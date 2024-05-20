// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELSettingsInputActionViewModel.h"
#import <MediaLive/VELCommon.h>
@implementation VELSettingsInputActionViewModel
- (instancetype)init {
    if (self = [super init]) {
        self.showQRScan = YES;
        self.keyboardType = UIKeyboardTypeDefault;
        self.insets = UIEdgeInsetsMake(15, 15, 15, 15);
        self.size = CGSizeMake(VELAutomaticDimension, 110);
        self.textFiledContainerBgColor = VELColorWithHexString(@"#535552");
        self.actionBtnBgColor = VELColorWithHexString(@"#535552");
        self.textFieldHeight = 35;
        self.btnSize = CGSizeMake(50, 27);
        self.showActionBtn = YES;
        self.btnTitleAttributes = @{
            NSFontAttributeName : [UIFont systemFontOfSize:14],
            NSForegroundColorAttributeName : UIColor.whiteColor,
        }.mutableCopy;
        self.selectBtnTitleAttributes = self.btnTitleAttributes.mutableCopy;
        self.titleAttribute = @{
            NSFontAttributeName : [UIFont systemFontOfSize:14],
            NSForegroundColorAttributeName : UIColor.whiteColor
        }.mutableCopy;
        self.leftTitleAttribute = self.titleAttribute.mutableCopy;
        self.placeHolderAttribute = @{
            NSFontAttributeName : [UIFont systemFontOfSize:14],
            NSForegroundColorAttributeName : [[UIColor whiteColor] colorWithAlphaComponent:0.7]
        }.mutableCopy;
        self.textAttribute = @{
            NSFontAttributeName : [UIFont systemFontOfSize:14],
            NSForegroundColorAttributeName : [UIColor whiteColor]
        }.mutableCopy;
        self.qrScanIcon = [self.qrScanIcon vel_imageByTintColor:UIColor.whiteColor];
    }
    return self;
}
@end
