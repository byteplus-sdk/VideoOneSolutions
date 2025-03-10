// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDPlayerGestureService.h"
#import "MDPlayerGestureWrapper.h"
#import "MDPlayerGestureDisableHandler.h"

@interface MDPlayerGestureService() <UIGestureRecognizerDelegate>

@property (nonatomic, strong) MDPlayerGestureWrapper *singleTapGestureWrapper;
@property (nonatomic, strong) MDPlayerGestureWrapper *doubleTapGestureWrapper;
@property (nonatomic, strong) MDPlayerGestureWrapper *panGestureWrapper;
@property (nonatomic, strong) MDPlayerGestureWrapper *longPressGestureWrapper;
@property (nonatomic, strong) MDPlayerGestureWrapper *pinchGestureWrapper;

@end

@implementation MDPlayerGestureService

- (void)setGestureView:(UIView *)gestureView {
    if(_gestureView == gestureView) {
        return;
    }
    if (_gestureView != nil && _gestureView != gestureView) {
        [self removeGestureView:_gestureView];
    }
    _gestureView = gestureView;
    [gestureView addGestureRecognizer:self.singleTapGestureWrapper.gestureRecognizer];
    [gestureView addGestureRecognizer:self.doubleTapGestureWrapper.gestureRecognizer];
    [gestureView addGestureRecognizer:self.panGestureWrapper.gestureRecognizer];
    [gestureView addGestureRecognizer:self.longPressGestureWrapper.gestureRecognizer];
    [gestureView addGestureRecognizer:self.pinchGestureWrapper.gestureRecognizer];
    [self.singleTapGestureWrapper.gestureRecognizer requireGestureRecognizerToFail:self.doubleTapGestureWrapper.gestureRecognizer];
    self.singleTapGestureWrapper.gestureRecognizer.delaysTouchesBegan = YES;
}

- (void)removeGestureView:(UIView *)gestureView {
    [gestureView removeGestureRecognizer:self.singleTapGestureWrapper.gestureRecognizer];
    [gestureView removeGestureRecognizer:self.doubleTapGestureWrapper.gestureRecognizer];
    [gestureView removeGestureRecognizer:self.panGestureWrapper.gestureRecognizer];
    [gestureView removeGestureRecognizer:self.longPressGestureWrapper.gestureRecognizer];
    [gestureView removeGestureRecognizer:self.pinchGestureWrapper.gestureRecognizer];
}

#pragma mark - Public Mehtod
- (void)addGestureHandler:(id<MDPlayerGestureHandlerProtocol>)handler forType:(MDGestureType)gestureType {
    if (gestureType & MDGestureType_SingleTap) {
        [self.singleTapGestureWrapper addGestureHandler:handler];
    }
    if (gestureType & MDGestureType_DoubleTap) {
        [self.doubleTapGestureWrapper addGestureHandler:handler];
    }
    if (gestureType & MDGestureType_Pan) {
        [self.panGestureWrapper addGestureHandler:handler];
    }
    if (gestureType & MDGestureType_LongPress) {
        [self.longPressGestureWrapper addGestureHandler:handler];
    }
    if (gestureType & MDGestureType_Pinch) {
        [self.pinchGestureWrapper addGestureHandler:handler];
    }
}

- (void)removeGestureHandler:(id<MDPlayerGestureHandlerProtocol>)handler forType:(MDGestureType)gestureType {
    if (gestureType & MDGestureType_SingleTap) {
        [_singleTapGestureWrapper removeGestureHandler:handler];
    }
    if (gestureType & MDGestureType_DoubleTap) {
        [_doubleTapGestureWrapper removeGestureHandler:handler];
    }
    if (gestureType & MDGestureType_Pan) {
        [_panGestureWrapper removeGestureHandler:handler];
    }
    if (gestureType & MDGestureType_LongPress) {
        [_longPressGestureWrapper removeGestureHandler:handler];
    }
    if (gestureType & MDGestureType_Pinch) {
        [_pinchGestureWrapper removeGestureHandler:handler];
    }
}

- (void)removeGestureHandler:(id<MDPlayerGestureHandlerProtocol>)handler {
    [self removeGestureHandler:handler forType:MDGestureType_All];
}

- (id<MDPlayerGestureHandlerProtocol>)disableGestureType:(MDGestureType)gestureType scene:(NSString *)scene {
    NSAssert(scene.length > 0, @"disableGestureType scene is nil ！！！");
    id<MDPlayerGestureHandlerProtocol> disableHandler = [[MDPlayerGestureDisableHandler alloc] initWithGestureType:gestureType scene:scene];
    [self addGestureHandler:disableHandler forType:gestureType];
    return disableHandler;
}

#pragma mark - Setter & Getter
- (MDPlayerGestureWrapper *)singleTapGestureWrapper {
    if (!_singleTapGestureWrapper) {
        _singleTapGestureWrapper = [[MDPlayerGestureWrapper alloc] initWithGestureRecognizer:[[UITapGestureRecognizer alloc] init] gestureType:MDGestureType_SingleTap];
    }
    return _singleTapGestureWrapper;
}

- (MDPlayerGestureWrapper *)doubleTapGestureWrapper {
    if (!_doubleTapGestureWrapper) {
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] init];
        gesture.numberOfTapsRequired = 2;
        _doubleTapGestureWrapper = [[MDPlayerGestureWrapper alloc] initWithGestureRecognizer:gesture gestureType:MDGestureType_DoubleTap];
    }
    return _doubleTapGestureWrapper;
}

- (MDPlayerGestureWrapper *)panGestureWrapper {
    if (!_panGestureWrapper) {
        UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] init];
        gesture.delaysTouchesBegan = NO;
        gesture.delaysTouchesEnded = NO;
        _panGestureWrapper = [[MDPlayerGestureWrapper alloc] initWithGestureRecognizer:gesture gestureType:MDGestureType_Pan];
    }
    return _panGestureWrapper;
}

- (MDPlayerGestureWrapper *)longPressGestureWrapper {
    if (!_longPressGestureWrapper) {
        UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] init];
        gesture.numberOfTouchesRequired = 1;
        gesture.minimumPressDuration = 0.5;
        _longPressGestureWrapper = [[MDPlayerGestureWrapper alloc] initWithGestureRecognizer:gesture gestureType:MDGestureType_LongPress];
    }
    return _longPressGestureWrapper;
}

- (MDPlayerGestureWrapper *)pinchGestureWrapper {
    if (!_pinchGestureWrapper) {
        UIPinchGestureRecognizer *gesture = [[UIPinchGestureRecognizer alloc] init];
        _pinchGestureWrapper = [[MDPlayerGestureWrapper alloc] initWithGestureRecognizer:gesture gestureType:MDGestureType_Pinch];
    }
    return _pinchGestureWrapper;
}

@end
