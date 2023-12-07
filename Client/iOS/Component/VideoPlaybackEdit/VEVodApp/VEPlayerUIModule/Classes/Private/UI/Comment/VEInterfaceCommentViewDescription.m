//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "VEInterfaceCommentViewDescription.h"
#import "VEInterfaceCommentCell.h"

@implementation VEInterfaceCommentViewDescription

+ (instancetype)horizontalStyle {
    VEInterfaceCommentViewDescription *description = [VEInterfaceCommentViewDescription new];
    description.axis = UILayoutConstraintAxisHorizontal;
    description.animationDuration = 0.0;
    CGFloat screenHeight = MAX([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    CGFloat screenWidth = MIN([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    description.contentSize = CGSizeMake(ceil(screenHeight / 812.0 * 360.0), ceil(screenWidth - 16));
    description.bgColor = [UIColor clearColor];
    description.bgRoundingCorners = UIRectCornerAllCorners;
    description.bgCornerRadii = CGSizeMake(8, 8);
    description.headerHeight = 48;
    description.titleColor = [UIColor colorWithRed:0.92 green:0.93 blue:0.94 alpha:1];
    description.titleTextAlignment = NSTextAlignmentNatural;
    description.topSeparatorColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.04];
    description.cellReuseIdentifier = VEInterfaceCommentCelDarkID;
    description.inputHeight = 52;
    description.inputBgColor = [UIColor clearColor];
    description.inputActiveBgColor = [UIColor colorWithRed:0.08 green:0.08 blue:0.08 alpha:0.85];
    description.inputSeparatorColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.04];
    description.inputBorderColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.12];
    description.inputTextColor = [UIColor colorWithRed:0.92 green:0.93 blue:0.94 alpha:1];
    description.inputPlaceholderColorColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.9];
    return description;
}

+ (instancetype)verticalStyle {
    VEInterfaceCommentViewDescription *description = [VEInterfaceCommentViewDescription new];
    description.axis = UILayoutConstraintAxisVertical;
    description.animationDuration = 0.25;
    CGFloat screenHeight = MAX([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    CGFloat screenWidth = MIN([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    description.contentSize = CGSizeMake(screenWidth, ceil(screenHeight / 812.0 * 559.0));
    description.bgColor = [UIColor whiteColor];
    description.bgRoundingCorners = UIRectCornerTopLeft | UIRectCornerTopRight;
    description.bgCornerRadii = CGSizeMake(4, 4);
    description.headerHeight = 52;
    description.titleColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.06 alpha:1];
    description.titleTextAlignment = NSTextAlignmentCenter;
    description.topSeparatorColor = [UIColor colorWithRed:0.09 green:0.09 blue:0.14 alpha:0.2];
    description.cellReuseIdentifier = VEInterfaceCommentCelLightID;
    description.inputHeight = 52;
    description.inputBgColor = [UIColor whiteColor];
    description.inputActiveBgColor = [UIColor whiteColor];
    description.inputSeparatorColor = [UIColor colorWithRed:0.09 green:0.09 blue:0.14 alpha:0.1];
    description.inputBorderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.04];
    description.inputTextColor = [UIColor colorWithRed:0.01 green:0.03 blue:0.08 alpha:1];
    description.inputPlaceholderColorColor = [UIColor colorWithRed:0.64 green:0.65 blue:0.68 alpha:1];
    return description;
}

+ (instancetype)descriptionWithAxis:(UILayoutConstraintAxis)axis {
    if (axis == UILayoutConstraintAxisVertical) {
        return [self verticalStyle];
    }
    return [self horizontalStyle];
}

@end
