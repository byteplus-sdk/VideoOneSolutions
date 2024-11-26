// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "BaseIMModel.h"
#import "BaseIMView.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseIMComponent : NSObject

- (instancetype)initWithSuperView:(UIView *)superView;

@property (nonatomic, strong) BaseIMView *baseIMView;

- (void)addIM:(BaseIMModel *)model;

- (void)updaetHidden:(BOOL)isHidden;

- (void)updateUserInteractionEnabled:(BOOL)isEnabled;

- (void)updateRightConstraintValue:(NSInteger)right;

- (void)remakeTopConstraintValue:(NSInteger)top;

- (void)hidden:(BOOL)isHidden;

@end

NS_ASSUME_NONNULL_END
