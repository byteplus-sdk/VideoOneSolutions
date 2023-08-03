// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LiveSettingSingleSelectView : UIView

- (instancetype)initWithTitle:(NSString *)title;

@property (nonatomic, copy) void (^itemClickBlock)(void);

@property (nonatomic, copy) NSString *valueString;

@end

NS_ASSUME_NONNULL_END
