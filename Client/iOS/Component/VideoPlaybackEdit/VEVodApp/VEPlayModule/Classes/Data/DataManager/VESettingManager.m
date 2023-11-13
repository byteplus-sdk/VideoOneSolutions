// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VESettingManager.h"
#import "VEVideoPlayerController.h"
#import "VEVideoPlayerController+DebugTool.h"
#import <ToolKit/Localizator.h>
#import "ToastComponent.h"

static NSString * const shortVideoSectionKey = @"短视频策略";

static NSString * const universalSectionKey = @"通用选项";

NSString * const universalActionSectionKey = @"通用操作"; // clear, log out?

NSString * const  universalDidSectionKey = @"did";

@interface VESettingManager ()

@property (nonatomic, strong) NSMutableDictionary *settings;

@end

@implementation VESettingManager

static VESettingManager *instance;
static dispatch_once_t onceToken;
+ (VESettingManager *)universalManager {
    dispatch_once(&onceToken, ^{
        instance = [VESettingManager new];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.settings = [NSMutableDictionary dictionary];
        [self initialDefaultSettings];
    }
    return self;
}

- (void)initialDefaultSettings {
    NSMutableArray *shortVideoSection = [NSMutableArray array];
    [shortVideoSection addObject:({
        VESettingModel *model = [VESettingModel new];
        model.displayText = LocalizedStringFromBundle(@"Preload_strategy", @"VEVodApp");
        model.settingKey = VESettingKeyShortVideoPreloadStrategy;
        model.open = YES;
        model.settingType = VESettingTypeSwitcher;
        model.allAreaAction = ^{
            [[ToastComponent shareToastComponent] showWithMessage:LocalizedStringFromBundle(@"video_strategy_changed", @"VEVodApp")];
        };
        model;
    })];
    [shortVideoSection addObject:({
        VESettingModel *model = [VESettingModel new];
        model.displayText = LocalizedStringFromBundle(@"Prerender_strategy", @"VEVodApp");
        model.settingKey = VESettingKeyShortVideoPreRenderStrategy;
        model.open = YES;
        model.settingType = VESettingTypeSwitcher;
        model.allAreaAction = ^{
            [[ToastComponent shareToastComponent] showWithMessage:LocalizedStringFromBundle(@"video_strategy_changed", @"VEVodApp")];
        };
        model;
    })];
    [self.settings setValue:shortVideoSection forKey:shortVideoSectionKey];
    
    NSMutableArray *universalSection = [NSMutableArray array];
    [universalSection addObject:({
        VESettingModel *model = [VESettingModel new];
        model.displayText = @"bytevc1";
        model.settingKey = VESettingKeyUniversalH265;
        model.open = YES;
        model.settingType = VESettingTypeSwitcher;
        model.allAreaAction = ^{
            [[ToastComponent shareToastComponent] showWithMessage:LocalizedStringFromBundle(@"video_strategy_changed", @"VEVodApp")];
        };
        model;
    })];
    [universalSection addObject:({
        VESettingModel *model = [VESettingModel new];
        model.displayText = LocalizedStringFromBundle(@"hardware_decoding", @"VEVodApp");
        model.settingKey = VESettingKeyUniversalHardwareDecode;
        model.open = YES;
        model.settingType = VESettingTypeSwitcher;
        model.allAreaAction = ^{
            [[ToastComponent shareToastComponent] showWithMessage:LocalizedStringFromBundle(@"video_strategy_changed", @"VEVodApp")];
        };
        model;
    })];
    [self.settings setValue:universalSection forKey:universalSectionKey];
    
    NSMutableArray *universalDidSection = [NSMutableArray array];
    [universalDidSection addObject:({
        VESettingModel *model = [VESettingModel new];
        model.displayText = LocalizedStringFromBundle(@"device_id", @"VEVodApp");
        model.settingKey = VESettingKeyUniversalDeviceID;
        model.detailText = [VEVideoPlayerController deviceID];
        model.settingType = VESettingTypeDisplayDetail;
        model.allAreaAction = ^{
            [[ToastComponent shareToastComponent] showWithMessage:LocalizedStringFromBundle(@"copy_did_success", @"VEVodApp")];
        };
        model;
    })];
    [self.settings setValue:universalDidSection forKey:universalDidSectionKey];
    
    NSMutableArray *universalActionSection = [NSMutableArray array];
    [universalActionSection addObject:({
        VESettingModel *model = [VESettingModel new];
        model.displayText = LocalizedStringFromBundle(@"clean_cache", @"VEVodApp");
        model.settingKey = VESettingKeyUniversalActionCleanCache;
        model.settingType = VESettingTypeDisplay;
        model.allAreaAction = ^{
            [VEVideoPlayerController cleanCache];
            [[ToastComponent shareToastComponent] showWithMessage:LocalizedStringFromBundle(@"clean_cache_success", @"VEVodApp")];
        };
        model;
    })];
    [self.settings setValue:universalActionSection forKey:universalActionSectionKey];
}

- (NSArray *)settingSections {
    @autoreleasepool {
        return @[shortVideoSectionKey, universalSectionKey, universalDidSectionKey, universalActionSectionKey];
    }
}

- (VESettingModel *)settingForKey:(VESettingKey)key {
    NSArray *settings = [NSArray array];
    switch (key / 1000) {
        case 0:{
            settings = [self.settings objectForKey:universalSectionKey];
        }
            break;
        case 1:{
            settings = [self.settings objectForKey:universalActionSectionKey];
        }
            break;
        case 10:{
            settings = [self.settings objectForKey:shortVideoSectionKey];
        }
            break;
    }
    for (VESettingModel *model in settings) {
        if (model.settingKey == key) return model;
    }
    return nil;
}

- (NSString *)sectionKeyLocalized:(NSString *)key {
    if ([key isEqualToString:shortVideoSectionKey]) {
        return LocalizedStringFromBundle(@"shortVideo_strategy", @"VEVodApp");
    } else if ([key isEqualToString:universalSectionKey]) {
        return LocalizedStringFromBundle(@"common_settings", @"VEVodApp");
    }
    return @"";
}

@end
