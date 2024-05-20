// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef VELGestureRecognizer_h
#define VELGestureRecognizer_h

#import <UIKit/UIGestureRecognizerSubclass.h>

@class VELGestureRecognizer;
@protocol VELGestureRecognizerDelegate <NSObject>

- (void)gestureRecognizer:(VELGestureRecognizer *)recognizer onTouchEvent:(NSSet<UITouch *> *)touches;

@end
@interface VELGestureRecognizer : UIGestureRecognizer

@property (nonatomic, weak) id<VELGestureRecognizerDelegate> recognizerDelegate;

@end

#endif /* VELGestureRecognizer_h */
