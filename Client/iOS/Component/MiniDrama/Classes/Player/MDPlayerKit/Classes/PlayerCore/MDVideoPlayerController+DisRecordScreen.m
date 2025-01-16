//
//  MDVideoPlayerController+DisRecordScreen.m
//  MDPlayerKit
//
//  Created by zyw on 2024/4/18.
//

#import "MDVideoPlayerController+DisRecordScreen.h"
#import "DramaDisrecordManager.h"
#import <ToolKit/ToolKit.h>

@implementation MDVideoPlayerController (DIsRecordScreen)

- (void)registerScreenCapturedDidChangeNotification {
    if (![DramaDisrecordManager isOpenDisrecord]) {
        return;
    }
    VOLogI(VOMiniDrama, @"registerScreenCapturedDidChangeNotification, %@", self);
    if (@available(iOS 11.0, *)) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIScreenCapturedDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onScreenCapturedChange:) name:UIScreenCapturedDidChangeNotification object:nil];
    }
}

- (void)unregisterScreenCaptureDidChangeNotification {
    if (![DramaDisrecordManager isOpenDisrecord]) {
        return;
    }
    VOLogI(VOMiniDrama, @"unregisterScreenCaptureDidChangeNotification, %@", self);
    if (@available(iOS 11.0, *)) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIScreenCapturedDidChangeNotification object:nil];
    }
}

- (void)onScreenCapturedChange:(NSNotification *)notification {
    if (@available(iOS 11.0, *)) {
        UIScreen *screen = notification.object;
        if (screen) {
            if ([screen isCaptured]) {
                [[DramaDisrecordManager sharedInstance] showDisRecordView];
                [self pause];
            } else {
                [[DramaDisrecordManager sharedInstance] hideDisRecordView];
                [self play];
            }
        }
    }
}
@end
