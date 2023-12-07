// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
@import Foundation;

typedef NS_ENUM(NSUInteger, VESceneType){
    VESceneTypeShortVideo = 0,
    VESceneTypeFeedVideo = 1,
    VESceneTypeLongVideo = 2,
};

typedef enum : NSUInteger {
    VESettingTypeDisplay,
    VESettingTypeDisplayDetail,
    VESettingTypeSwitcher,
    VESettingTypeMutilSelector,
    VESettingTypeEntrance
} VESettingDisplayType;

typedef enum : NSUInteger {
    VESettingKeyUniversalH265 = 0000,
    VESettingKeyUniversalHardwareDecode,
    VESettingKeyUniversalDeviceID,
    
    VESettingKeyUniversalActionCleanCache = 1000,
    VESettingKeyUniversalActionPlayVidoeUrl = 1001,
    
    
    VESettingKeyShortVideoPreloadStrategy = 10000,
    VESettingKeyShortVideoPreRenderStrategy,
    
} VESettingKey;

@interface VESettingModel : NSObject

@property (nonatomic, assign) VESettingKey settingKey;

@property (nonatomic, assign) VESettingDisplayType settingType;

@property (nonatomic, assign) BOOL open;

@property (nonatomic, strong) id currentValue;

@property (nonatomic, strong) NSString *displayText;

@property (nonatomic, strong) NSString *detailText;

@property (nonatomic, copy) void(^allAreaAction)(void);

@end

@interface VESettingModel (DisplayCell)

- (NSDictionary *)cellInfo;

- (CGFloat)cellHeight;

@end
