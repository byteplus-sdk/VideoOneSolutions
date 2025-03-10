// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDInterfaceElementDescription.h"
#import "NSObject+ToElementDescription.h"

@protocol MDInterfaceElementProtocol <NSObject>

@optional

@property (nonatomic, copy) NSString *elementID;

@property (nonatomic, assign) MDInterfaceElementType type;

- (id)elementAction:(id)mayElementView;

- (void)elementNotify:(id)mayElementView :(NSString *)key :(id)obj;

- (id)elementSubscribe:(id)mayElementView;

- (void)elementWillLayout:(UIView *)elementView :(NSSet<UIView *> *)elementGroup :(UIView *)groupContainer;

- (void)elementDisplay:(UIView *)view;

@end
