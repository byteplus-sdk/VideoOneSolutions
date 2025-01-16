//
//  DramaSubtitleManage.m
//  AFNetworking
//
//  Created by ByteDance on 2024/12/6.
//

#import "DramaSubtitleManage.h"
#import "TTVideoEngine+Options.h"
#import "TTVideoEngine+SubTitle.h"
#import "YYModel.h"
#import <ToolKit/ToolKit.h>

@implementation DramaSubtitleModel

@end

@interface DramaSubtitleManage ()<TTVideoEngineSubtitleDelegate>
@property (nonatomic, strong) DramaSubtitleModel *currentSubtitleModel;
@property (nonatomic, assign) BOOL isFirstLoad;
@property (nonatomic, strong) DramaSubtitleModel *Off;
@property (nonatomic, assign) NSInteger defaulSubtitleId;
@property (nonatomic, copy) void (^switchSubtitleBlock)(BOOL result);

@end

@implementation DramaSubtitleManage

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isFirstLoad = YES;
    }
    return self;
}

- (void)dealloc {
    VOLogI(VOMiniDrama,@"[SmartSubtitle] dealloc");
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
//            if (!result) {
//                [[ToastComponent shareToastComponent] showWithMessage:LocalizedStringFromBundle(@"failed_to_obtain_subtitles_toast", @"VodPlayer")];
//            }
        }];
    } else {
        [[ToastComponent shareToastComponent] showWithMessage:LocalizedStringFromBundle(@"failed_to_obtain_subtitles_toast", @"VodPlayer")];
    }
}
- (void)showSubtitle:(BOOL)tag {
    __weak __typeof__(self) weak_self = self;
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        weak_self.subTitleLabel.text = @"";
//        weak_self.subTitleLabel.hidden = !tag;
    });
    [self.videoEngine setOptionForKey:VEKKeyPlayerSubEnabled_BOOL value:[[NSNumber alloc] initWithBool:tag]];
}
- (void)switchSubtitle:(NSInteger)subtitleId withBlock:(void (^_Nullable)(BOOL))block {
    if (self.videoEngine.playbackState == TTVideoEnginePlaybackStateStopped || self.currentSubtitleModel.subtitleId == subtitleId) {
        [self updateSubtitleId:subtitleId];
        if (block) {
            block(YES);
        }
        return;
    }
    
    if (subtitleId == 0) {
        [self updateSubtitleId:0];
        [self showSubtitle:NO];
        if (block) {
            block(YES);
        }
    } else {
        if (self.currentSubtitleModel.subtitleId == 0) {
            if (self.isFirstLoad) {
                self.isFirstLoad = NO;
            } else {
                [self showSubtitle:YES];
            }
        }
        self.switchSubtitleBlock = block;
        [self.videoEngine setOptionForKey:VEKeyPlayerSwitchSubtitleId_NSInteger value:[[NSNumber alloc] initWithInteger:subtitleId]];
    }
    [self updateSubtitleId:subtitleId];
}

- (void)updateSubtitleId:(NSInteger) subtitleId {
    self.currentSubtitleModel.subtitleId = subtitleId;
    self.currentSubtitleModel.languageName = [self currentLanguangeName];
}
- (void)resetSubtitleListWithInfos:(NSArray<NSDictionary *> *)subtitleinfos {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:self.Off];
    for (int i = 0; i < subtitleinfos.count; i++) {
        NSInteger subtitleid = [subtitleinfos[i][@"SubtitleId"] integerValue];
        NSInteger languageid = [subtitleinfos[i][@"LanguageId"] integerValue];
        NSString *source = subtitleinfos[i][@"Source"];
        DramaSubtitleModel *subtitle = [[DramaSubtitleModel alloc] init];
        subtitle.subtitleId = subtitleid;
        subtitle.languageName = [DramaSubtitleManage getLanguangeNameWithId:languageid];
        if ([source isEqualToString:@"ASR"]) {
            VOLogI(VOMiniDrama, @"origin language: %@", subtitle.languageName);
            if (array.count > 1) {
                [array insertObject:subtitle atIndex:1];
            } else {
//                self.subTitleLabel.hidden = NO;
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
    VOLogI(VOMiniDrama,@"[SmartSubtitle] onSubSwitchCompleted, success: %d, currentSubtitleId: %ld", success, currentSubtitleId);
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
    VOLogI(VOMiniDrama,@"[SmartSubtitle] onSubtitleInfoRequested");
    __weak __typeof__(self) weak_self = self;
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        if (info) {
            NSDictionary *result = info[@"Result"];
            NSArray *fileSubtitleInfoList = result[@"FileSubtitleInfoList"];
            NSArray *subtitleinfos = fileSubtitleInfoList[0][@"SubtitleInfoList"];
            [weak_self resetSubtitleListWithInfos:subtitleinfos];
        } else {
            [[ToastComponent shareToastComponent] showWithMessage:LocalizedStringFromBundle(@"failed_to_obtain_subtitles_toast", @"VodPlayer")];
            [weak_self clearState];
            if (weak_self.openSubtitleBlock) {
                weak_self.openSubtitleBlock(NO, nil);
            }
        }
    });
}

- (void)videoEngine:(TTVideoEngine *)videoEngine onSubLoadFinished:(BOOL)success info:(TTVideoEngineLoadInfo *_Nullable)info {
    VOLogI(VOMiniDrama,@"[SmartSubtitle] onSubLoadFinished: %d, firstPts: %ld, code: %ld", success, info.firstPts, info.code);
    __weak __typeof__(self) weak_self = self;
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        if(!success) {
            [[ToastComponent shareToastComponent] showWithMessage:LocalizedStringFromBundle(@"failed_to_obtain_subtitles_toast", @"VodPlayer")];
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
                    weak_self.openSubtitleBlock(YES, weak_self.subtitleList[1]);
                } else {
                    [[ToastComponent shareToastComponent] showWithMessage:LocalizedStringFromBundle(@"failed_to_obtain_subtitles_toast", @"VodPlayer")];
                    weak_self.openSubtitleBlock(NO, nil);
                }
            }
        } else {
            if (weak_self.currentSubtitleModel.subtitleId != 0) {
                [weak_self.videoEngine setOptionForKey:VEKeyPlayerSwitchSubtitleId_NSInteger value:[[NSNumber alloc] initWithInteger:weak_self.currentSubtitleModel.subtitleId]];
            } else {
                [weak_self showSubtitle:NO];
            }
            if (weak_self.openSubtitleBlock) {
                weak_self.openSubtitleBlock(YES, weak_self.currentSubtitleModel);
            }
        }
    });
}

- (void)clearState {
    self.subtitleList = @[];
    self.currentSubtitleModel = nil;
    self.isFirstLoad = YES;
    self.videoEngine = nil;
    self.openSubtitleBlock = nil;
    self.switchSubtitleBlock = nil;
}
+ (id)getLanguangeNameWithId:(NSInteger)languangeId {
    NSString *result = @"";
    switch (languangeId) {
        case 1:
            result = LocalizedStringFromBundle(@"Chinese", @"VodPlayer");
            break;
        case 2:
            result = LocalizedStringFromBundle(@"English", @"VodPlayer");
            break;
        case 3:
            result = LocalizedStringFromBundle(@"Japanese", @"VodPlayer");
            break;
        case 4:
            result = LocalizedStringFromBundle(@"Korean", @"VodPlayer");
            break;
        default:
            result = LocalizedStringFromBundle(@"subtitle_default", @"VodPlayer");
            break;
    }
    return result;
}

- (NSString *)currentLanguangeName {
    if (self.currentSubtitleModel.subtitleId == 0 || self.subtitleList == nil) {
        return LocalizedStringFromBundle(@"subtitle_default", @"VodPlayer");
    }
    for (DramaSubtitleModel *sub in self.subtitleList) {
        if (self.currentSubtitleModel.subtitleId == sub.subtitleId) {
            return sub.languageName;
        }
    }
    return LocalizedStringFromBundle(@"subtitle_default", @"VodPlayer");
}

#pragma mark - Getter

- (DramaSubtitleModel *)Off {
    if (!_Off) {
        _Off = [[DramaSubtitleModel alloc] init];
        _Off.subtitleId = 0;
        _Off.languageName = LocalizedStringFromBundle(@"off_button_text", @"VodPlayer");
    }
    return _Off;
}

- (DramaSubtitleLabel *)subTitleLabel {
    if (!_subTitleLabel) {
        _subTitleLabel = [[DramaSubtitleLabel alloc] init];
        _subTitleLabel.strokeWidth = 1;
        _subTitleLabel.strokeColor = [UIColor blackColor];
        _subTitleLabel.tag = 12345;
        _subTitleLabel.textAlignment = NSTextAlignmentCenter;
        _subTitleLabel.font = [UIFont systemFontOfSize:17 weight:500];
        _subTitleLabel.numberOfLines = 0;
        _subTitleLabel.textColor = [UIColor whiteColor];
        _subTitleLabel.backgroundColor = [UIColor clearColor];
//        _subTitleLabel.hidden = YES;
    }
    return _subTitleLabel;
}

- (DramaSubtitleModel *)currentSubtitleModel {
    if (!_currentSubtitleModel) {
        _currentSubtitleModel = [DramaSubtitleModel new];
        _currentSubtitleModel.subtitleId = 0;
        _currentSubtitleModel.languageName = [self currentLanguangeName];
    }
    return _currentSubtitleModel;
}

@end

