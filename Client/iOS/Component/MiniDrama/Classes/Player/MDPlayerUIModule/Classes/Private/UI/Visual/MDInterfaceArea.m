// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDInterfaceArea.h"
#import "MDEventConst.h"
#import "MDInterfaceElementDescription.h"

NSString *const MDUIEventScreenRotation = @"MDUIEventScreenRotation";

NSString *const MDUIEventScreenLockStateChanged = @"MDUIEventScreenLockStateChanged";

NSString *const MDUIEventPageBack = @"MDUIEventPageBack";

NSString *const MDUIEventLockScreen = @"MDUIEventLockScreen";

NSString *const MDUIEventStartPip = @"MDUIEventStartPip";

NSString *const MDUIEventClearScreen = @"MDUIEventClearScreen";

@implementation MDInterfaceArea

- (instancetype)initWithElements:(NSArray<id<MDInterfaceElementDescription>> *)elements {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.clipsToBounds = YES;
//        [self _registEvents];
        [self layoutElements:elements];
    }
    return self;
}


#pragma mark ----- Layout

- (void)invalidateLayout {
    
}

- (void)layoutElements:(NSArray<id<MDInterfaceElementDescription>> *)elements {
    
}


#pragma mark ----- Hidden behavior

- (BOOL)isEnableZone:(CGPoint)point {
    if (self.hidden) {
        return NO;
    }
    for (UIView *subview in self.subviews) {
        if (subview.elementDescription) {
            if (CGRectContainsPoint(subview.frame, point)) {
                return YES;
            }
        }
    }
    return NO;
}

- (void)show:(BOOL)show animated:(BOOL)animated {
    if (animated) {
        if (show) {
            if (!self.hidden) return;
            [UIView animateWithDuration:0.3 animations:^{
                self.alpha = 0.0;
            } completion:^(BOOL finished) {
                self.hidden = YES;
                self.alpha = 1.0;
            }];
        } else {
            if (self.hidden) return;
            self.alpha = 0.0;
            self.hidden = NO;
            [UIView animateWithDuration:0.3 animations:^{
                self.alpha = 1.0;
            }];
        }
    } else {
        self.hidden = !show;
    }
}

#pragma mark ----- Message / Action

//- (void)_registEvents {
//    [[MDEventMessageBus universalBus] registEvent:MDUIEventScreenClearStateChanged withAction:@selector(screenAction) ofTarget:self];
//    [[MDEventMessageBus universalBus] registEvent:MDUIEventScreenLockStateChanged withAction:@selector(screenAction) ofTarget:self];
//}
//
//- (void)screenAction {
//    BOOL screenIsClear = [[MDEventPoster currentPoster] screenIsClear];
//    BOOL screenIsLocking = [[MDEventPoster currentPoster] screenIsLocking];
//    if (screenIsLocking) {
//        [self show:NO animated:NO];
//    } else {
//        [self show:!screenIsClear animated:NO];
//    }
//}

@end

