// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDPlayerActionView.h"
#import "NSArray+BTDAdditions.h"
#import "MDPlayerControlViewDefine.h"

@interface MDPlayerActionView ()

@property (nonatomic, strong) NSMutableArray *orderedSubviews;

@end

@implementation MDPlayerActionView

#pragma mark - Public Mehtod

- (void)addPlayerControlView:(MDPlayerControlView * _Nullable)controlView viewType:(MDPlayerControlViewType)viewType {
    if (!controlView || [self viewWithTag:viewType]) {
        return;
    }

    controlView.tag = viewType;
    if (self.orderedSubviews.count) {
        BOOL flag = NO;
        for (UIView *targetView in self.orderedSubviews) {
            if (viewType < targetView.tag) {
                [self insertSubview:controlView belowSubview:targetView];
                [self.orderedSubviews btd_insertObject:controlView atIndex:0];
                flag = YES;
                break;
            }
        }
        if (!flag) {
            [self addSubview:controlView];
            [self.orderedSubviews btd_addObject:controlView];
        }
    } else {
        [self addSubview:controlView];
        [self.orderedSubviews btd_addObject:controlView];
    }
}

- (void)removePlayerControlView:(MDPlayerControlViewType)viewType {
    MDPlayerControlView *controlView = [self viewWithTag:viewType];
    if (controlView) {
        [controlView removeFromSuperview];
        controlView = nil;
    }
}

- (MDPlayerControlView * _Nullable)getPlayerControlView:(MDPlayerControlViewType)viewType {
    MDPlayerControlView *controlView = [self viewWithTag:viewType];
    return controlView;
}

#pragma mark - Setter & Getter
- (NSMutableArray *)orderedSubviews {
    if (!_orderedSubviews) {
        _orderedSubviews = [NSMutableArray array];
    }
    return _orderedSubviews;
}

@end
