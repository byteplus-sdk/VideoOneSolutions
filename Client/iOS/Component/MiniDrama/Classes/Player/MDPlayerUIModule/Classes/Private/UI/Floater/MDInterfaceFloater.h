// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
@protocol MDInterfaceElementDataSource;
@protocol MDInterfaceElementDescription;

@protocol MDInterfaceFloaterPresentProtocol <NSObject>

- (CGRect)enableZone;

- (void)show:(BOOL)show;

@end

@interface MDInterfaceFloater : UIControl

- (instancetype)initWithScene:(id<MDInterfaceElementDataSource>)scene;

@end
