//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VEInterfaceCommentViewDescription : NSObject

@property (nonatomic, assign) UILayoutConstraintAxis axis;

@property (nonatomic, assign) NSTimeInterval animationDuration;

@property (nonatomic, assign) CGSize contentSize;

@property (nonatomic, copy) UIColor *bgColor;

@property (nonatomic, assign) UIRectCorner bgRoundingCorners;

@property (nonatomic, assign) CGSize bgCornerRadii;

@property (nonatomic, assign) CGFloat headerHeight;

@property (nonatomic, copy) UIColor *titleColor;

@property (nonatomic, assign) NSTextAlignment titleTextAlignment;

@property (nonatomic, copy) UIColor *topSeparatorColor;

@property (nonatomic, copy) NSString *cellReuseIdentifier;

@property (nonatomic, assign) CGFloat inputHeight;

@property (nonatomic, copy) UIColor *inputBgColor;

@property (nonatomic, copy) UIColor *inputActiveBgColor;

@property (nonatomic, copy) UIColor *inputSeparatorColor;

@property (nonatomic, copy) UIColor *inputBorderColor;

@property (nonatomic, copy) UIColor *inputTextColor;

@property (nonatomic, copy) UIColor *inputPlaceholderColorColor;

+ (instancetype)horizontalStyle;

+ (instancetype)verticalStyle;

+ (instancetype)descriptionWithAxis:(UILayoutConstraintAxis)axis;

@end

NS_ASSUME_NONNULL_END
