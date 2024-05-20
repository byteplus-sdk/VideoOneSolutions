// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VELFocusView : UIView
@property(nonatomic, copy) void (^sunValueChanged)(CGFloat sunValue);
@property(nonatomic, copy) void (^wbValueChanged)(CGFloat wbValue);
@property(nonatomic, assign) CGFloat sunValue;
@property(nonatomic, assign) CGFloat wbValue;
@property(nonatomic, assign) BOOL showSunView;
@property(nonatomic, assign) BOOL showWBView;
- (void)updateSunValue:(CGFloat)value;
- (void)updateWBValue:(CGFloat)value;
@end

NS_ASSUME_NONNULL_END
