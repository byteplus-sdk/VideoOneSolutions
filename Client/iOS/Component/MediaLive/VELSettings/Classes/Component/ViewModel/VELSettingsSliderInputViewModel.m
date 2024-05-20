// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELSettingsSliderInputViewModel.h"
#import <MediaLive/VELCommon.h>
@implementation VELSettingsSliderInputViewModel
- (instancetype)init {
    if (self = [super init]) {
        self.titleAttribute = @{
            NSFontAttributeName : [UIFont systemFontOfSize:14 weight:(UIFontWeightRegular)],
            NSForegroundColorAttributeName : UIColor.blackColor,
        }.mutableCopy;
        self.textAttribute = @{
            NSFontAttributeName : [UIFont systemFontOfSize:14],
            NSForegroundColorAttributeName : UIColor.blackColor,
        }.mutableCopy;
        NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
        [paraStyle setParagraphStyle:NSParagraphStyle.defaultParagraphStyle];
        paraStyle.alignment = NSTextAlignmentCenter;
        self.inputTextAttribute = @{
            NSFontAttributeName : [UIFont systemFontOfSize:14],
            NSForegroundColorAttributeName : UIColor.blackColor,
            NSParagraphStyleAttributeName : paraStyle
        }.mutableCopy;
        self.value = 0;
        self.minimumValue = 0;
        self.maximumValue = 1;
        self.inputBgColor = [VELColorWithHexString(@"#000000") colorWithAlphaComponent:0.12];
        self.minimumTrackColor = VELColorWithHexString(@"#35C75A");
        self.thumbColor = VELColorWithHexString(@"#35C75A");
        self.disableThumbColor = VELColorWithHexString(@"#6E6E6E");
        self.inputOutset = UIEdgeInsetsMake(8, 16, 8, 16);
        self.inputSize = CGSizeMake(58, -1);
        self.maximumTrackColor = VELColorWithHexString(@"#E0DEDE");
        self.valueFormat = @"%.2f";
        self.enable = YES;
    }
    return self;
}
@end
