// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEInterfaceSmartSubtitleConf.h"
#import "NSObject+ToElementDescription.h"
#import "VEActionButton.h"
#import "VEEventConst.h"
#import "VEEventMessageBus.h"
#import "VEEventPoster+Private.h"
#import "VEInterface.h"
#import "VEInterfaceElementDescriptionImp.h"
#import <ToolKit/Localizator.h>
#import <ToolKit/ReportComponent.h>
#import <ToolKit/ToolKit.h>

#import "Masonry.h"

static NSString *smartSubtitleButtonIdentify = @"smartSubtitleButtonIdentify";
static NSString *playSpeedButtonIdentifier = @"playSpeedButtonIdentifier";

@interface VEInterfaceSmartSubtitleConf ()
@property (nonatomic, weak) VEActionButton *button;
@end

@implementation VEInterfaceSmartSubtitleConf

- (VEInterfaceElementDescriptionImp *)subTitleButton {
    __weak typeof(self) weak_self = self;
    return ({
        VEInterfaceElementDescriptionImp *subTitleBtnDes = [VEInterfaceElementDescriptionImp new];
        subTitleBtnDes.elementID = smartSubtitleButtonIdentify;
        subTitleBtnDes.type = VEInterfaceElementTypeButton;
        subTitleBtnDes.elementDisplay = ^(VEActionButton *button) {
            weak_self.button = button;
            [weak_self resetState];
        };
        subTitleBtnDes.elementAction = ^NSString *(VEActionButton *button) {
            return VEUIEventShowSubtitleMenu;
        };
        subTitleBtnDes.elementNotify = ^id(VEActionButton *button, NSString *key, id obj) {
            button.hidden = [weak_self buttonHiddon];
            if ([key isEqualToString:VEPlayEventSmartSubtitleChanged]) {
                if ([obj isKindOfClass:[SubtitleidType class]]) {
                    SubtitleidType *subtitle = (SubtitleidType *)obj;
                    NSString *currentLanguageTitle = [(SubtitleidType *)obj languageName];
                    if (subtitle.subtitleId == 0) {
                        [button setImage:[UIImage imageNamed:@"subTitleOff"] forState:UIControlStateNormal];
                        NSString *title = LocalizedStringFromBundle(@"subtitle_default", @"VEVodApp");
                        [button setTitle:title forState:UIControlStateNormal];
                        [weak_self.manager switchSubtitle:0 withBlock:^(BOOL result) {
                            [[ToastComponent shareToastComponent] showWithMessage:LocalizedStringFromBundle(@"subtitle_close", @"VEVodApp")];
                        }];
                    } else {
                        [button setImage:[UIImage imageNamed:@"subTitle"] forState:UIControlStateNormal];
                        [button setTitle:currentLanguageTitle forState:UIControlStateNormal];
                        if (weak_self.manager.currentSubtitleId == 0) {
                            [[ToastComponent shareToastComponent] showWithMessage:[NSString stringWithFormat:LocalizedStringFromBundle(@"subtitle_open", @"VEVodApp"), currentLanguageTitle]];
                            [weak_self.manager switchSubtitle:subtitle.subtitleId withBlock:nil];
                        } else {
                            [weak_self.manager switchSubtitle:subtitle.subtitleId withBlock:nil];
                        }
                    }
                } else {
                    [[ToastComponent shareToastComponent] showWithMessage:LocalizedStringFromBundle(@"failed_to_obtain_subtitles_toast", @"VEVodApp")];
                }
            }
            return @[VEPlayEventSmartSubtitleChanged, VEUIEventScreenClearStateChanged, VEUIEventScreenLockStateChanged];
        };
        subTitleBtnDes.elementWillLayout = ^(__kindof UIView *elementView, NSSet<UIView *> *elementGroup, __kindof UIView *goupContainer) {
            if (normalScreenBehaivor()) {
                elementView.hidden = YES;
                elementView.alpha = 0.0;
            } else {
                elementView.hidden = NO;
                elementView.alpha = 1.0;
                UIView *playSpeedBtn = [weak_self viewOfElementIdentifier:playSpeedButtonIdentifier inGroup:elementGroup];
                [elementView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(playSpeedBtn);
                    make.trailing.equalTo(playSpeedBtn.mas_leading).offset(-25);
                    make.height.mas_equalTo(50.0);
                }];
            }
        };
        subTitleBtnDes;
    });
}

- (void)setManager:(SmartSubtitleManager *)manager {
    _manager = manager;
    [self.button setTitle:manager.currentLanguangeName forState:UIControlStateNormal];
    __weak __typeof__(self) weak_self = self;
    manager.openSubtitleBlock = ^(BOOL result, NSString *_Nullable defaulLanguage) {
        if (result) {
            [weak_self refresh:defaulLanguage];
        } else {
            [weak_self resetState];
        }
    };
}

- (void)resetState {
    __weak __typeof__(self) weak_self = self;
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        [weak_self.button setImage:[UIImage imageNamed:@"subTitle"] forState:UIControlStateNormal];
        NSString *title = LocalizedStringFromBundle(@"subtitle_default", @"VEVodApp");
        [weak_self.button setTitle:title forState:UIControlStateNormal];
    });
}

- (void)refresh:(NSString *)languageName {
    __weak __typeof__(self) weak_self = self;
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        [weak_self.button setTitle:languageName forState:UIControlStateNormal];
    });
}

- (BOOL)buttonHiddon {
    BOOL screenIsClear = [self.eventPoster screenIsClear];
    BOOL screenIsLocking = [self.eventPoster screenIsLocking];
    return screenIsLocking || screenIsClear;
}

#pragma mark - VEInterfaceElementProtocol

- (NSArray *)extraElements {
    return @[[self subTitleButton]];
}

@end
