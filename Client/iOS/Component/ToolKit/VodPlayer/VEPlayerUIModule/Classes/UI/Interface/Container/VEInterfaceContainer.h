// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
@protocol VEInterfaceElementDataSource;
@protocol VEInterfaceElementDescription;

@interface VEInterfaceContainer : UIView

- (instancetype)initWithScene:(id<VEInterfaceElementDataSource>)scene;

@end
