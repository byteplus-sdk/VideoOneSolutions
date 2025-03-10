// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef TextSwitchView_h
#define TextSwitchView_h

#import <UIKit/UIKit.h>
#import "TextSwitchItemView.h"

@interface TextSwitchView : UIView

@property (nonatomic, weak) id<TextSwitchItemViewDelegate> delegate;
@property (nonatomic, strong) NSArray<TextSwitchItem *> *items;
@property (nonatomic, strong) TextSwitchItem *selectItem;

@end

#endif /* TextSwithView_h */
