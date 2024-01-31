// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
@protocol VEInterfaceElementDataSource;
@protocol VEInterfaceElementDescription;

@protocol VEInterfaceFloaterPresentProtocol <NSObject>

- (CGRect)enableZone;

- (void)show:(BOOL)show;

@end

@interface VEInterfaceFloater : UIControl

- (instancetype)initWithScene:(id<VEInterfaceElementDataSource>)scene;

@end
