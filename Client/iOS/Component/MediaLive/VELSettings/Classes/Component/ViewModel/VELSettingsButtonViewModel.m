// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELSettingsButtonViewModel.h"
#import <MediaLive/VELCommon.h>
@implementation VELSettingsButtonViewModel
- (instancetype)init {
    if (self = [super init]) {
        self.contentMode = UIViewContentModeLeft;
        self.imagePosition = VELImagePositionLeft;
        self.titleAttributes = @{
            NSFontAttributeName : [UIFont systemFontOfSize:14],
            NSForegroundColorAttributeName : UIColor.blackColor,
        }.mutableCopy;
        self.selectTitleAttributes = self.titleAttributes.mutableCopy;
        self.imageSize = CGSizeMake(VELAutomaticDimension, VELAutomaticDimension);
        self.accessorySize = CGSizeMake(16, 16);
        self.spacingBetweenImageAndTitle = 12;
        self.spacingBetweenImageTitleAndPoint = 10;
        self.pointSize = CGSizeMake(8, 8);
        self.pointColor = UIColor.blackColor;
        self.alignment = UIControlContentHorizontalAlignmentCenter;
    }
    return self;
}

+ (instancetype)modelWithImage:(UIImage *)image title:(NSString *)title rightAccessory:(UIImage *)rightAccessory {
    VELSettingsButtonViewModel *model = [self modelWithTitle:title];;
    model.image = image;
    model.rightAccessory = rightAccessory;
    return model;
}
+ (instancetype)modelWithTitle:(NSString *)title {
    VELSettingsButtonViewModel *model = [[self alloc] init];
    model.title = title;
    return model;
}
- (void)syncSettings:(VELSettingsBaseViewModel *)model {
    [super syncSettings:model];
    if ([model isKindOfClass:VELSettingsButtonViewModel.class]) {
        VELSettingsButtonViewModel *btnModel = (VELSettingsButtonViewModel *)model;
        self.contentMode = btnModel.contentMode;
        self.imagePosition = btnModel.imagePosition;
        self.titleAttributes = btnModel.titleAttributes;
        self.selectTitleAttributes = btnModel.selectTitleAttributes;
        self.imageSize = btnModel.imageSize;
        self.accessorySize = btnModel.accessorySize;
        self.spacingBetweenImageAndTitle = btnModel.spacingBetweenImageAndTitle;
        self.spacingBetweenImageTitleAndPoint = btnModel.spacingBetweenImageTitleAndPoint;
        self.pointSize = btnModel.pointSize;
        self.pointColor = btnModel.pointColor;
    }
}

+ (instancetype)modelWithTitle:(NSString *)title action:(void (^)(VELSettingsButtonViewModel *model, NSInteger index))action {
    VELSettingsButtonViewModel *model = [[VELSettingsButtonViewModel alloc] init];
    model.title = title;
    model.backgroundColor = UIColor.clearColor;
    model.titleAttributes[NSForegroundColorAttributeName] = UIColor.whiteColor;
    model.selectTitleAttributes[NSForegroundColorAttributeName] = UIColor.whiteColor;
    model.cornerRadius = 5;
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:12]};
    NSStringDrawingOptions opts = NSStringDrawingUsesLineFragmentOrigin |
    NSStringDrawingUsesFontLeading;
    CGFloat textWidth = [title boundingRectWithSize:
                       CGSizeMake(1000, 27)
                                          options:opts 
                                       attributes:attribute
                                          context:nil].size.width + 20;
    
    model.size = CGSizeMake(textWidth < 80 ? 80 : textWidth, 27);
    model.imagePosition = VELImagePositionLeft;
    model.spacingBetweenImageAndTitle = 3;
    model.contentMode = UIViewContentModeCenter;
    model.alignment = UIControlContentHorizontalAlignmentCenter;
    model.containerBackgroundColor = VELColorWithHexString(@"#535552");
    model.containerSelectBackgroundColor = VELColorWithHexString(@"#535552");
    model.userInteractionEnabled = YES;
    [model setSelectedBlock:action];
    return model;
}

+ (instancetype)checkBoxModelWithTitle:(NSString *)title action:(void (^)(VELSettingsButtonViewModel *model, NSInteger index))action {
    VELSettingsButtonViewModel *model = [self modelWithTitle:title action:action];
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:12]};
    NSStringDrawingOptions opts = NSStringDrawingUsesLineFragmentOrigin |
    NSStringDrawingUsesFontLeading;
    CGFloat textWidth = [title boundingRectWithSize:
                       CGSizeMake(1000, 27)
                                          options:opts
                                       attributes:attribute
                                            context:nil].size.width + 40;
    model.size = CGSizeMake(textWidth < 80 ? 80 : textWidth, 27);
    [model clearDefault];
    model.image = VELUIImageMake(@"ic_check_box");
    model.selectImage = VELUIImageMake(@"ic_check_box_sel");
    return model;
}
@end
