// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELSettingsPickerViewModel.h"
#import <MediaLive/VELCommon.h>
@implementation VELSettingsPickerViewModel
- (instancetype)init {
    if (self = [super init]) {
        self.menuHoldTitleAttributes = @{
            NSFontAttributeName : [UIFont systemFontOfSize:14 weight:(UIFontWeightRegular)],
            NSForegroundColorAttributeName : UIColor.blackColor,
        }.mutableCopy;
        self.alignment = UIControlContentHorizontalAlignmentLeft;
        self.titleAttributes = @{
            NSFontAttributeName : [UIFont systemFontOfSize:14 weight:(UIFontWeightRegular)],
            NSForegroundColorAttributeName : UIColor.blackColor,
        }.mutableCopy;
        self.selectTitleAttributes = @{
            NSFontAttributeName : [UIFont systemFontOfSize:14 weight:(UIFontWeightRegular)],
            NSForegroundColorAttributeName : UIColor.blackColor,
        }.mutableCopy;
    }
    return self;
}

- (NSArray<VELSettingsButtonViewModel *> *)menuModels {
    if (!_menuModels && self.menuStrings.count > 0) {
        NSMutableArray *models = [NSMutableArray arrayWithCapacity:self.menuStrings.count];
        [self.menuStrings enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            VELSettingsButtonViewModel *model = [VELSettingsButtonViewModel modelWithTitle:obj];
            [model syncSettings:self];
            [model clearDefault];
            model.hasBorder = NO;
            model.selectedBorderColor = UIColor.clearColor;
            CGFloat textWidth = [obj sizeWithAttributes:self.titleAttributes].width;
            textWidth += VELUIEdgeInsetsGetHorizontalValue(self.margin);
            model.size = CGSizeMake(textWidth, self.size.height - VELUIEdgeInsetsGetVerticalValue(self.insets) - VELUIEdgeInsetsGetVerticalValue(self.margin));
            [models addObject:model];
        }];
        _menuModels = models.copy;
    }
    return _menuModels;
}

- (VELSettingsBaseViewModel *)selectModel {
    if (self.selectIndex < 0 || self.selectIndex >= self.menuModels.count) {
        return nil;
    }
    return [self.menuModels objectAtIndex:self.selectIndex];
}

- (void)syncSettings:(VELSettingsBaseViewModel *)model {
    [super syncSettings:model];
    if ([model isKindOfClass:VELSettingsPickerViewModel.class]) {
        VELSettingsPickerViewModel *segmentModel = (VELSettingsPickerViewModel *)model;
        self.menuStrings = segmentModel.menuStrings.copy;
        _menuModels = nil;
    }
}
@end
