// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

#import <AVKit/AVKit.h>
#import <React/RCTComponent.h>
#import <React/RCTViewManager.h>

@interface AirPlayRoutePickerView : AVRoutePickerView <AVRoutePickerViewDelegate>
@property(nonatomic, copy) RCTBubblingEventBlock onWillPresentRoutes;
@property(nonatomic, copy) RCTBubblingEventBlock onDidEndPresentingRoutes;
@end

@implementation AirPlayRoutePickerView

- (instancetype)init
{
  if (self = [super init]) {
    self.delegate = self;
    self.prioritizesVideoDevices = YES;
  }
  return self;
}

- (void)routePickerViewWillBeginPresentingRoutes:(__unused AVRoutePickerView *)routePickerView
{
  if (self.onWillPresentRoutes) {
    self.onWillPresentRoutes(@{});
  }
}

- (void)routePickerViewDidEndPresentingRoutes:(__unused AVRoutePickerView *)routePickerView
{
  if (self.onDidEndPresentingRoutes) {
    self.onDidEndPresentingRoutes(@{});
  }
}

@end

@interface AirPlayRoutePickerViewManager : RCTViewManager
@end

@implementation AirPlayRoutePickerViewManager

RCT_EXPORT_MODULE(AirPlayRoutePickerView)

- (UIView *)view
{
  return [AirPlayRoutePickerView new];
}

RCT_EXPORT_VIEW_PROPERTY(tintColor, UIColor)
RCT_EXPORT_VIEW_PROPERTY(activeTintColor, UIColor)
RCT_EXPORT_VIEW_PROPERTY(prioritizesVideoDevices, BOOL)
RCT_EXPORT_VIEW_PROPERTY(onWillPresentRoutes, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onDidEndPresentingRoutes, RCTBubblingEventBlock)

@end
