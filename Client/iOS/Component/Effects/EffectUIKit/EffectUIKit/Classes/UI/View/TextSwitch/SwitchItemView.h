// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef SwitchItemView_h
#define SwitchItemView_h

#import <UIKit/UIKit.h>

@interface SwitchItemConfig : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSArray<NSString *> *items;
@property (nonatomic, assign) NSInteger selectIndex;
@property (nonatomic, copy) NSString *key;

- (instancetype)initWithTitle:(NSString *)title items:(NSArray *)items selectIndex:(NSInteger)index;
- (instancetype)initWithTitle:(NSString *)title items:(NSArray *)items selectIndex:(NSInteger)index key:(NSString *)key;

@end

@class SwitchItemView;
@protocol SwitchItemViewDelegate <NSObject>

- (void)switchItemView:(SwitchItemView *)view didSelect:(NSInteger)index;

@end

@interface SwitchItemView : UIView

@property (nonatomic, weak) id<SwitchItemViewDelegate> delegate;

@property (nonatomic, strong) SwitchItemConfig *config;

@end

#endif /* SwitchItemView_h */
