// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef CompareView_h
#define CompareView_h

#import <UIKit/UIKit.h>

@class CompareView;
@protocol CompareViewDelegate <NSObject>

- (void)effectBaseView:(CompareView *)view onTouchDownCompare:(UIView *)sender;
- (void)effectBaseView:(CompareView *)view onTouchUpCompare:(UIView *)sender;

@end

@interface CompareView : UIView

@property (nonatomic, weak) id<CompareViewDelegate> delegate;

- (instancetype)initWithButtomMargin:(int)bottomMargin;

- (void)updateShowCompare:(BOOL)showCompare;

- (void)updateButtomMargin:(int)bottomMargin delay:(NSTimeInterval)delay;

@end

#endif /* CompareView_h */
