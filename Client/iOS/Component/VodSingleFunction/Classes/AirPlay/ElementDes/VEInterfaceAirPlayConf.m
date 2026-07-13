//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "VEInterfaceAirPlayConf.h"
#import "AirPlayRoutePickerView.h"
#import "NSObject+ToElementDescription.h"
#import "VEEventConst.h"
#import "VEInterface.h"
#import "VEInterfaceElementDescriptionImp.h"
#import <ToolKit/ToolKit.h>
#import "Masonry.h"

static NSString *const VEAirPlayButtonIdentifier = @"airPlayButtonIdentifier";

NSString *const VEUIEventAirPlayStateChanged = @"VEUIEventAirPlayStateChanged";

@interface VEInterfaceAirPlayConf ()

@property (nonatomic, strong) AirPlayRoutePickerView *airPlayPickerView;

@end

@implementation VEInterfaceAirPlayConf

- (AirPlayRoutePickerView *)airPlayPickerView {
    if (!_airPlayPickerView) {
        _airPlayPickerView = [[AirPlayRoutePickerView alloc] initWithFrame:CGRectZero];
        _airPlayPickerView.eventPoster = self.eventPoster;
    }
    return _airPlayPickerView;
}

- (VEInterfaceElementDescriptionImp *)airPlayButton {
    __weak typeof(self) weak_self = self;
    return ({
        VEInterfaceElementDescriptionImp *airPlayButtonDes = [VEInterfaceElementDescriptionImp new];
        airPlayButtonDes.elementID = VEAirPlayButtonIdentifier;
        airPlayButtonDes.type = VEInterfaceElementTypeCustomView;
        airPlayButtonDes.customView = weak_self.airPlayPickerView;
        airPlayButtonDes.elementDisplay = ^(AirPlayRoutePickerView *view) {
            [view updateHidden];
        };
        airPlayButtonDes.elementNotify = ^id(AirPlayRoutePickerView *view, NSString *key, id obj) {
            return @[VEUIEventScreenClearStateChanged,
                     VEUIEventScreenLockStateChanged,
                     VEUIEventScreenOrientationChanged];
        };
        airPlayButtonDes.elementWillLayout = ^(AirPlayRoutePickerView *view, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            UIView *pipBtn = [weak_self viewOfElementIdentifier:VEPIPButtonIdentifier inGroup:elementGroup];
            [view mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(22, 22));
                make.centerY.equalTo(pipBtn).offset(1);
                make.right.equalTo(pipBtn.mas_left).offset(-12);
            }];
        };
        airPlayButtonDes;
    });
}

#pragma mark - VEInterfaceElementProtocol

- (NSArray *)extraElements {
    return @[[self airPlayButton]];
}

@end
