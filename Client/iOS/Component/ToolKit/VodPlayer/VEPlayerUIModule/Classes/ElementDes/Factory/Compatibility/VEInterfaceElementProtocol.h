// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "NSObject+ToElementDescription.h"
#import "VEInterfaceElementDescription.h"

@protocol VEInterfaceElementProtocol <NSObject>

@optional

@property (nonatomic, copy) NSString *elementID;

@property (nonatomic, assign) VEInterfaceElementType type;

- (id)elementAction:(id)mayElementView;

- (void)elementNotify:(id)mayElementView key:(NSString *)key obj:(id)obj;

- (id)elementSubscribe:(id)mayElementView;

- (void)elementWillLayout:(UIView *)elementView elementGroup:(NSSet<UIView *> *)elementGroup groupContainer:(UIView *)groupContainer;

- (void)elementDisplay:(UIView *)view;

@end
