// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef BubbleTipManager_h
#define BubbleTipManager_h

#import <UIKit/UIKit.h>

@interface BubbleTipManager : NSObject

@property (nonatomic, strong) UIView *container;

@property (nonatomic, assign) int topMargin;


- (instancetype)initWithContainer:(UIView *)container topMargin:(int)topMargin;


- (void)showBubble:(NSString *)title desc:(NSString *)desc duration:(NSTimeInterval)duration;

@end

#endif /* BubbleTipManager_h */
