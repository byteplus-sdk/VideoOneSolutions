// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef MDPlayerGestureHandlerProtocol_h
#define MDPlayerGestureHandlerProtocol_h

#import <UIKit/UIKit.h>
#import "MDPlayerInteractionDefine.h"

/**
 * @locale zh
 * @type api
 * @brief 处理手势Hnadler协议
 */
@protocol MDPlayerGestureHandlerProtocol <NSObject>

@optional
/**
 * @locale zh
 * @type api
 * @brief 当多个handler都可以相应同一手势时，需要根据优先级选择一个，默认为0
 * @param gestureType 手势类型
 */
- (NSInteger)handlerPriorityForGestureType:(MDGestureType)gestureType;

/**
 * @locale zh
 * @type api
 * @brief 是否禁止该手势，默认为NO，增加一个参数当前触摸的位置，便于做更精细化的处理
 * @param gestureRecognizer UIGestureRecognizer 对象
 * @param gestureType 手势类型
 * @param location location
 */
- (BOOL)gestureRecognizerShouldDisable:(UIGestureRecognizer *)gestureRecognizer gestureType:(MDGestureType)gestureType location:(CGPoint)location;

/**
 * @locale zh
 * @type api
 * @brief 是否响应该手势，默认为YES
 * @param gestureRecognizer UIGestureRecognizer 对象
 * @param gestureType 手势类型
 */
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer gestureType:(MDGestureType)gestureType;

/**
 * @locale zh
 * @type api
 * @brief 手势处理回调
 * @param gestureRecognizer UIGestureRecognizer 对象
 * @param gestureType 手势类型
 */
- (void)handleGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer gestureType:(MDGestureType)gestureType;

@end

#endif /* MDPlayerGestureHandlerProtocol_h */
