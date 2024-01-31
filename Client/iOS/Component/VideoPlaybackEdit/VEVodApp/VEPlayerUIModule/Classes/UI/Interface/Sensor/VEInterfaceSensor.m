// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEInterfaceSensor.h"
#import "VEEventConst.h"
#import "VEEventTimer.h"
#import "VEInterfaceElementDescription.h"
#import "VEInterfaceProtocol.h"
#import "VEVerticalProgressSlider.h"
#import <Masonry/Masonry.h>

NSString *const VEUIEventVolumeIncrease = @"VEUIEventVolumeIncrease";

NSString *const VEUIEventBrightnessIncrease = @"VEUIEventBrightnessIncrease";

NSString *const VEPlayEventProgressValueIncrease = @"VEPlayEventProgressValueIncrease";

NSString *const VEUIEventResetAutoHideController = @"VEUIEventResetAutoHideController";

static inline CGFloat VEDampValueUnit(void) {
    return UIScreen.mainScreen.bounds.size.width / 5.0;
}

const CGFloat VECheckSlideValue = 13.0;

const CGFloat lockTimeinterval = 5.0;

@interface VEInterfaceSensor ()

@property (nonatomic, weak) id<VEInterfaceElementDataSource> scene;

@property (nonatomic, assign) CGPoint beginPoint;

@property (nonatomic, assign) CGFloat beginValue;

@property (nonatomic, assign) BOOL isMoving;

@property (nonatomic, assign) BOOL isMovingVertically;

@property (nonatomic, assign) BOOL isMovingLeftSide;

@property (nonatomic, strong) NSMutableSet *elementGestures;

@property (nonatomic, strong) VEEventTimer *timer;

@property (nonatomic, assign) NSTimeInterval tapEndTime;

@end

@implementation VEInterfaceSensor

- (instancetype)initWithScene:(id<VEInterfaceElementDataSource>)scene {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self initializeGesture:scene];
    }
    return self;
}

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.timer stop];
}

- (void)initializeGesture:(id<VEInterfaceElementDataSource>)scene {
    self.scene = scene;
    self.elementGestures = [NSMutableSet set];
    for (id<VEInterfaceElementDescription> elementDes in [scene customizedElements]) {
        if (elementDes.type > VEInterfaceElementTypeGesture && elementDes.type < VEInterfaceElementTypeVisual) {
            if (elementDes.type == VEInterfaceElementTypeGestureAutoHideController) {
                self.timer = [[VEEventTimer alloc] init];
                [self.timer addTarget:self action:@selector(clearScreenIfNeed) loopInterval:lockTimeinterval * NSEC_PER_SEC];
                [self performClearScreenLater];
                continue;
            }
            [self.elementGestures addObject:elementDes];
        }
    }
}

- (id<VEInterfaceElementDescription>)elementDesOfType:(VEInterfaceElementType)gestureType {
    for (id<VEInterfaceElementDescription> elementDes in self.elementGestures) {
        if (gestureType == elementDes.type) return elementDes;
    }
    return nil;
}

- (void)clearScreenIfNeed {
    [self.timer stop];
    if ([self.scene.eventPoster currentPlaybackState] == VEPlaybackStatePlaying && ![self.scene.eventPoster screenIsClear]) {
        [self postEvent:VEUIEventClearScreen withObject:@(YES) rightNow:YES];
    }
}

- (void)performClearScreenLater {
    [self.timer stop];
    if ([self.scene.eventPoster currentPlaybackState] == VEPlaybackStatePlaying && ![self.scene.eventPoster screenIsClear]) {
        [self.timer restart];
    }
}

#pragma mark----- Event

- (void)checkEventTouchBegan {
    if ([self.scene.eventPoster screenIsLocking]) {
        return;
    }
    NSDictionary *param = @{@"changeValue": @(0), @"touchBegan": @(YES), @"touchEnd": @(NO)};
    if (self.isMovingVertically) {
        VEInterfaceElementType type = self.isMovingLeftSide ? VEInterfaceElementTypeGestureLeftVerticalPan : VEInterfaceElementTypeGestureRightVerticalPan;
        [self postEventOfTouchEntry:type param:param];
        return;
    }
    [self postEventOfTouchEntry:VEInterfaceElementTypeGestureHorizontalPan param:param];
}

- (void)checkEventTouchEnd:(CGPoint)touchPoint {
    [self.timer restart];
    if (!self.isMoving || CGPointEqualToPoint(self.beginPoint, touchPoint)) {
        [self chekEventTapEnd:touchPoint];
        [self resetResponderStatus];
        return;
    }
    CGFloat movedX = touchPoint.x - self.beginPoint.x;
    CGFloat movedY = touchPoint.y - self.beginPoint.y;
    [self checkEventByMovedX:movedX movedY:movedY touchEnd:YES];
    [self resetResponderStatus];
}

- (void)checkEventByMovedX:(CGFloat)movedX movedY:(CGFloat)movedY touchEnd:(BOOL)end {
    if (!self.isMoving || [self.scene.eventPoster screenIsLocking]) {
        return;
    }
    if (self.isMovingVertically) {
        CGFloat changeValue = (self.beginValue - movedY) / VEDampValueUnit();
        self.beginValue = movedY;
        VEInterfaceElementType type = self.isMovingLeftSide ? VEInterfaceElementTypeGestureLeftVerticalPan : VEInterfaceElementTypeGestureRightVerticalPan;
        NSDictionary *param = @{@"changeValue": @(changeValue), @"touchBegan": @(NO), @"touchEnd": @(end)};
        [self postEventOfTouchEntry:type param:param];
        return;
    }
    CGFloat changeValue = (movedX - self.beginValue) / (VEDampValueUnit() * 2);
    self.beginValue = movedX;
    NSDictionary *param = @{@"changeValue": @(changeValue), @"touchBegan": @(NO), @"touchEnd": @(end)};
    [self postEventOfTouchEntry:VEInterfaceElementTypeGestureHorizontalPan param:param];
}

- (void)postEventOfTouchEntry:(VEInterfaceElementType)type param:(id)obj {
    id<VEInterfaceElementDescription> elementDes = [self elementDesOfType:type];
    if (!elementDes) {
        return;
    }
    NSString *event = elementDes.elementAction(self);
    if (![self isAbleToRespond:event]) {
        return;
    }
    if ([event isEqualToString:VEUIEventClearScreen]) {
        obj = @(![self.scene.eventPoster screenIsClear]);
    }
    if (elementDes.elementNotify) {
        elementDes.elementNotify(self, event, obj);
        return;
    }
    [self.scene.eventMessageBus postEvent:event withObject:obj rightNow:YES];
}

- (void)postEvent:(NSString *)event withObject:(id)object rightNow:(BOOL)now {
    if (![self isAbleToRespond:event]) {
        return;
    }
    [self.scene.eventMessageBus postEvent:event withObject:object rightNow:now];
}

- (BOOL)isAbleToRespond:(NSString *)event {
    // ignore all events exception for 'screen clearing' when screen is locking
    return event && ([event isEqualToString:VEUIEventClearScreen] || ![self.scene.eventPoster screenIsLocking]);
}

- (void)resetResponderStatus {
    self.beginPoint = CGPointZero;
    self.isMoving = NO;
    self.isMovingVertically = NO;
    self.beginValue = 0.0;
}

#pragma mark - Tap Event
- (void)chekEventTapEnd:(CGPoint)touchPoint {
    NSTimeInterval endTime = CFAbsoluteTimeGetCurrent() * 1000;
    if (endTime - self.tapEndTime > 250) {
        [self performSelector:@selector(singleTapEvent:) withObject:[NSValue valueWithCGPoint:touchPoint] afterDelay:0.3];
    } else {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self doubleTapEvent:[NSValue valueWithCGPoint:touchPoint]];
    }
    self.tapEndTime = endTime;
}

- (void)singleTapEvent:(NSValue *)touchPoint {
    if (self.scene.deactive) {
        return;
    }
    [self postEventOfTouchEntry:VEInterfaceElementTypeGestureSingleTap param:@{
        @"locationInView": self,
        @"location": touchPoint
    }];
}

- (void)doubleTapEvent:(NSValue *)touchPoint {
    if (self.scene.deactive) {
        return;
    }
    [self postEventOfTouchEntry:VEInterfaceElementTypeGestureDoubleTap param:@{
        @"locationInView": self,
        @"location": touchPoint
    }];
}

#pragma mark----- UIResponder

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.timer stop];
    CGPoint touchPoint = [[touches anyObject] locationInView:UIApplication.sharedApplication.keyWindow];
    self.beginPoint = touchPoint;
    self.isMoving = NO;
    self.isMovingVertically = NO;
    self.beginValue = 0.0;
    // left: x < half screen. right: x > half screen.
    if (touchPoint.x < UIScreen.mainScreen.bounds.size.width / 2.0) {
        self.isMovingLeftSide = YES;
    } else {
        self.isMovingLeftSide = NO;
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [[touches anyObject] locationInView:UIApplication.sharedApplication.keyWindow];
    CGFloat movedX = touchPoint.x - self.beginPoint.x;
    CGFloat movedY = touchPoint.y - self.beginPoint.y;
    if (!self.isMoving && (ABS(movedX) > VECheckSlideValue || ABS(movedY) > VECheckSlideValue)) {
        self.isMoving = YES;
        if (ABS(movedY) >= ABS(movedX)) {
            self.beginValue = movedY;
            self.isMovingVertically = YES;
        } else {
            self.beginValue = movedX;
            self.isMovingVertically = NO;
        }
        [self checkEventTouchBegan];
    }
    [self checkEventByMovedX:movedX movedY:movedY touchEnd:NO];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [[touches anyObject] locationInView:UIApplication.sharedApplication.keyWindow];
    [self checkEventTouchEnd:touchPoint];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [[touches anyObject] locationInView:UIApplication.sharedApplication.keyWindow];
    [self checkEventTouchEnd:touchPoint];
}

@end
