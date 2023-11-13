// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "UIView+VEElementDescripition.h"
@protocol VEInterfaceElementDescription;

@interface VEInterfaceArea : UIView

@property (nonatomic, assign) NSInteger zIndex;

- (instancetype)initWithElements:(NSArray<id<VEInterfaceElementDescription>> *)elements;

- (BOOL)isEnableZone:(CGPoint)point;

- (void)invalidateLayout;

- (void)show:(BOOL)show animated:(BOOL)animated;

@end
