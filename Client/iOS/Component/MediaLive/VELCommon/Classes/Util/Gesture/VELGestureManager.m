// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELGestureManager.h"
#import "VELGestureRecognizer.h"

@interface VELGestureManager () <UIGestureRecognizerDelegate, VELGestureRecognizerDelegate>

@property (nonatomic, strong, readwrite) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, strong, readwrite) UITapGestureRecognizer *doubleTapRecognizer;
@property (nonatomic, strong, readwrite) UIPinchGestureRecognizer *pinchRecognizer;
@property (nonatomic, strong, readwrite) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, strong, readwrite) UIRotationGestureRecognizer *rotateRecognizer;
@property (nonatomic, strong, readwrite) UILongPressGestureRecognizer *longPressRecognizer;
@property (nonatomic, strong, readwrite) VELGestureRecognizer *gestureRecognizer;

@property (nonatomic, assign) CGPoint oldPoint;

@property (nonatomic, weak) UIView *view;

@end


@implementation VELGestureManager {
    CGFloat         _preScale;
    CGFloat         _preRotate;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _enable = YES;
        _skipEdge = YES;
        _edgeWidth = 10;
        _preScale = 1.f;
        _preRotate = 0.f;
        _oldPoint = (CGPoint){0, 0};
    }
    return self;
}

- (void)attachView:(UIView *)view {
    self.view = view;
    [view addGestureRecognizer:self.tapRecognizer];
    [view addGestureRecognizer:self.doubleTapRecognizer];
    [view addGestureRecognizer:self.panRecognizer];
    [view addGestureRecognizer:self.pinchRecognizer];
    [view addGestureRecognizer:self.rotateRecognizer];
    [view addGestureRecognizer:self.longPressRecognizer];
    [view addGestureRecognizer:self.gestureRecognizer];
}
- (void)unAttachView:(UIView *)view {
    self.view = nil;
    [view removeGestureRecognizer:self.tapRecognizer];
    [view removeGestureRecognizer:self.doubleTapRecognizer];
    [view removeGestureRecognizer:self.panRecognizer];
    [view removeGestureRecognizer:self.pinchRecognizer];
    [view removeGestureRecognizer:self.rotateRecognizer];
    [view removeGestureRecognizer:self.longPressRecognizer];
    [view removeGestureRecognizer:self.gestureRecognizer];
}
- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer {
    VELGestureType gestureType = VELGestureTypeTap;
    if (gestureRecognizer == self.tapRecognizer) {
        gestureType = VELGestureTypeTap;
    } else if (gestureRecognizer == self.doubleTapRecognizer) {
        gestureType = VELGestureTypeDoubleTap;
    } else if (gestureRecognizer == self.panRecognizer) {
        gestureType = VELGestureTypePan;
    } else if (gestureRecognizer == self.pinchRecognizer) {
        gestureType = VELGestureTypeScale;
    } else if (gestureRecognizer == self.rotateRecognizer) {
        gestureType = VELGestureTypeRotate;
    } else if (gestureRecognizer == self.longPressRecognizer) {
        gestureType = VELGestureTypeLongPress;
    }
    CGPoint point = [gestureRecognizer locationInView:self.view];
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        _oldPoint = point;
        if ([self.delegate respondsToSelector:@selector(gestureManagerDidBegin:onGesture:)]) {
            [self.delegate gestureManagerDidBegin:self onGesture:(gestureType)];
        }
    }
    
    if (gestureRecognizer == self.tapRecognizer) {
        [self.delegate gestureManager:self onGesture:gestureType x:point.x y:point.y dx:0.f dy:0.f factor:0.f];
    } else if (gestureRecognizer == self.doubleTapRecognizer) {
        [self.delegate gestureManager:self onGesture:gestureType x:point.x y:point.y dx:0.f dy:0.f factor:0.f];
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded
        || gestureRecognizer.state == UIGestureRecognizerStateCancelled
        || gestureRecognizer.state == UIGestureRecognizerStateFailed) {
        if ([self.delegate respondsToSelector:@selector(gestureManagerDidEnd:onGesture:)]) {
            [self.delegate gestureManagerDidEnd:self onGesture:gestureType];
        }
        _oldPoint = (CGPoint){0, 0};
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        if (gestureRecognizer == self.panRecognizer) {
            [self.delegate gestureManager:self onGesture:gestureType x:point.x y:point.y dx:point.x-_oldPoint.x dy:point.y-_oldPoint.y factor:1];
            _oldPoint = point;
        } else if (gestureRecognizer == self.pinchRecognizer) {
            CGFloat scale = self.pinchRecognizer.scale;
            [self.delegate gestureManager:self onGesture:gestureType x:scale / _preScale y:0.f dx:0.f dy:0.f factor:3.f];
            _preScale = scale;
        } else if (gestureRecognizer == self.rotateRecognizer) {
            CGFloat rotate = self.rotateRecognizer.rotation;
            [self.delegate gestureManager:self onGesture:gestureType x:rotate - _preRotate y:0.f dx:0.f dy:0.f factor:6.f];
            _preRotate = rotate;
        } else if (gestureRecognizer == self.longPressRecognizer) {
            [self.delegate gestureManager:self onGesture:gestureType x:point.x y:point.y dx:0.f dy:0.f factor:0.f];
        }
    }
}

#pragma mark VELGestureRecognizerDelegate
- (void)gestureRecognizer:(VELGestureRecognizer *)recognizer onTouchEvent:(NSSet<UITouch *> *)touches {
    NSInteger pointerCount = touches.count;
    for (int i = 0; i < touches.count; ++i) {
        UITouch *touch = touches.allObjects[i];
        int pointerId = (int)[touch hash];
        CGPoint point = [touch locationInView:self.view];
        CGFloat force = touch.force;
        CGFloat majorRadius = touch.majorRadius;
        switch (touch.phase) {
            case UITouchPhaseBegan:
                [self.delegate gestureManager:self onTouchEvent:VELTouchEventBegan x:point.x y:point.y force:force majorRadius:majorRadius pointerId:pointerId pointerCount:pointerCount];
                [self vel_touchBegan];
                break;
            case UITouchPhaseMoved:
                [self.delegate gestureManager:self onTouchEvent:VELTouchEventMoved x:point.x y:point.y force:force majorRadius:majorRadius pointerId:pointerId pointerCount:pointerCount];
                break;
            case UITouchPhaseStationary:
                [self.delegate gestureManager:self onTouchEvent:VELTouchEventStationary x:point.x y:point.y force:force majorRadius:majorRadius pointerId:pointerId pointerCount:pointerCount];
                break;
            case UITouchPhaseEnded:
                [self.delegate gestureManager:self onTouchEvent:VELTouchEventEnded x:point.x y:point.y force:force majorRadius:majorRadius pointerId:pointerId pointerCount:pointerCount];
                [self vel_touchEnded];
                break;
            case UITouchPhaseCancelled:
                [self.delegate gestureManager:self onTouchEvent:VELTouchEventCanceled x:point.x y:point.y force:force majorRadius:majorRadius pointerId:pointerId pointerCount:pointerCount];
                [self vel_touchEnded];
                break;
            default:
                break;
        }
    }
}

#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    BOOL shoudeRecive = touch.view == self.view;
    if (self.delegate && [self.delegate respondsToSelector:@selector(gestureManager:shouldReceiveTouch:)]) {
        shoudeRecive &= [self.delegate gestureManager:self shouldReceiveTouch:touch];
    }
    
    if (!self.receiveAllTouch && touch.view != self.view) {
        return NO;
    }
    if (_skipEdge) {
        CGPoint point = [touch locationInView:self.view];
        if (point.x < _edgeWidth) {
            return NO;
        }
    }
    return _enable ? shoudeRecive : NO;
}

#pragma mark private
- (void)vel_touchBegan {
    _preScale = 1.f;
    _preRotate = 0.f;
}

- (void)vel_touchEnded {
    
}

#pragma mark getter
- (UITapGestureRecognizer *)tapRecognizer {
    if (_tapRecognizer == nil) {
        _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        _tapRecognizer.delegate = self;
    }
    return _tapRecognizer;
}

- (UITapGestureRecognizer *)doubleTapRecognizer {
    if (_doubleTapRecognizer == nil) {
        _doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        _doubleTapRecognizer.delegate = self;
        _doubleTapRecognizer.numberOfTapsRequired = 2;
    }
    return _doubleTapRecognizer;
}
- (UIPanGestureRecognizer *)panRecognizer {
    if (_panRecognizer == nil) {
        _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        _panRecognizer.delegate = self;
    }
    return _panRecognizer;
}

- (UIPinchGestureRecognizer *)pinchRecognizer {
    if (_pinchRecognizer == nil) {
        _pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        _pinchRecognizer.delegate = self;
    }
    return _pinchRecognizer;
}

- (UIRotationGestureRecognizer *)rotateRecognizer {
    if (_rotateRecognizer == nil) {
        _rotateRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    }
    return _rotateRecognizer;
}

- (UILongPressGestureRecognizer *)longPressRecognizer {
    if (_longPressRecognizer == nil) {
        _longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        _longPressRecognizer.delegate = self;
    }
    return _longPressRecognizer;
}

- (VELGestureRecognizer *)gestureRecognizer {
    if (_gestureRecognizer == nil) {
        _gestureRecognizer = [[VELGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        _gestureRecognizer.recognizerDelegate = self;
        _gestureRecognizer.delegate = self;
    }
    return _gestureRecognizer;
}

@end
