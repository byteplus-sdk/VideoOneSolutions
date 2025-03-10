// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDActionButton.h"
#import "MDInterfaceElementDescription.h"
#import "UIView+MDElementDescripition.h"
#import "MDEventConst.h"

@implementation MDActionButton

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
}


#pragma mark ----- MDInterfaceFactoryProduction

- (void)elementViewAction {
    [self addTarget:self action:@selector(touchUpInsideAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)touchUpInsideAction:(UIControl *)sender {
    if (sender.elementDescription.elementAction) {
        NSString *eventKey = sender.elementDescription.elementAction(sender);
        if ([eventKey isKindOfClass:[NSString class]]) {
            [[MDEventMessageBus universalBus] postEvent:eventKey withObject:nil rightNow:YES];
        } else if ([eventKey isKindOfClass:[NSDictionary class]]) {
            NSDictionary *eventDic = (NSDictionary *)eventKey;
            [[MDEventMessageBus universalBus] postEvent:eventDic.allKeys.firstObject withObject:eventDic.allValues.firstObject rightNow:YES];
        }
    }
}

- (void)elementViewEventNotify:(id)param {
    if ([param isKindOfClass:[NSDictionary class]]) {
        NSDictionary *paramDic = (NSDictionary *)param;
        if (self.elementDescription.elementNotify) {
            self.elementDescription.elementNotify(self, [[paramDic allKeys] firstObject], [[paramDic allValues] firstObject]);
        }
    }
}

- (BOOL)isEnableZone:(CGPoint)point {
    if (self.hidden) {
        return NO;
    }
    if (CGRectContainsPoint(self.frame, point)) {
        return YES;
    }
    return NO;
}

@end
