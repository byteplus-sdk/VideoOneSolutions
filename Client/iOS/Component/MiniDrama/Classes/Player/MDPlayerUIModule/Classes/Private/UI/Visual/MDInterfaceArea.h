// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "UIView+MDElementDescripition.h"
@protocol MDInterfaceElementDescription;

@interface MDInterfaceArea : UIView

@property (nonatomic, assign) NSInteger zIndex;

- (instancetype)initWithElements:(NSArray<id<MDInterfaceElementDescription>> *)elements;

- (BOOL)isEnableZone:(CGPoint)point;

- (void)invalidateLayout;

// deprecated

- (void)screenAction;

- (void)show:(BOOL)show animated:(BOOL)animated;

@end
