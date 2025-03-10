// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
@protocol MDInterfaceElementDataSource;
@protocol MDInterfaceElementDescription;

@interface MDInterfaceVisual : UIView

- (instancetype)initWithScene:(id<MDInterfaceElementDataSource>)scene;

@end
