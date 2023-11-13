// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEInterfaceSensor.h"
#import "VEEventConst.h"
#import "VEEventTimer.h"
#import "VEInterfaceElementDescription.h"
#import "VEInterfaceProtocol.h"

NSString *const VEUIEventVolumeIncrease = @"VEUIEventVolumeIncrease";

NSString *const VEUIEventBrightnessIncrease = @"VEUIEventBrightnessIncrease";

NSString *const VEPlayEventProgressValueIncrease = @"VEPlayEventProgressValueIncrease";

static inline CGFloat VEDampValueUnit(void) {
    return UIScreen.mainScreen.bounds.size.width / 3.0;
}

const CGFloat VECheckSlideValue = 13.0;

const CGFloat lockTimeinterval = 5.0 + 1.0;

@interface VEInterfaceSensor ()

@property (nonatomic, weak) id<VEInterfaceElementDataSource> scene;

@property (nonatomic, assign) CGPoint beginPoint;

@property (nonatomic, assign) CGFloat beginValue;

@property (nonatomic, assign) BOOL isMoving;

@property (nonatomic, assign) BOOL isMovingVertically;

@property (nonatomic, assign) BOOL isMovingLeftSide;

@property (nonatomic, strong) NSMutableSet *elementGestures;

@end

@implementation VEInterfaceSensor

- (instancetype)initWithScene:(id<VEInterfaceElementDataSource>)scene {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self initializeGesture:scene];
        //        [[VEEventTimer universalTimer] addTarget:self action:@selector(clearScreen) loopInterval:lockTimeinterval * NSEC_PER_SEC];
    }
    return self;
}

- (void)clearScreen {
    [self.scene.eventMessageBus postEvent:VEUIEventClearScreen withObject:@(YES) rightNow:YES];
}

- (void)initializeGesture:(id<VEInterfaceElementDataSource>)scene {
    self.scene = scene;
    [self doubleTapGesture];
    self.elementGestures = [NSMutableSet set];
    for (id<VEInterfaceElementDescription> elementDes in [scene customizedElements]) {
        if (elementDes.type > VEInterfaceElementTypeGesture && elementDes.type < VEInterfaceElementTypeVisual) {
            [self.elementGestures addObject:elementDes];
        }
    }
}

- (void)doubleTapGesture {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapEvent)];
    tap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:tap];
}

- (id<VEInterfaceElementDescription>)elementDesOfType:(VEInterfaceElementType)gestureType {
    for (id<VEInterfaceElementDescription> elementDes in self.elementGestures) {
        if (gestureType == elementDes.type) return elementDes;
    }
    return nil;
}

#pragma mark----- Event

- (void)singleTapEvent {
    [self postEventOfTouchEntry:VEInterfaceElementTypeGestureSingleTap param:nil];
}

- (void)doubleTapEvent {
    [self postEventOfTouchEntry:VEInterfaceElementTypeGestureDoubleTap param:nil];
}

- (void)checkEventTouchBeganByMovedX:(CGFloat)movedX movedY:(CGFloat)movedY {
    if (!self.isMovingVertically) {
        id<VEInterfaceElementDescription> elementDes = [self elementDesOfType:VEInterfaceElementTypeGestureHorizontalPan];
        if (elementDes) {
            NSString *event = elementDes.elementAction(self);
            if (event && [event isEqualToString:VEPlayEventProgressValueIncrease]) {
                [self.scene.eventMessageBus postEvent:VEPlayEventSeeking withObject:@(YES) rightNow:YES];
            }
        }
    }
}

- (void)checkEventByMovedX:(CGFloat)movedX movedY:(CGFloat)movedY touchEnd:(BOOL)end {
    if (self.isMoving) {
        if (self.isMovingVertically) {
            if ([UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait) {
                CGFloat changeValue = (self.beginValue - movedY) / VEDampValueUnit();
                self.beginValue = movedY;
                //              left brightness: x < half screen. right volume: x > half screen.
                [self postEventOfTouchEntry:self.beginPoint.x < self.frame.size.width / 2 ? VEInterfaceElementTypeGestureLeftVerticalPan : VEInterfaceElementTypeGestureRightVerticalPan param:@(changeValue)];
            }
        } else {
            CGFloat changeValue = (movedX - self.beginValue) / (VEDampValueUnit() * 2);
            self.beginValue = movedX;
            NSDictionary *param = @{@"changeValue": @(changeValue), @"touchEnd": @(end)};
            [self postEventOfTouchEntry:VEInterfaceElementTypeGestureHorizontalPan param:param];
        }
    }
}

- (void)postEventOfTouchEntry:(VEInterfaceElementType)type param:(id)obj {
    id<VEInterfaceElementDescription> elementDes = [self elementDesOfType:type];
    if (elementDes) {
        NSString *event = elementDes.elementAction(self);
        if (event && [self.scene.eventPoster screenIsLocking] && ![event isEqualToString:VEUIEventClearScreen]) {
            // ignore all events exception for 'screen clearing'
            return;
        }
        if (!obj && [event isEqualToString:VEUIEventClearScreen]) {
            obj = @(![self.scene.eventPoster screenIsClear]);
        }
        [self.scene.eventMessageBus postEvent:event withObject:obj rightNow:YES];
    }
}

#pragma mark----- UIResponder

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [[touches anyObject] locationInView:UIApplication.sharedApplication.keyWindow];
    self.beginPoint = touchPoint;
    self.isMoving = NO;
    self.isMovingVertically = NO;
    self.beginValue = 0.0;
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
        [self checkEventTouchBeganByMovedX:movedX movedY:movedY];
    }
    [self checkEventByMovedX:movedX movedY:movedY touchEnd:NO];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [[touches anyObject] locationInView:UIApplication.sharedApplication.keyWindow];
    CGFloat movedX = touchPoint.x - self.beginPoint.x;
    CGFloat movedY = touchPoint.y - self.beginPoint.y;
    if (CGPointEqualToPoint(self.beginPoint, touchPoint)) {
        [self singleTapEvent];
        [self.scene.eventMessageBus postEvent:VEPlayEventSeeking withObject:@(NO) rightNow:YES];
        return;
    }
    [self checkEventByMovedX:movedX movedY:movedY touchEnd:YES];
    [self.scene.eventMessageBus postEvent:VEPlayEventSeeking withObject:@(NO) rightNow:YES];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [[touches anyObject] locationInView:UIApplication.sharedApplication.keyWindow];
    CGFloat movedX = touchPoint.x - self.beginPoint.x;
    CGFloat movedY = touchPoint.y - self.beginPoint.y;
    if (CGPointEqualToPoint(self.beginPoint, touchPoint)) {
        [self.scene.eventMessageBus postEvent:VEPlayEventSeeking withObject:@(NO) rightNow:YES];
        return;
    }
    [self checkEventByMovedX:movedX movedY:movedY touchEnd:YES];
    [self.scene.eventMessageBus postEvent:VEPlayEventSeeking withObject:@(NO) rightNow:YES];
}

@end
