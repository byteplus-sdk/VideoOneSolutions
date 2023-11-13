// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
@protocol VEInterfaceElementDataSource;
@protocol VEInterfaceElementDescription;

@interface VEInterfaceVisual : UIView

- (instancetype)initWithScene:(id<VEInterfaceElementDataSource>)scene;

@end
