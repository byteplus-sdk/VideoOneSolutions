// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELSettingsPopChooseViewModel.h"
#import <MediaLive/VELCommon.h>
#import <ToolKit/Localizator.h>
@interface VELSettingsPopChooseViewModel ()
@property (nonatomic, strong, readwrite, nullable) NSArray <NSNumber *> *menuValues;
@end
@implementation VELSettingsPopChooseViewModel
- (instancetype)init {
    if (self = [super init]) {
        self.menuHoldBorderColor = VELColorWithHexString(@"#FFEEEE");
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
    if ([model isKindOfClass:VELSettingsPopChooseViewModel.class]) {
        VELSettingsPopChooseViewModel *segmentModel = (VELSettingsPopChooseViewModel *)model;
        self.menuStrings = segmentModel.menuStrings.copy;
        _menuModels = nil;
    }
}

+ (VELSettingsPopChooseViewModel *)createCommonMenuModelWithTitle:(NSString *)title
                                                       menuTitles:(NSArray <NSString *>*)menuTitles
                                                       menuValues:(NSArray <NSNumber *> *)menuValues
                                                      selectBlock:(BOOL (^)(NSInteger index, NSNumber *value))selectBlock {
    NSAssert(menuTitles.count == menuValues.count, LocalizedStringFromBundle(@"medialive_count_equal_error", @"MediaLive"));
    
    VELSettingsPopChooseViewModel *model = [[VELSettingsPopChooseViewModel alloc] init];
    model.title = title;
    model.backgroundColor = UIColor.clearColor;
    model.titleAttributes[NSForegroundColorAttributeName] = UIColor.whiteColor;
    model.menuHoldTitleAttributes[NSForegroundColorAttributeName] = UIColor.whiteColor;
    model.menuHoldTitleAttributes[NSFontAttributeName] = [UIFont systemFontOfSize:12];
    model.containerBackgroundColor = [VELColorWithHexString(@"#535552") colorWithAlphaComponent:0.8];
    model.containerSelectBackgroundColor = [VELColorWithHexString(@"#535552") colorWithAlphaComponent:0.8];
    model.menuStrings = menuTitles;
    model.insets = UIEdgeInsetsMake(2, 5, 2, 5);
    model.menuValues = menuValues;
    [model setMenuSelectedBlock:^BOOL (NSInteger index) {
        if (selectBlock) {
            return selectBlock(index, menuValues[index]);
        }
        return YES;
    }];
    model.size = CGSizeMake((VEL_DEVICE_WIDTH - 40) * 0.5, 34);
    __block CGFloat maxWidth = 0;
    NSDictionary *attributes = @{
        NSFontAttributeName : [UIFont systemFontOfSize:14]
    };
    [menuTitles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
         maxWidth = MAX(maxWidth, [obj sizeWithAttributes:attributes].width);
    }];
    maxWidth = MIN(maxWidth, model.size.width);
    [[model menuModels] enumerateObjectsUsingBlock:^(VELSettingsButtonViewModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hasBorder = NO;
        obj.hasShadow = NO;
        obj.cornerRadius = 6;
        obj.containerBackgroundColor = [UIColor clearColor];
        obj.containerSelectBackgroundColor = VELColorWithHexString(@"#535552");
        obj.size = CGSizeMake(MAX(90, maxWidth + 30), 34);
        obj.selectTitleAttributes[NSForegroundColorAttributeName] = VELColorWithHexString(@"#E8E5E5");
        obj.extraInfo[@"MENU_VALUE"] = menuValues[idx];
    }];
    return model;
}
+ (VELSettingsPopChooseViewModel *)createWhiteCommonMenuModelWithTitle:(NSString *)title
                                                       menuTitles:(NSArray <NSString *>*)menuTitles
                                                       menuValues:(NSArray <NSNumber *> *)menuValues
                                                           selectBlock:(BOOL (^)(NSInteger index, NSNumber *value))selectBlock {
    NSAssert(menuTitles.count == menuValues.count, LocalizedStringFromBundle(@"medialive_count_equal_error", @"MediaLive"));
    
    VELSettingsPopChooseViewModel *model = [[VELSettingsPopChooseViewModel alloc] init];
    model.title = title;
    model.backgroundColor = UIColor.clearColor;
    model.titleAttributes[NSForegroundColorAttributeName] = UIColor.blackColor;
    model.menuHoldTitleAttributes[NSForegroundColorAttributeName] = UIColor.blackColor;
    model.menuHoldTitleAttributes[NSFontAttributeName] = [UIFont systemFontOfSize:12];
    model.containerBackgroundColor = UIColor.whiteColor;
    model.containerSelectBackgroundColor = UIColor.whiteColor;
    model.menuHoldBorderColor = UIColor.blackColor;
    model.menuStrings = menuTitles;
    model.insets = UIEdgeInsetsMake(3, 5, 3, 5);
    model.menuValues = menuValues;
    [model setMenuSelectedBlock:^BOOL (NSInteger index) {
        if (selectBlock) {
            return selectBlock(index, menuValues[index]);
        }
        return YES;
    }];
    model.size = CGSizeMake((VEL_DEVICE_WIDTH - 40) * 0.5, 34);
    __block CGFloat maxWidth = 0;
    NSDictionary *attributes = @{
        NSFontAttributeName : [UIFont systemFontOfSize:14]
    };
    [menuTitles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
         maxWidth = MAX(maxWidth, [obj sizeWithAttributes:attributes].width);
    }];
    maxWidth = MIN(maxWidth, model.size.width);
    [[model menuModels] enumerateObjectsUsingBlock:^(VELSettingsButtonViewModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hasBorder = NO;
        obj.hasShadow = NO;
        obj.cornerRadius = 6;
        obj.containerBackgroundColor = [UIColor clearColor];
        obj.containerSelectBackgroundColor = [VELColorWithHexString(@"#535552") colorWithAlphaComponent:0.4];
        obj.size = CGSizeMake(MAX(90, maxWidth + 30), 34);
        obj.selectTitleAttributes[NSForegroundColorAttributeName] = VELColorWithHexString(@"#E8E5E5");
        obj.extraInfo[@"MENU_VALUE"] = menuValues[idx];
    }];
    return model;
}
@end
