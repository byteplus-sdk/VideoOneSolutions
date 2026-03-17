// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

#import <ToolKit/Localizator.h>
#import <ToolKit/DeviceInforTool.h>
#import "MDAdSettingManager.h"

static NSString *const inStreamAdPositions = @"in_stream_ad_positions";
static NSInteger const PrerollIndex = 0;
static NSInteger const MidrollIndex = 1;
static NSInteger const PostrollIndex = 2;

@interface MDAdSettingManager ()

@property (nonatomic, strong) NSMutableDictionary *settings;

@end

@implementation MDAdSettingManager

static MDAdSettingManager *instance;
static dispatch_once_t onceToken;
+ (MDAdSettingManager *)universalManager {
    dispatch_once(&onceToken, ^{
        instance = [MDAdSettingManager new];
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
    NSMutableArray *inStreamAdOptions = [NSMutableArray array];
    [inStreamAdOptions addObject:({
        VESettingModel *model = [VESettingModel new];
        model.displayText = LocalizedStringFromBundle(@"mini_drama_ads_pre-roll", @"MiniDramaWithInStreamAds");
        model.settingKey = VESettingKeyShortVideoPreloadStrategy;
        model.open = NO;
        model.settingType = VESettingTypeSwitcher;
        model;
    })];
    [inStreamAdOptions addObject:({
        VESettingModel *model = [VESettingModel new];
        model.displayText = LocalizedStringFromBundle(@"mini_drama_ads_mid-roll", @"MiniDramaWithInStreamAds");
        model.settingKey = VESettingKeyShortVideoPreRenderStrategy;
        model.open = YES;
        model.settingType = VESettingTypeSwitcher;
        model;
    })];
    [inStreamAdOptions addObject:({
        VESettingModel *model = [VESettingModel new];
        model.displayText = LocalizedStringFromBundle(@"mini_drama_ads_post-roll", @"MiniDramaWithInStreamAds");
        model.settingKey = VESettingKeyShortVideoPreRenderStrategy;
        model.open = NO;
        model.settingType = VESettingTypeSwitcher;
        model;
    })];
    [self.settings setValue:inStreamAdOptions forKey:inStreamAdPositions];
}

- (NSArray *)settingSections {
    @autoreleasepool {
        return @[inStreamAdPositions];
    }
}

- (NSString *)sectionKeyLocalized:(NSString *)key {
    if ([key isEqualToString:inStreamAdPositions]) {
        return LocalizedStringFromBundle(@"mini_drama_ads_setting_option", @"MiniDramaWithInStreamAds");
    }
    return @"";
}

- (BOOL)prerollEnabled {
    VESettingModel *prerollModel = _settings[inStreamAdPositions][PrerollIndex];
    return prerollModel.open;
}

- (BOOL)midrollEnabled {
    VESettingModel *midrollModel = _settings[inStreamAdPositions][MidrollIndex];
    return midrollModel.open;
}

- (BOOL)postrollEnabled {
    VESettingModel *postrollModel = _settings[inStreamAdPositions][PostrollIndex];
    return postrollModel.open;
}

@end
