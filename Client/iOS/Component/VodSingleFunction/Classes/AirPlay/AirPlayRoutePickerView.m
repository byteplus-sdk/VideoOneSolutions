//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "AirPlayRoutePickerView.h"
#import "VEEventConst.h"
#import "VEEventPoster.h"
#import "VEInterface.h"
#import <AVKit/AVKit.h>

@interface AirPlayRoutePickerView ()

@property (nonatomic, strong) AVRoutePickerView *routePickerView;

@end

@implementation AirPlayRoutePickerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _routePickerView = [[AVRoutePickerView alloc] initWithFrame:CGRectZero];
        _routePickerView.prioritizesVideoDevices = YES;
        _routePickerView.tintColor = [UIColor whiteColor];
        _routePickerView.activeTintColor = [UIColor whiteColor];
        _routePickerView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_routePickerView];
        [NSLayoutConstraint activateConstraints:@[
            [_routePickerView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [_routePickerView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [_routePickerView.topAnchor constraintEqualToAnchor:self.topAnchor],
            [_routePickerView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        ]];
    }
    return self;
}

- (void)updateHidden {
    BOOL screenIsClear = [self.eventPoster screenIsClear];
    BOOL screenIsLocking = [self.eventPoster screenIsLocking];
    self.hidden = !normalScreenBehaivor() || screenIsClear || screenIsLocking;
}

#pragma mark - VEInterfaceCustomView

- (void)elementViewAction {
}

- (void)elementViewEventNotify:(id)obj {
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSString *key = [[(NSDictionary *)obj allKeys] firstObject];
        if (key) {
            [self updateHidden];
        }
    }
}

- (BOOL)isEnableZone:(CGPoint)point {
    if (self.hidden) {
        return NO;
    }
    return CGRectContainsPoint(self.frame, point);
}

@end
