// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef VELGestureManager_h
#define VELGestureManager_h

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, VELTouchEvent) {
    VELTouchEventBegan,
    VELTouchEventMoved,
    VELTouchEventStationary,
    VELTouchEventEnded,
    VELTouchEventCanceled,
};

typedef NS_ENUM(NSInteger, VELGestureType) {
    VELGestureTypeTap,
    VELGestureTypePan,
    VELGestureTypeRotate,
    VELGestureTypeScale,
    VELGestureTypeLongPress,
    VELGestureTypeDoubleTap,
};

@class VELGestureManager;
@protocol VELGestureDelegate <NSObject>
/// @param manager VELGestureManager
- (void)gestureManager:(VELGestureManager *)manager onTouchEvent:(VELTouchEvent)event x:(CGFloat)x y:(CGFloat)y force:(CGFloat)force majorRadius:(CGFloat)majorRadius pointerId:(NSInteger)pointerId pointerCount:(NSInteger)pointerCount;
/// @param manager VELGestureManager
/// @param dx dx
/// @param dy dy
- (void)gestureManager:(VELGestureManager *)manager onGesture:(VELGestureType)gesture x:(CGFloat)x y:(CGFloat)y dx:(CGFloat)dx dy:(CGFloat)dy factor:(CGFloat)factor;
@optional
- (void)gestureManagerDidBegin:(VELGestureManager *)manager onGesture:(VELGestureType)gesture;
- (void)gestureManagerDidEnd:(VELGestureManager *)manager onGesture:(VELGestureType)gesture;
- (BOOL)gestureManager:(VELGestureManager *)manager shouldReceiveTouch:(UITouch *)touch;
@end
@interface VELGestureManager : NSObject

@property (nonatomic, weak) id<VELGestureDelegate> delegate;
@property (nonatomic, assign, getter=isEnable) BOOL enable;
@property (nonatomic, assign, getter=isSkipEdge) BOOL skipEdge;
@property (nonatomic, assign) CGFloat edgeWidth;
@property (nonatomic, assign) BOOL receiveAllTouch;
- (void)attachView:(UIView *)view;
- (void)unAttachView:(UIView *)view;

@end

#endif /* VELGestureManager_h */
