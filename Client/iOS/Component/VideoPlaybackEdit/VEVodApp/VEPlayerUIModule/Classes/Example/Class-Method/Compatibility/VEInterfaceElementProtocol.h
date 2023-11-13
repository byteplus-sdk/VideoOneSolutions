// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEInterfaceElementDescription.h"
#import "NSObject+ToElementDescription.h"

@protocol VEInterfaceElementProtocol <NSObject>

@optional

@property (nonatomic, copy) NSString *elementID;

@property (nonatomic, assign) VEInterfaceElementType type;

- (id)elementAction:(id)mayElementView;

- (void)elementNotify:(id)mayElementView :(NSString *)key :(id)obj;

- (id)elementSubscribe:(id)mayElementView;

- (void)elementWillLayout:(UIView *)elementView :(NSSet<UIView *> *)elementGroup :(UIView *)groupContainer;

- (void)elementDisplay:(UIView *)view;

@end
