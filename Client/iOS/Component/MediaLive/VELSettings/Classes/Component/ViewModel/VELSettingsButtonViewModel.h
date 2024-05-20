// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELSettingsBaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, VELImagePosition) {
    VELImagePositionTop,
    VELImagePositionLeft,
    VELImagePositionBottom,
    VELImagePositionRight
};

@interface VELSettingsButtonViewModel : VELSettingsBaseViewModel
@property (nonatomic, assign) UIViewContentMode contentMode;
@property (nonatomic, assign) UIControlContentHorizontalAlignment alignment;
@property (nonatomic, assign) VELImagePosition imagePosition;
@property (nonatomic, assign) BOOL userInteractionEnabled;
@property (nonatomic, strong) NSMutableDictionary <NSAttributedStringKey, id> *titleAttributes;

@property (nonatomic, strong) NSMutableDictionary <NSAttributedStringKey, id> *selectTitleAttributes;
@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy, nullable) NSString *selectTitle;
@property (nonatomic, strong, nullable) UIImage *image;
@property (nonatomic, strong, nullable) UIImage *selectImage;
@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, assign) CGFloat spacingBetweenImageAndTitle;
@property (nonatomic, assign) BOOL showPoint;
@property (nonatomic, assign) CGFloat spacingBetweenImageTitleAndPoint;
@property (nonatomic, assign) CGSize pointSize;
@property (nonatomic, strong) UIColor *pointColor;
@property (nonatomic, strong, nullable) UIImage *rightAccessory;
@property (nonatomic, assign) CGSize accessorySize;
+ (instancetype)modelWithImage:(UIImage *)image
                         title:(NSString *)title
                rightAccessory:(UIImage *)rightAccessory;

+ (instancetype)modelWithTitle:(NSString *)title;

+ (instancetype)modelWithTitle:(NSString *)title
                        action:(void (^_Nullable)(VELSettingsButtonViewModel *model, NSInteger index))action;

+ (instancetype)checkBoxModelWithTitle:(NSString *)title
                                action:(void (^_Nullable)(VELSettingsButtonViewModel *model, NSInteger index))action;
@end

NS_ASSUME_NONNULL_END
