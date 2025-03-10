// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDInterfaceSensor.h"
#import "MDInterfaceProtocol.h"
#import "MDInterfaceElementDescription.h"
#import "MDEventConst.h"
#import "VEEventTimer.h"


NSString *const MDUIEventVolumeIncrease = @"MDUIEventVolumeIncrease";

NSString *const MDUIEventBrightnessIncrease = @"MDUIEventBrightnessIncrease";

NSString *const MDPlayEventProgressValueIncrease = @"MDPlayEventProgressValueIncrease";


static inline CGFloat MDDampValueUnit () {
    return UIScreen.mainScreen.bounds.size.width / 3.0;
}

static const CGFloat MDCheckSlideValue = 13.0;

static const CGFloat lockTimeinterval = 5.0;

@interface MDInterfaceSensor ()

@property (nonatomic, assign) CGPoint beginPoint;

@property (nonatomic, assign) CGFloat beginValue;

@property (nonatomic, assign) BOOL isMoving;

@property (nonatomic, assign) BOOL isMovingVertically;

@property (nonatomic, assign) BOOL isMovingLeftSide;

@property (nonatomic, strong) NSMutableSet *elementGestures;

@property (nonatomic, assign) NSTimeInterval tapEndTime;

@property (nonatomic, strong) VEEventTimer *timer;

@end

@implementation MDInterfaceSensor

- (instancetype)initWithScene:(id<MDInterfaceElementDataSource>)scene {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self initializeGesture:scene];
    }
    return self;
}

- (void)dealloc
{
    [self.timer stop];
}

- (void)clearScreen {
    [[MDEventMessageBus universalBus] postEvent:MDUIEventClearScreen withObject:@(YES) rightNow:YES];
}

- (void)clearScreenIfNeed {
    [self.timer stop];
    if ([[MDEventPoster currentPoster] currentPlaybackState] == MDPlaybackStatePlaying && ![[MDEventPoster currentPoster] screenIsClear]) {
        [[MDEventMessageBus universalBus] postEvent:MDUIEventClearScreen withObject:@(YES) rightNow:YES];
    }
}

- (void)performClearScreenLater {
    [self.timer stop];
    if ([[MDEventPoster currentPoster] currentPlaybackState] == MDPlaybackStatePlaying && ![[MDEventPoster currentPoster] screenIsClear]) {
        [self.timer restart];
    }
}

- (void)initializeGesture:(id<MDInterfaceElementDataSource>)scene {
    [self doubleTapGesture];
    self.elementGestures = [NSMutableSet set];
    for (id<MDInterfaceElementDescription> elementDes in [scene customizedElements]) {
        if (elementDes.type > MDInterfaceElementTypeGesture && elementDes.type < MDInterfaceElementTypeVisual) {
            if (elementDes.type == MDInterfaceElementTypeGestureAutoHideController) {
                self.timer = [[VEEventTimer alloc] init];
                [self.timer addTarget:self action:@selector(clearScreenIfNeed) loopInterval:lockTimeinterval * NSEC_PER_SEC];
                [self performClearScreenLater];
            }
            [self.elementGestures addObject:elementDes];
        }
    }
}

- (void)doubleTapGesture {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapEvent)];
    tap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:tap];
}

- (id<MDInterfaceElementDescription>)elementDesOfType:(MDInterfaceElementType)gestureType {
    for (id<MDInterfaceElementDescription> elementDes in self.elementGestures) {
        if (gestureType == elementDes.type) return elementDes;
    }
    return nil;
}

- (void)resetResponderStatus {
    self.beginPoint = CGPointZero;
    self.isMoving = NO;
    self.isMovingVertically = NO;
    self.beginValue = 0.0;
}

#pragma mark ----- Event
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

- (void)singleTapEvent {
    [self postEventOfTouchEntry:MDInterfaceElementTypeGestureSingleTap param:nil];
}

- (void)singleTapEvent:(NSValue *)touchPoint {
    [self postEventOfTouchEntry:MDInterfaceElementTypeGestureSingleTap param:@{
        @"locationInView": self,
        @"location": touchPoint
    }];
}

- (void)doubleTapEvent {
    [self postEventOfTouchEntry:MDInterfaceElementTypeGestureDoubleTap param:nil];
}

- (void)doubleTapEvent:(NSValue *)touchPoint {
    [self postEventOfTouchEntry:MDInterfaceElementTypeGestureDoubleTap param:@{
        @"locationInView": self,
        @"location": touchPoint
    }];
}


- (void)checkEventTouchBegan {
    if ([[MDEventPoster currentPoster] screenIsLocking]) {
        return;
    }
    NSDictionary *param = @{@"changeValue": @(0), @"touchBegan": @(YES), @"touchEnd": @(NO)};
    if (self.isMovingVertically) {
        MDInterfaceElementType type = self.isMovingLeftSide ? MDInterfaceElementTypeGestureLeftVerticalPan : MDInterfaceElementTypeGestureRightVerticalPan;
        [self postEventOfTouchEntry:type param:param];
        return;
    }
    [self postEventOfTouchEntry:MDInterfaceElementTypeGestureHorizontalPan param:param];
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

- (void)checkEventByMovedX:(CGFloat)movedX movedY:(CGFloat)movedY {
    if (self.isMoving) {
        if (self.isMovingVertically) {
            CGFloat changeValue = (self.beginValue - movedY) / MDDampValueUnit();
            self.beginValue = movedY;
            MDInterfaceElementType type = self.isMovingLeftSide ? MDInterfaceElementTypeGestureLeftVerticalPan : MDInterfaceElementTypeGestureRightVerticalPan;
            [self postEventOfTouchEntry:type param:@(changeValue)];
        } else {
            CGFloat changeValue = (movedX - self.beginValue) / (MDDampValueUnit() * 2);
            self.beginValue = movedX;
            [self postEventOfTouchEntry:MDInterfaceElementTypeGestureHorizontalPan param:@(changeValue)];
        }
    }
}

- (void)checkEventByMovedX:(CGFloat)movedX movedY:(CGFloat)movedY touchEnd:(BOOL)end {
    if (!self.isMoving || [[MDEventPoster currentPoster] screenIsLocking]) {
        return;
    }
    if (self.isMovingVertically) {
        CGFloat changeValue = (self.beginValue - movedY) / MDDampValueUnit();
        self.beginValue = movedY;
        MDInterfaceElementType type = self.isMovingLeftSide ? MDInterfaceElementTypeGestureLeftVerticalPan : MDInterfaceElementTypeGestureRightVerticalPan;
        NSDictionary *param = @{@"changeValue": @(changeValue), @"touchBegan": @(NO), @"touchEnd": @(end)};
        [self postEventOfTouchEntry:type param:param];
        return;
    }
    CGFloat changeValue = (movedX - self.beginValue) / (MDDampValueUnit() * 2);
    self.beginValue = movedX;
    NSDictionary *param = @{@"changeValue": @(changeValue), @"touchBegan": @(NO), @"touchEnd": @(end)};
    [self postEventOfTouchEntry:MDInterfaceElementTypeGestureHorizontalPan param:param];
}

- (void)postEventOfTouchEntry:(MDInterfaceElementType)type param:(id)obj {
    id<MDInterfaceElementDescription> elementDes = [self elementDesOfType:type];
    if (elementDes) {
        NSString *event = elementDes.elementAction(self);
        if (event && [[MDEventPoster currentPoster] screenIsLocking] && ![event isEqualToString:MDUIEventClearScreen]) {
            return;
        }
        if (elementDes.elementNotify) {
            elementDes.elementNotify(self, event, obj);
            return;
        }
        [[MDEventMessageBus universalBus] postEvent:event withObject:obj rightNow:YES];
    }
}


#pragma mark ----- UIResponder

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
    if (!self.isMoving && (ABS(movedX) > MDCheckSlideValue || ABS(movedY) > MDCheckSlideValue)) {
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
