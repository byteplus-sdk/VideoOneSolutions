// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELSettingsSegmentViewModel.h"
#import <MediaLive/VELCommon.h>
@implementation VELSettingsSegmentViewModel
- (instancetype)init {
    if (self = [super init]) {
        self.spacingBetweenTitleAndSegments = 16;
        self.itemMargin = 10;
        self.alignment = UIControlContentHorizontalAlignmentLeft;
        _scrollDirection = UICollectionViewScrollDirectionHorizontal;
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

- (NSArray<VELSettingsButtonViewModel *> *)segmentModels {
    if (!_segmentModels && self.segmentStrings.count > 0) {
        NSMutableArray *models = [NSMutableArray arrayWithCapacity:self.segmentStrings.count];
        [self.segmentStrings enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            VELSettingsButtonViewModel *model = [VELSettingsButtonViewModel modelWithTitle:obj];
            [model syncSettings:self];
            model.margin = UIEdgeInsetsZero;
            model.insets = UIEdgeInsetsZero;
            model.hasBorder = YES;
            model.selectedBorderColor = UIColor.clearColor;
            model.size = CGSizeMake(VELAutomaticDimension, self.size.height - VELUIEdgeInsetsGetVerticalValue(self.insets) - VELUIEdgeInsetsGetVerticalValue(self.margin));
            [models addObject:model];
        }];
        _segmentModels = models.copy;
    }
    return _segmentModels;
}
- (VELSettingsBaseViewModel *)selectModel {
    if (self.selectIndex < 0 || self.selectIndex >= self.segmentModels.count) {
        return nil;
    }
    return [self.segmentModels objectAtIndex:self.selectIndex];
}
- (void)syncSettings:(VELSettingsBaseViewModel *)model {
    [super syncSettings:model];
    if ([model isKindOfClass:VELSettingsSegmentViewModel.class]) {
        VELSettingsSegmentViewModel *segmentModel = (VELSettingsSegmentViewModel *)model;
        self.segmentStrings = segmentModel.segmentStrings.copy;
        _segmentModels = nil;
    }
}
@end
