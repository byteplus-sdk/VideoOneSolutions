// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "SmartSubtitleManager.h"
#import "SubtitleidType.h"
#import "TTVideoEngine+Options.h"
#import "TTVideoEngine+SubTitle.h"
#import "YYModel.h"
#import <ToolKit/ToolKit.h>

@interface SmartSubtitleManager () <TTVideoEngineSubtitleDelegate>

@property (nonatomic, assign) NSInteger currentSubtitleId;
@property (nonatomic, assign) BOOL isFirstLoad;
@property (nonatomic, strong) SubtitleidType *Off;
@property (nonatomic, assign) NSInteger defaulSubtitleId;

@property (nonatomic, copy) void (^switchSubtitleBlock)(BOOL result);

@end

@implementation SmartSubtitleManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isFirstLoad = YES;
    }
    return self;
}

- (void)dealloc {
    VOLogI(VOVideoPlayback,@"[SmartSubtitle] dealloc");
}
- (void)openSubtitle:(NSString *)subtitleAuthToken {
    [self.videoEngine setOptionForKey:VEKKeyPlayerSubEnabled_BOOL value:@(YES)];
    [self.videoEngine setOptionForKey:VEKKeyPlayerSubtitleOptEnable_BOOL value:@(YES)];
    [self.videoEngine setOptionForKey:VEKeyPlayerEnableSubThread_BOOL value:@(YES)];
    [self.videoEngine setSubtitleDelegate:self];
    [self.videoEngine setSubtitleAuthToken:subtitleAuthToken];
}
- (void)showOriginalSubtitle {
    if (self.subtitleList.count > 1) {
        self.defaulSubtitleId = self.subtitleList[1].subtitleId;
        [self switchSubtitle:self.defaulSubtitleId withBlock:^(BOOL result) {
            if (!result) {
                [[ToastComponent shareToastComponent] showWithMessage:LocalizedStringFromBundle(@"failed_to_obtain_subtitles_toast", @"VEVodApp")];
            }
        }];
    } else {
        [[ToastComponent shareToastComponent] showWithMessage:LocalizedStringFromBundle(@"failed_to_obtain_subtitles_toast", @"VEVodApp")];
    }
}
- (void)showSubtitle:(BOOL)tag {
    __weak __typeof__(self) weak_self = self;
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        weak_self.subTitleLabel.text = @"";
        weak_self.subTitleLabel.hidden = !tag;
    });
    [self.videoEngine setOptionForKey:VEKKeyPlayerSubEnabled_BOOL value:[[NSNumber alloc] initWithBool:tag]];
}
- (void)switchSubtitle:(NSInteger)subtitleId withBlock:(void (^_Nullable)(BOOL))block {
    if (self.videoEngine.playbackState == TTVideoEnginePlaybackStateStopped) {
        self.currentSubtitleId = subtitleId;
        if (block) {
            block(YES);
        }
        return;
    }
    if (self.currentSubtitleId == subtitleId) {
        if (block) {
            block(YES);
        }
        return;
    }
    if (subtitleId == 0) {
        [self showSubtitle:NO];
        if (block) {
            block(YES);
        }
    } else {
        if (self.currentSubtitleId == 0) {
            if (self.isFirstLoad) {
                self.isFirstLoad = NO;
            } else {
                [self showSubtitle:YES];
            }
        }
        self.switchSubtitleBlock = block;
        [self.videoEngine setOptionForKey:VEKeyPlayerSwitchSubtitleId_NSInteger value:[[NSNumber alloc] initWithInteger:subtitleId]];
    }
    self.currentSubtitleId = subtitleId;
}
- (void)resetSubtitleListWithInfos:(NSArray<NSDictionary *> *)subtitleinfos {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:self.Off];
    for (int i = 0; i < subtitleinfos.count; i++) {
        NSInteger subtitleid = [subtitleinfos[i][@"SubtitleId"] integerValue];
        NSInteger languageid = [subtitleinfos[i][@"LanguageId"] integerValue];
        NSString *source = subtitleinfos[i][@"Source"];
        SubtitleidType *subtitle = [[SubtitleidType alloc] init];
        subtitle.subtitleId = subtitleid;
        subtitle.languageName = [SmartSubtitleManager getLanguangeNameWithId:languageid];
        if ([source isEqualToString:@"ASR"]) {
            if (array.count > 1) {
                [array insertObject:subtitle atIndex:1];
            } else {
                self.subTitleLabel.hidden = NO;
                [array addObject:subtitle];
            }
        } else {
            [array addObject:subtitle];
        }
    }
    self.subtitleList = [array copy];
}

#pragma mark -TTVideoEngineSubtitleDelegate
- (void)videoEngine:(TTVideoEngine *)videoEngine onSubtitleInfoCallBack:(NSString *)content pts:(NSUInteger)pts {
    __weak __typeof__(self) weak_self = self;
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        weak_self.subTitleLabel.text = content;
    });
}
- (void)videoEngine:(TTVideoEngine *)videoEngine onSubSwitchCompleted:(BOOL)success currentSubtitleId:(NSInteger)currentSubtitleId {
    VOLogI(VOVideoPlayback,@"[SmartSubtitle] onSubSwitchCompleted, success: %d, currentSubtitleId: %ld", success, currentSubtitleId);
    __weak __typeof__(self) weak_self = self;
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        if (weak_self.defaulSubtitleId == currentSubtitleId) {
            [weak_self showSubtitle:YES];
        }
        if (weak_self.switchSubtitleBlock) {
            weak_self.switchSubtitleBlock(success);
            weak_self.switchSubtitleBlock = nil;
        }
    });
}
- (void)videoEngine:(TTVideoEngine *)videoEngine onSubtitleInfoRequested:(id _Nullable)info error:(NSError *_Nullable)error {
    VOLogI(VOVideoPlayback,@"[SmartSubtitle] onSubtitleInfoRequested");
    __weak __typeof__(self) weak_self = self;
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        if (info) {
            NSDictionary *result = info[@"Result"];
            NSArray *fileSubtitleInfoList = result[@"FileSubtitleInfoList"];
            NSArray *subtitleinfos = fileSubtitleInfoList[0][@"SubtitleInfoList"];
            [weak_self resetSubtitleListWithInfos:subtitleinfos];
        } else {
            [[ToastComponent shareToastComponent] showWithMessage:LocalizedStringFromBundle(@"failed_to_obtain_subtitles_toast", @"VEVodApp")];
            [weak_self clearState];
            if (weak_self.openSubtitleBlock) {
                weak_self.openSubtitleBlock(NO, nil);
            }
        }
    });
}

- (void)videoEngine:(TTVideoEngine *)videoEngine onSubLoadFinished:(BOOL)success info:(TTVideoEngineLoadInfo *_Nullable)info {
    VOLogI(VOVideoPlayback,@"[SmartSubtitle] onSubLoadFinished: %d, firstPts: %ld, code: %ld", success, info.firstPts, info.code);
    __weak __typeof__(self) weak_self = self;
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        if(!success) {
            [[ToastComponent shareToastComponent] showWithMessage:LocalizedStringFromBundle(@"failed_to_obtain_subtitles_toast", @"VEVodApp")];
            [weak_self clearState];
            if (weak_self.openSubtitleBlock) {
                weak_self.openSubtitleBlock(NO, nil);
            }
            return;
        }
        if (weak_self.isFirstLoad) {
            [weak_self showOriginalSubtitle];
            if (weak_self.openSubtitleBlock) {
                if (weak_self.subtitleList.count > 1) {
                    weak_self.openSubtitleBlock(YES, weak_self.subtitleList[1].languageName);
                } else {
                    [[ToastComponent shareToastComponent] showWithMessage:LocalizedStringFromBundle(@"failed_to_obtain_subtitles_toast", @"VEVodApp")];
                    weak_self.openSubtitleBlock(NO, nil);
                }
            }
        } else {
            if (weak_self.currentSubtitleId != 0) {
                [weak_self.videoEngine setOptionForKey:VEKeyPlayerSwitchSubtitleId_NSInteger value:[[NSNumber alloc] initWithInteger:weak_self.currentSubtitleId]];
            } else {
                [weak_self showSubtitle:NO];
            }
            if (weak_self.openSubtitleBlock) {
                weak_self.openSubtitleBlock(YES, [weak_self currentLanguangeName]);
            }
        }
    });
}

- (void)clearState {
    self.subtitleList = @[];
    self.currentSubtitleId = 0;
    self.isFirstLoad = YES;
}
+ (id)getLanguangeNameWithId:(NSInteger)languangeId {
    NSString *result = @"";
    switch (languangeId) {
        case 1:
            result = LocalizedStringFromBundle(@"Chinese", @"VEVodApp");
            break;
        case 2:
            result = LocalizedStringFromBundle(@"English", @"VEVodApp");
            break;
        case 3:
            result = LocalizedStringFromBundle(@"Japanese", @"VEVodApp");
            break;
        case 4:
            result = LocalizedStringFromBundle(@"Korean", @"VEVodApp");
            break;
        default:
            result = @"Unknown";
            break;
    }
    return result;
}

#pragma mark - Getter
- (NSString *)currentLanguangeName {
    if (self.currentSubtitleId == 0) {
        return LocalizedStringFromBundle(@"subtitle_default", @"VEVodApp");
    }
    for (SubtitleidType *sub in self.subtitleList) {
        if (self.currentSubtitleId == sub.subtitleId) {
            return sub.languageName;
        }
    }
    return @"Unknown";
}

- (SubtitleidType *)Off {
    if (!_Off) {
        _Off = [[SubtitleidType alloc] init];
        _Off.subtitleId = 0;
        _Off.languageName = LocalizedStringFromBundle(@"off_button_text", @"VEVodApp");
    }
    return _Off;
}

- (MGPGLabel *)subTitleLabel {
    if (!_subTitleLabel) {
        _subTitleLabel = [[MGPGLabel alloc] init];
        _subTitleLabel.strokeWidth = 1;
        _subTitleLabel.strokeColor = [UIColor blackColor];
        _subTitleLabel.textAlignment = NSTextAlignmentCenter;
        _subTitleLabel.font = [UIFont systemFontOfSize:17 weight:500];
        _subTitleLabel.numberOfLines = 0;
        _subTitleLabel.textColor = [UIColor whiteColor];
        _subTitleLabel.backgroundColor = [UIColor clearColor];
        _subTitleLabel.hidden = YES;
    }
    return _subTitleLabel;
}
@end
