// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef SingleSwitchView_h
#define SingleSwitchView_h

#import <UIKit/UIKit.h>

@interface SingleSwitchConfig : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) BOOL isOn;
@property (nonatomic, copy) NSString *key;

- (instancetype)initWithTitle:(NSString *)title isOn:(BOOL)isOn;
- (instancetype)initWithTitle:(NSString *)title isOn:(BOOL)isOn key:(NSString *)key;

@end

@class SingleSwitchView;
@protocol SingleSwitchViewDelegate <NSObject>

- (void)switchView:(SingleSwitchView *)view isOn:(BOOL)isOn;

@end

@interface SingleSwitchView : UIView

@property (nonatomic, weak) id<SingleSwitchViewDelegate> delegate;
@property (nonatomic, strong) SingleSwitchConfig *config;

@end

#endif /* SingleSwitchView_h */
