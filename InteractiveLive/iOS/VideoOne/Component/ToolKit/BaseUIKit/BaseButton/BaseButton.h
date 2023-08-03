// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ButtonStatus) {
    ButtonStatusNone,
    ButtonStatusActive,
    ButtonStatusIng,
    ButtonStatusIllegal,
};

@interface BaseButton : UIButton

@property (nonatomic, assign) ButtonStatus status;

- (void)bingImage:(UIImage *)image status:(ButtonStatus)status;

- (void)bingFont:(UIFont *)font status:(ButtonStatus)status;

@end

NS_ASSUME_NONNULL_END
