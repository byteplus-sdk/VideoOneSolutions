// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPushUIViewController+Private.h"
#import <ToolKit/Localizator.h>
@implementation VELPushUIViewController (Record)
- (void)setSnapShotResult:(nullable UIImage *)image error:(nullable NSError *)error {
    if (error != nil || image == nil) {
        [VELUIToast showText:LocalizedStringFromBundle(@"medialive_snapshot_failed", @"MediaLive")];
    } else {
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)recordTimerAction {
    self.recordViewModel.time = ++_recordTime;
    [self.recordViewModel updateUI];
}

- (void)clearRecordState {
    self.recordViewModel.state = VELSettingsRecordStateNone;
    self.recordViewModel.time = 0;
    [self.recordViewModel updateUI];
}
- (void)setRecordStartResultError:(nullable NSError *)error {
    _recordTime = 0;
    if (error != nil) {
        [VELUIToast showText:LocalizedStringFromBundle(@"medialive_record_failed", @"MediaLive")];
        self.recordViewModel.state = VELSettingsRecordStateNone;
        [self.recordViewModel updateUI];
    } else {
        if (!_recordTimer && _recordTimer.isValid) {
            [_recordTimer invalidate];
        }
        _recordTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(recordTimerAction) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_recordTimer forMode:NSRunLoopCommonModes];
        [_recordTimer fire];
    }
}
- (void)setRecordResult:(nullable NSString *)videoPath error:(nullable NSError *)error {
    if (_recordTimer.isValid) {
        [_recordTimer invalidate];
        _recordTimer = nil;
    }
    if (error != nil || VEL_IS_EMPTY_STRING(videoPath)) {
        [VELUIToast showText:LocalizedStringFromBundle(@"medialive_record_failed", @"MediaLive")];
    } else {
        if (VEL_IS_NOT_EMPTY_STRING(videoPath)) {
            UISaveVideoAtPathToSavedPhotosAlbum(videoPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        }
    }
    [self clearRecordState];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    [VELUIToast hideAllToast];
    if (error == nil) {
        [VELUIToast showText:LocalizedStringFromBundle(@"medialive_snapshot_saved", @"MediaLive") detailText:@""];
    } else {
        [VELUIToast showText:@"%@%@", LocalizedStringFromBundle(@"medialive_snapshot_save_failed", @"MediaLive"),error.localizedDescription];
    }
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    [VELUIToast hideAllToast];
    if (error == nil) {
        [VELUIToast showText:LocalizedStringFromBundle(@"medialive_record_saved", @"MediaLive") detailText:@""];
    } else {
        [VELUIToast showText:LocalizedStringFromBundle(@"medialive_record_save_failed", @"MediaLive"), error.localizedDescription];
    }
    [self clearRecordState];
}

- (void)startRecord:(int)width height:(int)height {}
- (void)stopRecord {}
- (void)snapShot {}
@end
