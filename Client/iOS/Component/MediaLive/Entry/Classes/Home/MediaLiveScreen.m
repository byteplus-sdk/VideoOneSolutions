//
//  MediaLiveScreenCapture.m
//  MediaLive
//
//  Created by ByteDance on 2024/5/31.
//
#import <ToolKit/ToolKit.h>
#import <ToolKit/Localizator.h>
#import "MediaLiveScreen.h"
#import "VELPushScreenCaptureNewViewController.h"

@implementation MediaLiveScreen

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = LocalizedStringFromBundle(@"medialive_screen_entry_title", @"MediaLive");
        self.iconName = @"function_icon_live_screen";
    }
    return self;
}

- (void)enterWithCallback:(void (^)(BOOL))block {
    [super enterWithCallback:block];
    VELPushScreenCaptureNewViewController *vc = [[VELPushScreenCaptureNewViewController alloc] initWithCaptureType:VELSettingCaptureTypeScreen];
    UIViewController *topVC = [DeviceInforTool topViewController];
    [topVC.navigationController pushViewController:vc animated:YES];
    if (block) {
        block(YES);
    }
}

@end
